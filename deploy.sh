# debug
# set -o xtrace

## Queue node ##

KEY_NAME="ex02-cloud-yo-`date +'%N'`"
KEY_PEM="$KEY_NAME.pem"

echo "create key pair $KEY_PEM to connect to instances and save locally"
aws ec2 create-key-pair --key-name $KEY_NAME \
    | jq -r ".KeyMaterial" > $KEY_PEM
mv $KEY_PEM ~/KEY_PEM
# secure the key pair
chmod 400 ~/$KEY_PEM

SEC_GRP="ex02-cloud-yo-`date +'%N'`"

echo "setup firewall $SEC_GRP"
aws ec2 create-security-group   \
    --group-name $SEC_GRP       \
    --description "Access my instances" 

# figure out my ip
MY_IP=$(curl ipinfo.io/ip)
echo "My IP: $MY_IP"


echo "setup rule allowing SSH access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 22 --protocol tcp \
    --cidr $MY_IP/32

echo "setup rule allowing HTTP (port 3000) access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 3000 --protocol tcp \
    --cidr $MY_IP/32

UBUNTU_20_04_AMI="ami-042e8287309f5df03"

echo "Creating Ubuntu 20.04 instance..."
RUN_INSTANCES=$(aws ec2 run-instances   \
    --image-id $UBUNTU_20_04_AMI        \
    --instance-type t3.micro            \
    --key-name $KEY_NAME                \
    --security-groups $SEC_GRP)

INSTANCE_ID=$(echo $RUN_INSTANCES | jq -r '.Instances[0].InstanceId')

echo "Waiting for instance creation..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

QUEUE_PUBLIC_IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID | 
    jq -r '.Reservations[0].Instances[0].PublicIpAddress'
)

echo "New instance $INSTANCE_ID @ $QUEUE_PUBLIC_IP"

echo "deploying code to production"
scp -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=60" ex2queue.zip ubuntu@$QUEUE_PUBLIC_IP:/home/ubuntu/

echo "setup production environment"
ssh -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" ubuntu@$QUEUE_PUBLIC_IP <<EOF
    sudo apt update
    sudo apt install unzip curl-y
    unzip ex2queue.zip
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
    # run app
    npm install
    nohup npm start &>/dev/null &
    exit
EOF

echo "test that it all worked"
curl --retry 10 --retry-delay 1  http://$QUEUE_PUBLIC_IP:3000



## API nodes ##
### 1 ###

KEY_NAME="ex02-api1-yo-`date +'%N'`"
KEY_PEM="$KEY_NAME.pem"

echo "create key pair $KEY_PEM to connect to instances and save locally"
aws ec2 create-key-pair --key-name $KEY_NAME \
    | jq -r ".KeyMaterial" > $KEY_PEM
mv $KEY_PEM ~/KEY_PEM
# secure the key pair
chmod 400 ~/$KEY_PEM

SEC_GRP="ex02-api1-yo-`date +'%N'`"

echo "setup firewall $SEC_GRP"
aws ec2 create-security-group   \
    --group-name $SEC_GRP       \
    --description "Access my instances" 

# figure out my ip
MY_IP=$(curl ipinfo.io/ip)
echo "My IP: $MY_IP"


echo "setup rule allowing SSH access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 22 --protocol tcp \
    --cidr $MY_IP/32

echo "setup rule allowing HTTP (port 3000) access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 3000 --protocol tcp \
    --cidr $MY_IP/32

UBUNTU_20_04_AMI="ami-042e8287309f5df03"

echo "Creating Ubuntu 20.04 instance..."
RUN_INSTANCES=$(aws ec2 run-instances   \
    --image-id $UBUNTU_20_04_AMI        \
    --instance-type t3.micro            \
    --key-name $KEY_NAME                \
    --security-groups $SEC_GRP)

INSTANCE_ID=$(echo $RUN_INSTANCES | jq -r '.Instances[0].InstanceId')

