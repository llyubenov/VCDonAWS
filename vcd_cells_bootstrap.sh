#!/bin/bash -e
# vCD Cells bootstrapping

# Redirect script output to a log file
exec > /var/log/vcd_cells_bootstrap.log                                                                  
exec 2>&1

# Configuration
PROGRAM='Additional vCD Cells'

##################################### Functions Definitions
function checkos () {
    platform='unknown'
    unamestr=`uname`
    if [[ "$unamestr" == 'Linux' ]]; then
        platform='linux'
    else
        echo "[WARNING] This script is not supported on MacOS or freebsd"
        exit 1
    fi
    echo "${FUNCNAME[0]} Ended"
}

function chkstatus () {
    if [ $? -eq 0 ]
    then
        echo "Script [PASS]"
    else
        echo "Script [FAILED]" >&2
        exit 1
    fi
}

function osrelease () {
    OS=`cat /etc/os-release | grep '^NAME=' |  tr -d \" | sed 's/\n//g' | sed 's/NAME=//g'`
    if [ "$OS" == "Amazon Linux AMI" ]; then
        echo "AMZN"
    elif [ "$OS" == "CentOS Linux" ]; then
        echo "CentOS"
    else
        echo "Operating System Not Found"
    fi
    echo "${FUNCNAME[0]} Ended" >> /var/log/cfn-init.log
}

#function vcd_cells_on_amazon_os () {
#}

function vcd_cells_on_cent_os () {
    # Prepare Variables
    export Region=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone | rev | cut -c 2- | rev`
    export AZ=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`
    export VPCID=`curl http://169.254.169.254/latest/user-data/ | grep VPCID | sed 's/VPCID=//g'`
    export vCDBuildBucketName=`curl http://169.254.169.254/latest/user-data/ | grep vCDBuildBucketName | sed 's/vCDBuildBucketName=//g'`
    export vCDBuildName=`curl http://169.254.169.254/latest/user-data/ | grep vCDBuildName | sed 's/vCDBuildName=//g'`
    export vCDKeystoreFileName=`curl http://169.254.169.254/latest/user-data/ | grep vCDKeystoreFileName | sed 's/vCDKeystoreFileName=//g'`
    export vCDCertKeystorePasswd=`curl http://169.254.169.254/latest/user-data/ | grep vCDCertKeystorePasswd | sed 's/vCDCertKeystorePasswd=//g'`
    export MessagesLogGroup=`curl http://169.254.169.254/latest/user-data/ | grep MessagesLogGroup | sed 's/MessagesLogGroup=//g'`
    export CellLogGroup=`curl http://169.254.169.254/latest/user-data/ | grep CellLogGroup | sed 's/CellLogGroup=//g'`
    export ConsoleProxyLogGroup=`curl http://169.254.169.254/latest/user-data/ | grep ConsoleProxyLogGroup | sed 's/ConsoleProxyLogGroup=//g'`
    export vCloudContainerDebugLogGroup=`curl http://169.254.169.254/latest/user-data/ | grep vCloudContainerDebugLogGroup | sed 's/vCloudContainerDebugLogGroup=//g'`
    export xFerFQDN=`aws ec2 describe-instances --region=$Region --filters "Name=availability-zone,Values=$AZ" "Name=tag:Name,Values='vCD Transfer Server'" "Name=instance-state-name,Values=running" "Name=vpc-id,Values=$VPCID" --query 'Reservations[*].Instances[*].[PrivateDnsName]' | sed -n '4p' | sed -e 's/ //g' -e 's/^"//' -e 's/"$//'`
    export instanceIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4/)
    export vCDJXMS=`curl http://169.254.169.254/latest/user-data/ | grep vCDJXMS | sed 's/vCDJXMS=//g'`
    export vCDJXMX=`curl http://169.254.169.254/latest/user-data/ | grep vCDJXMX | sed 's/vCDJXMX=//g'`

    #Install GluxterFS client
    yum install glusterfs-fuse -y

    #Copy vCD Binaries
    aws s3 cp s3://$vCDBuildBucketName/$vCDBuildName /tmp/$vCDBuildName

    #Set vCD Binaries permissions
    chmod +x /tmp/$vCDBuildName

    #Prepare Transfer Store Mount
    echo "$xFerFQDN:/xfer /opt/vmware/vcloud-director/data/transfer glusterfs defaults,_netdev  0  0" >> /etc/fstab

    #Install vCD
    echo "N" | /tmp/$vCDBuildName

    #Mount Transfer Store and change ownership
    mount /opt/vmware/vcloud-director/data/transfer/
    chown vcloud:vcloud -R /opt/vmware/vcloud-director/data/transfer/

    #Set responses.properties and Java Certificate Keystore permissions
    chmod 644 /opt/vmware/vcloud-director/data/transfer/responses.properties
    chmod 644 /opt/vmware/vcloud-director/data/transfer/$vCDKeystoreFileName

    #Configure vCD Cell
    /opt/vmware/vcloud-director/bin/configure -r /opt/vmware/vcloud-director/data/transfer/responses.properties -ip $instanceIP --primary-port-http 80 --primary-port-https 443 -cons $instanceIP --console-proxy-port-https 8443 --keystore /opt/vmware/vcloud-director/data/transfer/$vCDKeystoreFileName -w $vCDCertKeystorePasswd  --enable-ceip true -unattended

    #Additional changes to vCD global.properties file
