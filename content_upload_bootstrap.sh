#!/bin/bash -e
# Contnt Upload bootstrapping

# Redirect script output to a log file
exec > /var/log/content_upload_bootstrap.log                                                                  
exec 2>&1

# Configuration
PROGRAM='Content Upload Instance Bootstrap'

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
    if [ "$OS" == "Amazon Linux" ]; then
        echo "AMZN"
    elif [ "$OS" == "CentOS Linux" ]; then
        echo "CentOS"
    else
        echo "Operating System Not Found"
    fi
    echo "${FUNCNAME[0]} Ended" >> /var/log/cfn-init.log
}

function content_upload_on_amazon_os () {
    export Region=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone | rev | cut -c 2- | rev`
    export AZ=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`
    export VPCID=`curl http://169.254.169.254/latest/user-data/ | grep VPCID | sed 's/VPCID=//g'`
    export ContentUploadBucket=`curl http://169.254.169.254/latest/user-data/ | grep ContentUploadBucket | sed 's/ContentUploadBucket=//g'`

    #Install AWS CLI
    pip install awscli --ignore-installed six

    # Install Python 3
    yum install -y python3 python3-devel

    # Install vCD Python SDK
    pip3 install --user pyvcloud

    # Clone S3FS repository from Git
    cd /opt
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git

    # Compile S3FS
    cd /opt/s3fs-fuse
    ./autogen.sh
    ./configure --prefix=/usr --with-openssl
    make
    make install

    # Create Content Upload directory
    mkdir -p /opt/$ContentUploadBucket

    # Add S3 bucket mount point to fstab
    echo "s3fs#$ContentUploadBucket /opt/$ContentUploadBucket fuse _netdev,allow_other,iam_role=auto,url=http://s3-$Region.amazonaws.com 0 0" >> /etc/fstab

    #Mount S3 bucket
    mount /opt/$ContentUploadBucket
    sleep 10

    # Upload Content Upload Helper Script
    cp /opt/$ContentUploadBucket/scripts/tenantlib.py /root/.local/lib/python3.7/site-packages/tenantlib.py

    # Upload Content Upload Script
    cp /opt/$ContentUploadBucket/scripts/content-upload.py /tmp/content-upload.py

    #Add Amazon Time Sync to Chrony
    echo "server 169.254.169.123 prefer iburst" >> /etc/chrony.conf
    systemctl restart chronyd

    #Run security updates
cat <<'EOF' >> ~/mycron
0 0 * * * yum -y update --security
EOF
    crontab ~/mycron
    rm ~/mycron
    
    echo "${FUNCNAME[0]} Ended"
}

function content_upload_on_cent_os () {
}

##################################### End Function Definitions

# Call checkos to ensure platform is Linux
checkos

release=$(osrelease)
# AMZN Linux
if [ "$release" == "AMZN" ]; then
    #Call function for AMZN
    content_upload_on_amazon_os
# CentOS Linux
elif [ "$release" == "CentOS" ]; then
    #Call function for CentOS
    content_upload_on_cent_os
else
    echo "[ERROR] Unsupported Linux OS"
    exit 1
fi

echo "Bootstrap complete."
