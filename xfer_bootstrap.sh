#!/bin/bash -e
# xFer Server bootstrapping


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
    # Install and Configure CloudWatch Log service on xFer
    export CWG=`curl http://169.254.169.254/latest/user-data/ | grep CLOUDWATCHGROUP | sed 's/CLOUDWATCHGROUP=//g'`
    export NFSCIDR=`curl http://169.254.169.254/latest/user-data/ | grep VPCCIDR| sed 's/VPCCIDR=//g'`
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
    export Region=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone | rev | cut -c 2- | rev`
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

    #Create LVM for Xfer store
    pvcreate /dev/xvdb
    pvscan
    vgcreate vol_vcd_xfer /dev/xvdb
    lvcreate -l 100%FREE -n lv_vcd_xfer vol_vcd_xfer
    mkfs.ext4 -L vcdxfer /dev/vol_vcd_xfer/lv_vcd_xfer

    #Mount xFer store
    mkdir -p /exports/xfer
    echo '/dev/vol_vcd_xfer/lv_vcd_xfer  /exports/xfer ext4    defaults        0 0' >> /etc/fstab
    mount /exports/xfer/

    #Configure NFS Service
    echo "/exports/xfer $NFSCIDR(rw,no_root_squash)" >> /etc/exports
    systemctl enable nfs
    systemctl start nfs
    
    #Create Cells folder in the Xfer Store
    mkdir -p /exports/xfer/cells


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