cat >> /opt/vmware/vcloud-director/etc/global.properties <<- EOF
# Custom Changes Made for console proxy and DB connections
consoleproxy.websockets.enabled = true
consoleproxy.securenio.buffer.size = 17000
database.pool.maxActive = 200
vcloud.http.maxThreads = 150
vcloud.http.minThreads = 32
vcloud.http.acceptorThreads = 16
hibernate.generate_statistics=true

# Limit the number of active syncs per Subscribed Public Catalog
contentLibrary.item.sync.batch.size = 1

#Configure vCD to cleanup abandoned DB Threads
database.pool.removeAbandoned = true
database.pool.abandonWhenPercentageFull = 0
database.pool.removeAbandonedTimeout = 43200
EOF

    #Set Custom vCD Java Heap Size
    sed -i "s/Xms1024M/Xms${vCDJXMS}M/g" /opt/vmware/vcloud-director/bin/vmware-vcd-cell-common
    sed -i "s/Xmx4096M/Xmx${vCDJXMX}M/g" /opt/vmware/vcloud-director/bin/vmware-vcd-cell-common


   

    # Install and Configure CloudWatch Log service
    echo "log_group_name = $MessagesLogGroup" >> /tmp/MessagesLogGroup.txt
    echo "log_group_name = $CellLogGroup" >> /tmp/CellLogGroup.txt
    echo "log_group_name = $ConsoleProxyLogGroup" >> /tmp/ConsoleProxyLogGroup.txt
    echo "log_group_name = $vCloudContainerDebugLogGroup" >> /tmp/vCloudContainerDebugLogGroup.txt

cat <<'EOF' >> ~/cloudwatchlog.conf
[general]
state_file = /var/awslogs/state/agent-state
use_gzip_http_content_encoding = true
logging_config_file = /var/awslogs/etc/awslogs.conf

[/var/log/messages]
datetime_format = %b %d %H:%M:%S
file = /var/log/messages
buffer_duration = 5000
log_stream_name = {hostname}
initial_position = start_of_file
EOF
    cat /tmp/MessagesLogGroup.txt >> ~/cloudwatchlog.conf

cat <<'EOF' >> ~/cloudwatchlog.conf

[cell.log]
datetime_format = %b %d %H:%M:%S
file = /opt/vmware/vcloud-director/logs/cell.log
buffer_duration = 5000
log_stream_name = {hostname}
initial_position = start_of_file
EOF
    cat /tmp/CellLogGroup.txt >> ~/cloudwatchlog.conf

cat <<'EOF' >> ~/cloudwatchlog.conf

[vcloud-container-debug.log]
datetime_format = %b %d %H:%M:%S
file = /opt/vmware/vcloud-director/logs/vcloud-container-debug.log
buffer_duration = 5000
log_stream_name = {hostname}
initial_position = start_of_file
EOF
    cat /tmp/vCloudContainerDebugLogGroup.txt >> ~/cloudwatchlog.conf

cat <<'EOF' >> ~/cloudwatchlog.conf

[console-proxy.log]
datetime_format = %b %d %H:%M:%S
file = /opt/vmware/vcloud-director/logs/console-proxy.log
buffer_duration = 5000
log_stream_name = {hostname}
initial_position = start_of_file
EOF
    cat /tmp/ConsoleProxyLogGroup.txt >> ~/cloudwatchlog.conf

    curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
    chmod +x ./awslogs-agent-setup.py
    ./awslogs-agent-setup.py -n -r $Region -c ~/cloudwatchlog.conf

cat <<'EOF' >> /etc/systemd/system/awslogs.service
[Unit]
Description=The CloudWatch Logs agent
After=rc-local.service

[Service]
Type=simple
Restart=always
KillMode=process
TimeoutSec=infinity
PIDFile=/var/awslogs/state/awslogs.pid
ExecStart=/var/awslogs/bin/awslogs-agent-launcher.sh --start --background --pidfile $PIDFILE --user awslogs --chuid awslogs &

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable awslogs
    systemctl restart awslogs

    #Start and Stop vCD Cell Services
    service vmware-vcd start
    sleep 120
    
    #Run security updates
cat <<'EOF' >> ~/mycron
0 0 * * * yum -y update --security
EOF
    crontab ~/mycron
    rm ~/mycron
    
    echo "${FUNCNAME[0]} Ended"
}

##################################### End Function Definitions

# Call checkos to ensure platform is Linux
checkos

release=$(osrelease)
# AMZN Linux
if [ "$release" == "AMZN" ]; then
    #Call function for AMZN
    vcd_cells_on_amazon_os
# CentOS Linux
elif [ "$release" == "CentOS" ]; then
    #Call function for CentOS
    vcd_cells_on_cent_os
else
    echo "[ERROR] Unsupported Linux OS"
    exit 1
fi

echo "Bootstrap complete."
