#/bin/bash
# Deploy vm to azure with all the necessary steps
set -e
source .env

VM_HOST=$DNS_NAME.$LOC.cloudapp.azure.com
az group create -n $RG -l $LOC -o table

az vm create \
    --resource-group $RG \
    --name  $VM_NAME \
    --image UbuntuLTS \
    --admin-username $USER \
    --generate-ssh-keys \
    --public-ip-address-dns-name $DNS_NAME\
    --size "Standard_D2_v3"

az vm open-port --port 80 --resource-group $RG --name $VM_NAME
az vm open-port --port 443 --resource-group $RG --name $VM_NAME --priority 942

SETTINGS='{"fileUris": ["https://raw.githubusercontent.com/brusMX/AKS-hybrid/master/deploy-env/harbor-docker-registry/harbor-setup.sh"], "commandToExecute": "./harbor-setup.sh '"$VM_HOST"'"}'

az vm extension set \
    --resource-group $RG \
    --vm-name $VM_NAME \
    --name customScript \
    --publisher Microsoft.Azure.Extensions \
    --protected-settings "$SETTINGS"


echo "Now, you can visit in your browser https://$VM_HOST"
echo "Default credentials are admin/Harbor12345"

