# Building an environment

In order to test these features we need to deploy an infrastructure capable of replicating the asked features. This is a simple diagram of what we want to accomplish regarding infrastructure:



## Comodo Certificates

In order to have a valid set of certificates for our registry, we will be using the free certificates from Comodo.

- [Set up your free comodo SSL certificates](obtaining-certs.md)
  
## On-prem registry

There are two registries we could use to emulate our on-prem registry scenario:

- [Docker Trusted Registry (requires a Docker Enterprise Edition license)](docker-trusted-registry/README-dtr.md)
- [Harbor Docker registry from VMWare (Opensource project)](harbor-docker-registry/README-harbor.md)

## On-prem bamboo

- [Deploy bamboo to your private vnet](atlassian-bamboo/README-bamboo.md)

