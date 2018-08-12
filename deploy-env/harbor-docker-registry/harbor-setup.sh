#/bin/bash
#/bin/bash
# This has no sudo since its supposed to be run as root by the custom script extension of azure
# Shell script to install basic libraries for harbor - https://github.com/goharbor/harbor/blob/master/docs/installation_guide.md
# Python	version 2.7 or higher	Note that you may have to install Python on Linux distributions (Gentoo, Arch) that do not come with a Python interpreter installed by default
# Docker engine	version 1.10 or higher	For installation instructions, please refer to: https://docs.docker.com/engine/installation/
# Docker Compose	version 1.6.0 or higher	For installation instructions, please refer to: https://docs.docker.com/compose/install/
# Openssl	latest is prefered	Generate certificate and keys for Harbor
set -e

if [ -z "$1" ]; then
    echo -e "${RED}--- ERROR --- Unknown hostname, you need to pass the hostname of the vm as the parameter (e.g ./harbor-setup myvm.eastus.azure.cloudapp.com)${NC}"
    exit 1
fi
VM_URL=$1

# updating
echo "--  **Updating and install apt stuff**"
echo
apt-get update 
apt -y install \
    python-pip \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

echo
echo "--   **Installed stuff now getting docker gpg**"
echo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

echo
echo "--  **Adding right repo for docker ce**"
echo
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" -y

apt-get update 

echo
echo "--   **Installing docker-ce**"
echo 
apt-get -y install docker-ce

echo
echo "-- **Downloading docker compose**"
echo
curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

docker-compose --version
echo
echo "--  **Upgrade open ssl**"
echo
apt -y upgrade openssl


echo
echo "--  **Create your own CA certificate**"
echo
mkdir -p ssl-keys
cd ssl-keys
openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout ca.key \
    -x509 -days 365 -out ca.crt -subj '/CN='${VM_URL}

echo
echo "--  **Certificate Signing Request**"
echo
openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout $VM_URL.key \
    -out $VM_URL.csr -subj '/CN='${VM_URL}


echo
echo "--  **Certificate Signing Request**"
echo
openssl x509 -req \
  -days 365 -in $VM_URL.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out $VM_URL.crt 


echo
echo "--  **Move certs**"
echo
mkdir -p /root/cert
cp $VM_URL.crt /root/cert/
cp $VM_URL.key /root/cert/
cd ..

echo
echo "--  **Downloading harbor*"
echo
wget https://storage.googleapis.com/harbor-releases/harbor-online-installer-v1.5.2.tgz
tar xvf harbor-online-installer-v1.5.2.tgz
rm -rf harbor-online-installer-v1.5.2.tgz
cd harbor

echo
echo "--  **Put certs in harbor.cfg**"
echo
OLD_PATH="ssl_cert\ =\ /data/cert/server.crt"
NEW_PATH="ssl_cert\ =\ /root/cert/$VM_URL.crt"
sed -i s#"$OLD_PATH"#"$NEW_PATH"#g harbor.cfg
OLD_PATH="ssl_cert_key\ =\ /data/cert/server.key"
NEW_PATH="ssl_cert_key\ =\ /root/cert/$VM_URL.key"
sed -i s#"$OLD_PATH"#"$NEW_PATH"#g harbor.cfg
sed -i s#"ui_url_protocol\ =\ http"#"ui_url_protocol\ =\ https"#g harbor.cfg

echo
echo "--  **Replacing chars hostname with: $VM_URL*"
echo
sed -i s/hostname\ =\ reg.mydomain.com/hostname\ =\ $VM_URL/g harbor.cfg

echo
echo "--  **Replacing chars mysql db pass**"
echo
DB_PASS='s5up3r!-S3cur5-p4SSW'
sed -i s/db_password\ =\ root123/db_password\ =\ $DB_PASS/g harbor.cfg


echo
echo "--  **Install harbor**"
echo
./prepare
./install.sh