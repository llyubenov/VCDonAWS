#!/bin/bash -e
# xFer Server bootstrapping

# Redirect script output to a log file
exec > /var/log/xfer_bootstrap.log                                                                     
exec 2>&1

# Configuration
PROGRAM='vCD xFer Server'

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

#function xfer_on_amazon_os () {
#}

function xfer_on_cent_os () {
    
    function primary_xfer_on_cent_os () {
        #Mount xFer store
        mkdir  /brick1
        echo '/dev/vol_vcd_xfer/lv_vcd_xfer /brick1 xfs rw,noatime,inode64,nouuid 1 2' >> /etc/fstab
        mount /brick1
        
        #Create xFer Volume folder
        mkdir -p /brick1/xfer

        #Define GlusterFS Nodes
        export xFerPrimary=`curl -s http://169.254.169.254/latest/meta-data/hostname`
        export xFerPeer=`aws ec2 describe-instances --region=$Region --filters "Name=network-interface.subnet-id,Values=$PrivateSubnet2ID" "Name=tag:Name,Values='vCD Transfer Server'" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateDnsName]' | sed -n '4p' | sed -e 's/ //g' -e 's/^"//' -e 's/"$//'`

        sleep 120

        #Create Distributed GlusterFS Volume   
        if [ "$xFerPeer" == "Null" ]; then
            echo "No Secondary Node"
            gluster volume create xfer $xFerPrimary:/brick1/xfer
        else
            #Create Trustes Storage Pool
            gluster peer probe $xFerPeer
            sleep 10
            gluster pool list
            #Create GlusterFS Volume
            gluster volume create xfer $xFerPrimary:/brick1/xfer $xFerPeer:/brick2/xfer
        fi  

        #Start GlusterFS Volume
        gluster volume start xfer 
    }

    function secondary_xfer_on_cent_os () {
        #Mount xFer store
        mkdir  /brick2
        echo '/dev/vol_vcd_xfer/lv_vcd_xfer /brick2 xfs rw,noatime,inode64,nouuid 1 2' >> /etc/fstab
        mount /brick2

        #Create xFer Volume folder
        mkdir -p /brick2/xfer
    }

    # Prepare Variables
    export Region=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone | rev | cut -c 2- | rev`
    export PrivateSubnet2ID=`curl http://169.254.169.254/latest/user-data/ | grep PrivateSubnet2ID | sed 's/PrivateSubnet2ID=//g'`
    export CWG=`curl http://169.254.169.254/latest/user-data/ | grep CLOUDWATCHGROUP | sed 's/CLOUDWATCHGROUP=//g'`
    export MacAddress=`curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/`
    export SubnetID=`curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MacAddress/subnet-id`

    # Install GlusterFS packages
    yum install wget -y
    yum install centos-release-gluster -y
    yum install epel-release -y
    yum install glusterfs-server -y

    #Enable and Start GlusterFS services

    systemctl start glusterd
    systemctl enable glusterd
    
    #Create LVM for Transfer store
    pvcreate /dev/xvdb
    pvscan
    vgcreate vol_vcd_xfer /dev/xvdb
    lvcreate -l 100%FREE -n lv_vcd_xfer vol_vcd_xfer
    mkfs.xfs -L vcdxfer /dev/vol_vcd_xfer/lv_vcd_xfer

    #Configure ClusterFS Volume
    if [ "$SubnetID" == "$PrivateSubnet2ID" ]; then
        #Configure Secondary Node
        secondary_xfer_on_cent_os
    else
        #Configure Primary Node
        primary_xfer_on_cent_os
    fi

    # Install and Configure CloudWatch Log service on xFer
    echo "log_group_name = $CWG" >> /tmp/groupname.txt

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
    cat /tmp/groupname.txt >> ~/cloudwatchlog.conf

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
    xfer_on_amazon_os
# CentOS Linux
elif [ "$release" == "CentOS" ]; then
    #Call function for CentOS
    xfer_on_cent_os
else
    echo "[ERROR] Unsupported Linux OS"
    exit 1
fi

echo "Bootstrap complete."
