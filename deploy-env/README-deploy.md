# Building an environment

In order to test these features we need to deploy an infrastructure capable of replicating the asked features. 

## Setting up the network

For this environment we will be using a custom VNet with 2 subnets with non overlapping IP address spaces to emulate the connection. Since Express Route takes up to 40 minutes to deploy, we will not include how to set this up. But if guidance is needed on how to deploy connect the VNET gateways  you can always go visit [this repo](https://github.com/xtophs/acs-k8s-cassandra-multi-dc/blob/master/README.md) or [this repo for different clouds with OpenBSD](https://github.com/dcasati/cross-cloud-vpn).

### Network topology

We will start this sample with a big address space provided by the On-prem network, we will reserve a segment explicit to the Azure services we will deploy, like AKS. Kubernetes will be configured with [CNI plugin](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/networking-overview.md) to take ownership of those IPs in the second address space. Lets do some calculations:

1. On-Prem total adress space:
    - Addres Space: 10.0.0.0/8
    - HostMin: 10.0.0.1
    - HostMax: 10.255.255.254
    - Broadcast: 10.255.255.255
    - Hosts/Net: 16777214

2. Azure services dedicated address space
    - Addres Space: 10.1.0.0/16 
    - HostMin: 10.1.0.1
    - HostMax: 10.1.255.254
    - Broadcast: 10.1.255.255
    - Hosts/Net: 65534

Obviously this range is quite excessive since Azure CNI is limited to 16'000 configured IP Addesses. And advanced networking allows you to have 30 pods per node. So you can resize that if needed.

Let's also rememebet that the Kubernetes service IP address range:

- Must not be within the VNet IP address range of your cluster
- Must not overlap with any other VNets with which the cluster VNet peers
- Must not overlap with any on-premises IPs
- Kubernetes DNS service IP address: The IP address for the cluster's DNS service. This address must be within the Kubernetes service address range.
- Docker Bridge address: The IP address and netmask to assign to the Docker bridge. This IP address must not be within the VNet IP address range of your cluster.

## Comodo Certificates

In order to have a valid set of certificates for our registry, we will be using the free certificates from Comodo.

- [Set up your free comodo SSL certificates](obtaining-certs.md)

## Deploying a daemonset to upload ca.crt to nodes

In order to trust the container registy we created, we need to allow tell docker to trust this new entity. Run the following command to do so"

```bash
cd daemonset-certs
kubectl apply -f upload-ca-cert-daemon.yml
```


## On-prem registry

There are two registries we could use to emulate our on-prem registry scenario:

- [Docker Trusted Registry (requires a Docker Enterprise Edition license)](docker-trusted-registry/README-dtr.md)
- [Harbor Docker registry from VMWare (Opensource project)](harbor-docker-registry/README-harbor.md)

## On-prem bamboo

- [Deploy bamboo to your private vnet](atlassian-bamboo/README-bamboo.md)

## Deploy AKS cluster
