You can use Redis Enterprise on Azure Container Services (AKS). For this example we'l be using OSx (MacOS) High Sierra and Azure CLI 2.0.

# Deploying Redis Enterprise with Kubernetes on Google Cloud 
It takes 4 steps to get a Redis Enterprise Cluster running under Azure AKS.
* Step #1 - Create Azure resource group
* Step #2 - Create a Kubernetes cluster on Google Cloud
* Step #3 - Get an external IP for remote administration
* Step #4 - Create Redis Enterprise Cluster deployment

_Note: The deployment is deliberately simplified and is great for getting started with Kubernetes and Redis Enterprise fast. Instructions are not intended for production usgrade deployments._

## Requirements
The steps below were performed using the latest [Azure Cloud sdk](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) and [kubectl tool](https://kubernetes.io/docs/tasks/kubectl/install/) on MacOS. There may be slight differences in detailed instructions with another operating system.

### Step-1: Create an Azure resource group
Resource group will hold all the related resources together under a single name. 
```
az group create --name redis-rg --location eastus
```

### Step-2: Create a new AKS cluster for Redis Enterprise
This may take a while. We'll use a 3 node cluster here.
```
az aks create --resource-group redis-aks-rg --name redis-aks --node-count 1 --generate-ssh-keys
```
You can use "`az aks show --resource-group redis-aks-rg --name redis-aks`" to monitor status under provisioningState attribute. 

Then, add credentials;
```
az aks get-credentials --resource-group redis-aks-rg --name redis-aks
```

### Step-3: Get an external static IP Address
We'll use this to get to the Redis Enterprise Admin UI.
```
az network public-ip create --resource-group MC_redis-aks-rg_redis-aks_eastus --name redis-ip --allocation-method static
az network public-ip list --resource-group MC_redis-aks-rg_redis-aks_eastus --query [0].ipAddress --output tsv
```

### Step-4: Create Redis Enterprise cluster on AKS
use the redis-enterprise.yaml to deploy redis enterprise.
```
kubectl create -f redis-enterprise.yaml
```

Validate the deployment is accesible using "'kubectl get service redis'". You can also view the kubernetes admin UI using "'az aks browse --resource-group redis-aks-rg --name redis-aks'"

