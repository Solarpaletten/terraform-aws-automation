#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install additional tools
apt-get install -y htop curl wget unzip jq

# Create application directory
mkdir -p /opt/app
chown ubuntu:ubuntu /opt/app

# Create a test script that interacts with S3
cat << 'EOF' > /opt/app/s3_test.sh
#!/bin/bash
BUCKET_NAME="${bucket_name}"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
HOSTNAME=$(hostname)

# Create a test file
echo "Server $HOSTNAME started at $TIMESTAMP" > /tmp/server_status.txt

# Upload to S3
aws s3 cp /tmp/server_status.txt s3://$BUCKET_NAME/server-logs/status_$TIMESTAMP.txt

# List objects in bucket
echo "S3 Objects:"
aws s3 ls s3://$BUCKET_NAME/server-logs/

# Log to system
logger "EC2 instance $HOSTNAME uploaded status to S3 bucket $BUCKET_NAME"
EOF

chmod +x /opt/app/s3_test.sh
chown ubuntu:ubuntu /opt/app/s3_test.sh

# Run the S3 test script
/opt/app/s3_test.sh

# Setup cron job to periodically test S3 access (every hour)
echo "0 * * * * ubuntu /opt/app/s3_test.sh" >> /etc/crontab

# Create startup completion marker
touch /opt/app/startup_complete

# Log startup completion
logger "EC2 user data script completed successfully"
echo "EC2 user data script completed at $(date)" > /opt/app/startup.log