echo "Waiting for instance creation..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID | 
    jq -r '.Reservations[0].Instances[0].PublicIpAddress'
)

echo "New instance $INSTANCE_ID @ $PUBLIC_IP"

echo "deploying code to production"
scp -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=60" ex2api.zip ubuntu@$PUBLIC_IP:/home/ubuntu/

echo "setup production environment"
ssh -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" ubuntu@$PUBLIC_IP <<EOF
    sudo apt update
    sudo apt install unzip curl-y
    unzip ex2api.zip
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
    export QUEUE_PUBLIC_IP=${QUEUE_PUBLIC_IP}
    # run app
    npm install
    nohup npm start &>/dev/null &
    exit
EOF

echo "test that it all worked"
curl --retry 10 --retry-delay 1  http://$PUBLIC_IP:3000

### 2 ###

KEY_NAME="ex02-api2-yo-`date +'%N'`"
KEY_PEM="$KEY_NAME.pem"

echo "create key pair $KEY_PEM to connect to instances and save locally"
aws ec2 create-key-pair --key-name $KEY_NAME \
    | jq -r ".KeyMaterial" > $KEY_PEM
mv $KEY_PEM ~/KEY_PEM
# secure the key pair
chmod 400 ~/$KEY_PEM

SEC_GRP="ex02-api2-yo-`date +'%N'`"

echo "setup firewall $SEC_GRP"
aws ec2 create-security-group   \
    --group-name $SEC_GRP       \
    --description "Access my instances" 

# figure out my ip
MY_IP=$(curl ipinfo.io/ip)
echo "My IP: $MY_IP"


echo "setup rule allowing SSH access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 22 --protocol tcp \
    --cidr $MY_IP/32

echo "setup rule allowing HTTP (port 3000) access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 3000 --protocol tcp \
    --cidr $MY_IP/32

UBUNTU_20_04_AMI="ami-042e8287309f5df03"

echo "Creating Ubuntu 20.04 instance..."
RUN_INSTANCES=$(aws ec2 run-instances   \
    --image-id $UBUNTU_20_04_AMI        \
    --instance-type t3.micro            \
    --key-name $KEY_NAME                \
    --security-groups $SEC_GRP)

INSTANCE_ID=$(echo $RUN_INSTANCES | jq -r '.Instances[0].InstanceId')

echo "Waiting for instance creation..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID | 
    jq -r '.Reservations[0].Instances[0].PublicIpAddress'
)

echo "New instance $INSTANCE_ID @ $PUBLIC_IP"

echo "deploying code to production"
scp -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=60" ex2api.zip ubuntu@$PUBLIC_IP:/home/ubuntu/

echo "setup production environment"
ssh -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" ubuntu@$PUBLIC_IP <<EOF
    sudo apt update
    sudo apt install unzip curl-y
    unzip ex2api.zip
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
    export QUEUE_PUBLIC_IP=${QUEUE_PUBLIC_IP}
    # run app
    npm install
    nohup npm start &>/dev/null &
    exit
EOF

echo "test that it all worked"
curl --retry 10 --retry-delay 1  http://$PUBLIC_IP:3000

## worker nodes ##
### 1 ###

KEY_NAME="ex02-worker1-yo-`date +'%N'`"
KEY_PEM="$KEY_NAME.pem"

echo "create key pair $KEY_PEM to connect to instances and save locally"
aws ec2 create-key-pair --key-name $KEY_NAME \
    | jq -r ".KeyMaterial" > $KEY_PEM
mv $KEY_PEM ~/KEY_PEM
# secure the key pair
chmod 400 ~/$KEY_PEM

SEC_GRP="ex02-worker1-yo-`date +'%N'`"

echo "setup firewall $SEC_GRP"
aws ec2 create-security-group   \
    --group-name $SEC_GRP       \
    --description "Access my instances" 

# figure out my ip
MY_IP=$(curl ipinfo.io/ip)
echo "My IP: $MY_IP"


