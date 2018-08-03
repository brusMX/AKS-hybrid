# Creating a pipeline in bamboo to integrate the hybrid scenario

Merge your PR to master and a webhook will deploy a docker builder, push it to the DTR and then kubernetes will make sure to have the latest version update the current service.