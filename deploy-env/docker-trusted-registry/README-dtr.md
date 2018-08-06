# How to install a secure DTR in Azure

## Requirements

1. [Terraform](https://www.terraform.io/downloads.html)
2. [Ansibe >= 2.5](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-ubuntu)

## Deploying infrastructure

1. Download the ansible/terraform artifacts `azure-v1.0.0.tar.gz` for Docker EE from [Docker Success Center](https://success.docker.com/article/certified-infrastructures-azure)

2. Uncompress the file and navigate to the folder just crated, inside the folder copy the variables file from the sample file:

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

3. You will need a SP. To obtain a service principal with contributor access to the subscription, you can always use my script:

    ```bash
    wget https://gist.githubusercontent.com/brusMX/bab2224dc1b0c26d3aef4799cb97c045/raw/bf05884b5aeca9ae0c455af3ce0e695ec372cccc/getAzureServicePrincipal.sh && chmod +x getAzureServicePrincipal.sh && ./getAzureServicePrincipal.sh
    ```
    And replace it in `terraform.tfvars`:

    ```bash
    client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # Service Principal UUID
    client_secret   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"    # Service Principal App Secret
    subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # Subscription UUID
    tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # Tenant UUID
    ```

4. Update the rest of the needed variables
    1. Region:

        ```bash
        region                   = "eastus"                    # Where to deploy (e.g. Central US)
        ```

    2. VMs username:

        ```bash
        linux_user                = "<User with root privileges>"
        ```

    3. SSH public key, make sure your key without a passphrase because they are not supported by terraform.

        ```bash
        ssh_key_path             = "~/.ssh/id_rsa.pub"                           # Path to your ssh public key
        ```

5. Download from the Docker store a valid license and place it inside this folder. It should be called `docker_subscription.lic` to match the name and location specified in `ucp_license_path`.
6. Now we can start the installation as suggested by the Docker success center:
    - `terraform init` - Ensure that all provider dependencies are downloaded in preparation for provisioning
    - `terraform plan` - Detail the steps to be performed and ensure that all providers and configuration are correct

    If everything is correct, proceed to the deployment:

    ```bash
    terraform apply
    ```
7. The script will be done after 5 minutes.

## Deploying configuration

1. Update `group_vars/linux` and make sure that the username matches the one in your `terraform.tfvars`.
2. As suggested, try to connect to the VMs. 
    1. Note: In windows WSL thre is a [bug](https://github.com/ansible/ansible/issues/42388), so in order to prevent ansible for asking you to verify all the instance names go ahead and add the following argument after all the IP addresses in the inventory/1.hosts: ` ansible_ssh_common_args='-o StrictHostKeyChecking=no'`. It would look something like this:

        ```bash
        [linux-ucp-manager-primary]
        docker-ee-bruno-Manager-Linux-1 ansible_user=brusmx ansible_host=43.13.37.119 ansible_ssh_common_args='-o StrictHostKeyChecking=no'

        [linux-ucp-manager-replicas]
        docker-ee-bruno-Manager-Linux-2 ansible_user=brusmx ansible_host=43.114.28.214 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
        docker-ee-bruno-Manager-Linux-3 ansible_user=brusmx ansible_host=43.114.30.166 ansible_ssh_common_args='-o StrictHostKeyChecking=no'

        [linux-dtr-worker-primary]
        docker-ee-bruno-DTR-Linux-1 ansible_user=brusmx ansible_host=42.114.26.101 ansible_ssh_common_args='-o StrictHostKeyChecking=no'

        [linux-dtr-worker-replicas]
        docker-ee-bruno-DTR-Linux-2 ansible_user=brusmx ansible_host=41.114.37.171 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
        docker-ee-bruno-DTR-Linux-3 ansible_user=brusmx ansible_host=47.114.28.113 ansible_ssh_common_args='-o StrictHostKeyChecking=no'

        [linux-workers]
        docker-ee-bruno-Worker-Linux-1 ansible_user=brusmx ansible_host=43.114.2.115 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
        docker-ee-bruno-Worker-Linux-2 ansible_user=brusmx ansible_host=43.14.3.118 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
        docker-ee-bruno-Worker-Linux-3 ansible_user=brusmx ansible_host=43.14.32.194 ansible_ssh_common_args='-o StrictHostKeyChecking=no'

        ```

    Try the connection:

    ```bash
    ansible --private-key=/home/brusmx/.ssh/id_rsa  -i ./inventory -m ping linux

    docker-ee-bruno-Manager-Linux-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
    }
    docker-ee-bruno-DTR-Linux-1 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    docker-ee-bruno-Manager-Linux-2 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    docker-ee-bruno-DTR-Linux-3 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    docker-ee-bruno-DTR-Linux-2 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    docker-ee-bruno-Worker-Linux-2 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    docker-ee-bruno-Manager-Linux-3 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    docker-ee-bruno-Worker-Linux-1 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    docker-ee-bruno-Worker-Linux-3 | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }
    ```

Proceed with the generation of certificates: Licenses and Certificates -> https://success.docker.com/article/certified-infrastructures-azure
