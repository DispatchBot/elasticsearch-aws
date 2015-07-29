#!/bin/bash

##
# Custom script to create an EBS volume. We do this in a user data bash script
# so that we can have an encrypted EBS. It is not possible to do this with cloudformation
# without having an encrypted snapshot you clone from, which just seems like a hack
# to us.


##
# Size in GB of the EBS volume to create
VOLUME_SIZE=100

# Get the region and zone of this instance.
EC2_AZ=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AZ\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
EC2_INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`

# Create an EBS volume
VOLUME_ID=`aws ec2 create-volume --size $VOLUME_SIZE --volume-type gp2 --encrypted --availability-zone $EC2_AZ --region $EC2_REGION --query 'VolumeId'`

VOLUME_ID="${VOLUME_ID%\"}"
VOLUME_ID="${VOLUME_ID#\"}"

# Wait for the volume to be created...
while true; do
  VOLUME_STATUS=`aws ec2 describe-volumes --volume-ids $VOLUME_ID --region $EC2_REGION --query 'Volumes[0].State'`
  VOLUME_STATUS="${VOLUME_STATUS%\"}"
  VOLUME_STATUS="${VOLUME_STATUS#\"}"

  if [ "$VOLUME_STATUS" = "available" ]; then
    echo 'Volume is ready'
    break
  fi

  echo "Volume status is $VOLUME_STATUS. Waiting..."

  sleep 3
done

# Attach the volume to self.
aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $EC2_INSTANCE_ID --device /dev/xvdh --region $EC2_REGION

# Now wait for it to attach.
while true; do
  VOLUME_STATUS=`aws ec2 describe-volumes --volume-ids $VOLUME_ID --region $EC2_REGION --query 'Volumes[0].Attachments[0].State'`
  VOLUME_STATUS="${VOLUME_STATUS%\"}"
  VOLUME_STATUS="${VOLUME_STATUS#\"}"

  if [ "$VOLUME_STATUS" = "attached" ]; then
    echo 'Volume is attached'
    break
  fi

  echo "Volume status is $VOLUME_STATUS. Waiting..."

  sleep 3
done

# Mount it.
mkfs -t ext4 /dev/xvdh
mkdir -p /esdata
mount /dev/xvdh /esdata

# Add to the fstab so it survives restarts
echo "/dev/xvdh  /esdata  ext4  defaults,nofail  0  2\n" >> /etc/fstab

# Delete volume on termination. Just some convenient clean up.
aws ec2 modify-instance-attribute --instance-id $EC2_INSTANCE_ID --block-device-mappings "[{ \"DeviceName\": \"/dev/xvdh\", \"Ebs\": { \"VolumeId\": \"$VOLUME_ID\", \"DeleteOnTermination\": true }}]" --region $EC2_REGION

# Docker daemon does not see newly mounted volumes. Restart the service.
service docker restart
start ecs

# Set the rack_id to the AZ. Helps ensure that we never have replicas in the same zone.
echo "node.rack_id: $EC2_AZ" >> /etc/elasticsearch/elasticsearch.yml
