Kubernetes provides simple orchestration with containers and has been widely adapted. It is simple to get a Redis Enterprise Pack (Redis<sup>e</sup> Pack) cluster on kubernetes with the new Redis Enterprise Pack Docker container. 

# What is Redis Enterprise Pack?
Redis is the most popular database used with Docker containers. Redis Enterprise Pack extends open source Redis and delivers stable high performance, linear scaling and high availability with significant operational savings.

# Step by Step Deployment for (Redis<sup>e</sup> Pack) on Kubernetes on Google Cloud 
We will go through XXX steps to set up our cluster with Redis Enterprise Pack (Redis<sup>e</sup> Pack)
Step #1 - Create a kubernetes cluster on Google Cloud
Step #2 - Deploy the Redis Enterprise Pack (Redis<sup>e</sup> Pack) containers to Kubernetes cluster
Step #3 - Setup Redis Enterprise Pack (Redis<sup>e</sup> Pack) cluster
Step #4 - Create a Redis database and test your connectivity

## Requirements
When performing the steps I used latest Google Cloud SDK - https://cloud.google.com/sdk/ on MacOS. There may be slight differences with other operating systems.

## Step #1 - Create a kubernetes cluster on Google Cloud
On your Google Cloud console, click on "Container Engine" option on the left nav and create a new cluster.
![getting-started](https://raw.githubusercontent.com/cihanb/kubernetesdemo_rp/master/media/get-started.jpeg)

To define your kubernetes cluster, give it a name and keep the size of the cluster to 3 nodes. we'll use all 3 nodes to deploy the Redis Enterprise Pack (Redis<sup>e</sup> Pack) cluster. I recommend you keep the size of nodes at least 2 cores and over 7GB RAM.
![getting-started](https://raw.githubusercontent.com/cihanb/kubernetesdemo_rp/master/media/create-cluster.jpeg)

Note: it may take a few mins to create the cluster. Ensure the kubernetes cluster creation is complete before proceeding to the next step.

For best placement, we require Redis Enterprise Pack (Redis<sup>e</sup> Pack) pods to be placed on seperate kubernetes nodes. This ensures better availability when cluster nodes fail. Placing multiple Redis Enterprise Pack (Redis<sup>e</sup> Pack) nodes in the same physical host can cause multiple nodes to fail at once and may result in availability and data loss. To ensure we can garantee better placement, we need to upgrade the kubernetes cluster to **1.6.2** or better. You can do the upgrade in the details page of the kubernetes cluster deployment we just created. 

![getting-started](https://raw.githubusercontent.com/cihanb/kubernetesdemo_rp/master/media/view-cluster.jpeg)

Finally to finish the kubernetes deployment, you need to get the kubernetes console up and running and start the kubernetes proxy. on the terminal window, run the folowing commands;
```
gcloud auth login 
```
Connect to the kubernetes cluster
```
gcloud container clusters get-credentials cluster-1 --zone europe-west1-c --project speedy-lattice-166011
```
The output will read; 
_#Fetching cluster endpoint and auth data._
_#kubeconfig entry generated for cluster-1._
And finally start the kubernetes cluster
```
kubectl proxy
```


- Feed the .yaml file for the Redis Enterprise Pack provisioning
  > kubectl apply -f redis-enterprise.yaml
    > deployment "redispack-deployment" created
    > service "redispack" created
- Provision cluster
# list nodes
  > kubectl get po
NAME                                   READY     STATUS    RESTARTS   AGE
redispack-deployment-709212938-765lg   1/1       Running   0          7s
redispack-deployment-709212938-k8njr   1/1       Running   0          7s
redispack-deployment-709212938-kcjd7   1/1       Running   0          7s


#create cluster
#apply workaround - bind to 0.0.0.0
kubectl exec -it redispack-deployment-709212938-765lg -- bash
    > sudo su -
    > sed ‘s/bind 127.0.0.1/bind 0.0.0.0/g’ -i /opt/redislabs/config/ccs-redis.conf
    > cnm_ctl restart
  > kubectl exec -it redispack-deployment-709212938-765lg "/opt/redislabs/bin/rladmin" cluster create name cluster.local username cihan@redislabs.com password redislabs123 flash_enabled

#get node ip
  kubectl exec -it redispack-deployment-709212938-765lg ifconfig | grep "inet addr"

#add node#2
  kubectl exec -it redispack-deployment-709212938-k8njr bash
    > sudo su -
    > sed ‘s/bind 127.0.0.1/bind 0.0.0.0/g’ -i /opt/redislabs/config/ccs-redis.conf
    > cnm_ctl restart
  > kubectl exec -it redispack-deployment-709212938-k8njr "/opt/redislabs/bin/rladmin" cluster join username cihan@redislabs.com password redislabs123 nodes 10.0.2.10 flash_enabled

#add node#3
  kubectl exec -it redispack-deployment-709212938-kcjd7  bash
    > sudo su -
    > sed ‘s/bind 127.0.0.1/bind 0.0.0.0/g’ -i /opt/redislabs/config/ccs-redis.conf
    > cnm_ctl restart
  > kubectl exec -it redispack-deployment-709212938-kcjd7 "/opt/redislabs/bin/rladmin" cluster join username cihan@redislabs.com password redislabs123 nodes 10.0.2.10 flash_enabled

#create database
kubectl exec -it redispack-deployment-709212938-765lg bash
curl -k -u "cihan@redislabs.com:redislabs123" --request POST --url "https://localhost:9443/v1/bdbs" --header 'content-type: application/json' --data '{"name":"sample-db","type":"redis","memory_size":1073741824,"port":12000}'

#test connection
/opt/redislabs/bin/redis-cli -p 12000
127.0.0.1:12000> set a 1
OK
127.0.0.1:12000> get a
"1"
127.0.0.1:12000>









- Modify ```settings.sh``` to change default cluster settings
  - FQDN (full qualified domain name) ```rp_fqdn```, 
  - Cluster admin account and password ```rp_admin_account_name``` and ```rp_admin_account_password```
- Run ```create_cluster.sh``` to set up a cluster and create a sample database ```sample-db``` on port 12000
  - You can view the cluster by visiting ```https://locahost:8443``` 

- Connect to your database using ```redis-cli``` 
```
docker  exec -it <container name: default is rp1> bash
```
```
sudo /opt/redislabs/bin/redis-cli -p 12000
127.0.0.1:16653> set key1 123
OK
127.0.0.1:16653> get key1
“123”
```
Note: Use ```delete_cluster.sh``` to cleanup the sample.