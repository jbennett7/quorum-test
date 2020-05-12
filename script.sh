#!/bin/bash
NAME=quorum

# CHANGE THIS TO HOW YOU EXECUTE the aws command
AWS='aws --profile contino'

# CHANGE THIS TO YOUR KEY
KEY_PAIR_NAME=INSERT_KEY_NAME_HERE

# CHANGE THIS TO YOUR SECURITY GROUP
SECURITY_GROUP_NAME=${NAME}

INSTANCE_PROFILE=${NAME}
AMI=ami-0323c3dd2da7fb37d
INSTANCE_TYPE=c5n.4xlarge

VPC_ID=$(${AWS} ec2 describe-vpcs \
    --query 'Vpcs[0].VpcId' \
    --output text)
SUBNET_IDS=$(${AWS} ec2 describe-subnets \
    --filters Name=vpc-id,Values=${VPC_ID} \
    --query 'Subnets[].SubnetId' \
    --output text)  
SECURITY_GROUP=$(${AWS} ec2 describe-security-groups \
    --filters Name=vpc-id,Values=${VPC_ID} \
    --query 'SecurityGroups[?GroupName==`'${SECURITY_GROUP_NAME}'`].GroupId' \
    --output text)

INSTANCE_IDS=$(${AWS} ec2 run-instances \
    --image-id ${AMI} \
    --count 1 \
    --instance-type ${INSTANCE_TYPE} \
    --key-name ${KEY_PAIR_NAME} \
    --security-group-ids ${SECURITY_GROUP} \
    --subnet-id $(echo ${SUBNET_IDS}|awk '{print $1}') \
    --associate-public-ip-address \
    --iam-instance-profile Name=${INSTANCE_PROFILE} \
    --user-data file://user-data.txt \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NAME}-Instance}]" \
    --query 'Instances[].InstanceId' \
    --output text)
echo ${INSTANCE_IDS} > .instance_ids
${AWS} ec2 wait instance-running --instance-ids ${INSTANCE_IDS}
INSTANCE_IP=$(${AWS} ec2 describe-instances \
    --instance-ids ${INSTANCE_IDS} \
    --query 'Reservations[].Instances[].PublicIpAddress' \
    --output text)
echo "${INSTANCE_IP}" |tee .instance_ip
