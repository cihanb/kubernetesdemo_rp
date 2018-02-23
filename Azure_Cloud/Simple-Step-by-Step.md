You can use Redis Enterprise on Azure Container Services (AKS). For this example we'l be using OSx (MacOS) High Sierra and Azure CLI 2.0.

### Step-1: Ensure you have AKS (azure container services) available on commandline
if you have not done so, login to Azure environment using CLI 2.0 using "`az login`" first.
```
az provider show -n Microsoft.ContainerService
```

### Step-2: Create an Azure resource group
Resource group will hold all the related resources together under a single name. 
```
az group create --name redis-rg --location eastus
```

### Step-3: Create a new AKS cluster for Redis Enterprise
This may take a while. We'll use a 3 node cluster here.
```
az aks create --resource-group redis-rg --name redis-aks --node-count 1 --generate-ssh-keys
```
You can use "`az aks show --resource-group redis-rg --name redis-aks`" to monitor status under provisioningState attribute. 

Then, add credentials;
```
az aks get-credentials --resource-group redis-rg --name redis-aks
```

### Step-4: Get an external static IP Address
We'll use this to get to the Redis Enterprise Admin UI.
```
az network public-ip create --resource-group MC_redis-rg_redis-aks_eastus --name redis-ip --allocation-method static
az network public-ip list --resource-group redis-rg --name redis-ip --query [0].ipAddress --output tsv
```

### Step-5: Create Redis Enterprise cluster on AKS
use the redis-enterprise.yaml to deploy redis enterprise.
```
kubectl create -f redis-enterprise.yaml
```

Validate the deployment is accesible using "'kubectl get service redis'". You can also view the kubernetes admin UI using "'az aks browse --resource-group redis-rg --name redis-aks'"