echo "setup rule allowing SSH access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 22 --protocol tcp \
    --cidr $MY_IP/32

echo "setup rule allowing HTTP (port 3000) access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 3000 --protocol tcp \
    --cidr $MY_IP/32

UBUNTU_20_04_AMI="ami-042e8287309f5df03"

echo "Creating Ubuntu 20.04 instance..."
RUN_INSTANCES=$(aws ec2 run-instances   \
    --image-id $UBUNTU_20_04_AMI        \
    --instance-type t3.micro            \
    --key-name $KEY_NAME                \
    --security-groups $SEC_GRP)

INSTANCE_ID=$(echo $RUN_INSTANCES | jq -r '.Instances[0].InstanceId')

echo "Waiting for instance creation..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID | 
    jq -r '.Reservations[0].Instances[0].PublicIpAddress'
)

echo "New instance $INSTANCE_ID @ $PUBLIC_IP"

echo "deploying code to production"
scp -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=60" ex2worker.zip ubuntu@$PUBLIC_IP:/home/ubuntu/

echo "setup production environment"
ssh -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" ubuntu@$PUBLIC_IP <<EOF
    sudo apt update
    sudo apt install unzip curl-y
    unzip ex2worker.zip
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
    export QUEUE_PUBLIC_IP=${QUEUE_PUBLIC_IP}
    # run app
    npm install
    nohup npm start &>/dev/null &
    exit
EOF

echo "test that it all worked"
curl --retry 10 --retry-delay 1  http://$PUBLIC_IP:3000

### 2 ###

KEY_NAME="ex02-worker2-yo-`date +'%N'`"
KEY_PEM="$KEY_NAME.pem"

echo "create key pair $KEY_PEM to connect to instances and save locally"
aws ec2 create-key-pair --key-name $KEY_NAME \
    | jq -r ".KeyMaterial" > $KEY_PEM
mv $KEY_PEM ~/KEY_PEM
# secure the key pair
chmod 400 ~/$KEY_PEM

SEC_GRP="ex02-worker2-yo-`date +'%N'`"

echo "setup firewall $SEC_GRP"
aws ec2 create-security-group   \
    --group-name $SEC_GRP       \
    --description "Access my instances" 

# figure out my ip
MY_IP=$(curl ipinfo.io/ip)
echo "My IP: $MY_IP"


echo "setup rule allowing SSH access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 22 --protocol tcp \
    --cidr $MY_IP/32

echo "setup rule allowing HTTP (port 3000) access to $MY_IP only"
aws ec2 authorize-security-group-ingress        \
    --group-name $SEC_GRP --port 3000 --protocol tcp \
    --cidr $MY_IP/32

UBUNTU_20_04_AMI="ami-042e8287309f5df03"

echo "Creating Ubuntu 20.04 instance..."
RUN_INSTANCES=$(aws ec2 run-instances   \
    --image-id $UBUNTU_20_04_AMI        \
    --instance-type t3.micro            \
    --key-name $KEY_NAME                \
    --security-groups $SEC_GRP)

INSTANCE_ID=$(echo $RUN_INSTANCES | jq -r '.Instances[0].InstanceId')

echo "Waiting for instance creation..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID | 
    jq -r '.Reservations[0].Instances[0].PublicIpAddress'
)

echo "New instance $INSTANCE_ID @ $PUBLIC_IP"

echo "deploying code to production"
scp -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=60" ex2worker.zip ubuntu@$PUBLIC_IP:/home/ubuntu/

echo "setup production environment"
ssh -i ~/$KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" ubuntu@$PUBLIC_IP <<EOF
    sudo apt update
    sudo apt install unzip curl-y
    unzip ex2worker.zip
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
    export QUEUE_PUBLIC_IP=${QUEUE_PUBLIC_IP}
    # run app
    npm install
    nohup npm start &>/dev/null &
    exit
EOF

echo "test that it all worked"
curl --retry 10 --retry-delay 1  http://$PUBLIC_IP:3000
