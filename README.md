# Step by Step Deployment for Redis Enterprise Pack (Redis<sup>e</sup> Pack) on Kubernetes on Google Cloud 

Here is a simple step by step cluster deployment for a Redis Enterprise Pack (Redis<sup>e</sup> Pack) on Kubernetes using Google Cloud.  

## Requirements
- MacOS Sierra
- Google Cloud SDK - https://cloud.google.com/sdk/

## Getting Started
- Create a Kubernetes Cluster on Google Cloud (see pict)
  #note: upgrade the master cluster version to version 1.6.2
  #authenticate to the cluster
  - gcloud auth login 
  - Connect to the cluster 
  > gcloud container clusters get-credentials cluster-1 --zone europe-west1-c --project speedy-lattice-166011
    > Fetching cluster endpoint and auth data.
    > kubeconfig entry generated for cluster-1.
  - start the proxy
  > kubectl proxy
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