# How to deploy a secure container registry and store the certificates to Azure key vault

1. Create an Ubuntu 16.04 VM
2. [Install Harbor Container Registry on it](https://github.com/vmware/harbor/blob/master/docs/installation_guide.md)
3. [Make sure to create the certificates and configure SSL](https://github.com/vmware/harbor/blob/master/docs/configure_https.md)
4. Go into the admin of Harbor and create a project
5. Create a dockerfile in your computer and upload it to harbor registry
6. Download the certificates from your VM into your machine, you can use SCP.
7. Copy the certificate to your machine `/etc/docker/certs.d/<domain-name>` or in Windows double click the certificate and restart docker.
8. Create an Azure Keyvault and upload the ca.crt as a secret  ([Check Noel's](https://www.noelbundick.com/posts/importing-certificates-to-key-vault/)) 

    ```bash
     az keyvault create -n k8s-keyvault-01 -g AKS-experiments --enabled-for-deployment --enabled-for-disk-encryption --enabled-for-template-deployment
     az keyvault secret set -n harbor-website-cert --vault-name k8s-keyvault-01 -f ca.crt
    ```

9. Connect to your client VM and download the Azure KeyVault secret with a valid SP

    ```bash
    az keyvault secret download -n harbor-website-cert --vault-name k8s-jeyvault-01 -f ca.crt
    ```

10. Trust the certificate by uploading it into the trusted valid ca-certificates.

    ```bash
    cp ca.crt /etc/docker/certs.d/<domain-name>
    ```

11. Try it out by downloading an image in your client server.

    ```bash
    docker login harbor-registry.eastus.cloudapp.azure.com -u brusmx
    docker pull harbor-registry.eastus.cloudapp.azure.com/test-a1/brusbox:1.0
    ```