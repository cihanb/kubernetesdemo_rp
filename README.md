Kubernetes provides simple orchestration with containers and has been widely adapted. It is simple to get a Redis Enterprise Pack (Redis<sup>e</sup> Pack) cluster on kubernetes with the new Redis Enterprise Pack Docker container. 

# What is Redis Enterprise Pack?
Redis is the most popular database used with Docker containers. Redis Enterprise Pack extends open source Redis and delivers stable high performance, linear scaling and high availability with significant operational savings.

We will use the Docker container for 4.5 version of Redis Enterprise Pack (Redis<sup>e</sup> Pack) for the steps here. You can find more information on the container image on [Docker Hub](https://hub.docker.com/r/redislabs/redis/) and see details on how to deploy the container locally with Docker below:
* [Working with Redis Enterprise Pack and Docker](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/)
* Getting Started with Redis Enterprise Pack and [Docker on Windows](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/windows/), 
* Getting Started with Redis Enterprise Pack and [Docker on Mac OSx](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/macos/), 
* Getting Started with Redis Enterprise Pack and [Docker on Linux](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/linux/)



# Deploying (Redis<sup>e</sup> Pack) with Kubernetes on Google Cloud 
We will go through 4 steps to set up our cluster with Redis Enterprise Pack (Redis<sup>e</sup> Pack)
* Step #1 - Create a kubernetes cluster on Google Cloud
* Step #2 - Deploy the Redis Enterprise Pack (Redis<sup>e</sup> Pack) containers to Kubernetes cluster
* Step #3 - Setup Redis Enterprise Pack (Redis<sup>e</sup> Pack) cluster
* Step #4 - Create a Redis database and test your connectivity

## Requirements
When performing the steps, I used latest Google Cloud SDK - https://cloud.google.com/sdk/ on MacOS. There may be slight differences with other operating systems.

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
_# Fetching cluster endpoint and auth data._
_# kubeconfig entry generated for cluster-1._
And finally start the kubernetes cluster
```
kubectl proxy
```
## Step #2 - Deploy the Redis Enterprise Pack (Redis<sup>e</sup> Pack) containers to Kubernetes cluster
You now need to feed the container yaml file to provision Redis Enterprise Pack (Redis<sup>e</sup> Pack) cluster
```
kubectl apply -f redis-enterprise.yaml
```
If the deployment is successful, the output should look like this;
_# deployment "redispack-deployment" created_
_# service "redispack" created_

You can now see the list of container nodes deployed on the kubernetes cluster. Simply run the following to see the list of nodes
```
kubectl get po
```
The output will look something like this;
```
NAME                                   READY     STATUS    RESTARTS   AGE
redispack-deployment-709212938-765lg   1/1       Running   0          7s
redispack-deployment-709212938-k8njr   1/1       Running   0          7s
redispack-deployment-709212938-kcjd7   1/1       Running   0          7s
```

## Step #3 - Setup Redis Enterprise Pack (Redis<sup>e</sup> Pack) cluster
We are now ready to create the Redis Enterprise Pack (Redis<sup>e</sup> Pack) cluster. There is one small change that needs to be done to the container to get networking to work properly: we need to change the css binding to 0.0.0.0. To do this you ned to run the following in each container with each iteration using the pods name from the _kubectl get po_ output above.
```
kubectl exec -it redispack-deployment-709212938-765lg -- bash
# sudo su -
# sed ‘s/bind 127.0.0.1/bind 0.0.0.0/g’ -i /opt/redislabs/config/ccs-redis.conf
# cnm_ctl restart
```

With this, lets provision the first node or the Redis Enterprise Pack (Redis<sup>e</sup> Pack) cluster.
```
kubectl exec -it redispack-deployment-709212938-765lg "/opt/redislabs/bin/rladmin" cluster create name cluster.local username cihan@redislabs.com password redislabs123 flash_enabled
```

We will need the ip address of the first node to be able to instruct the following nodes to join the cluster.
```
kubectl exec -it redispack-deployment-709212938-765lg ifconfig | grep "inet addr"
```
In my case the output was 10.0.2.10.
Lets add node 2 and 3 to the cluster 
```
kubectl exec -it redispack-deployment-709212938-k8njr "/opt/redislabs/bin/rladmin" cluster join username cihan@redislabs.com password redislabs123 nodes 10.0.2.10 flash_enabled
```
```
kubectl exec -it redispack-deployment-709212938-kcjd7 "/opt/redislabs/bin/rladmin" cluster join username cihan@redislabs.com password redislabs123 nodes 10.0.2.10 flash_enabled
```

## Step #4 - Create a Redis database and test your connectivity
We are now ready to create the database and connect to it. The following curl command can be used to create a database on port 12000. the database will be named _sample-db_.
```
kubectl exec -it redispack-deployment-709212938-765lg bash
# curl -k -u "cihan@redislabs.com:redislabs123" --request POST --url "https://localhost:9443/v1/bdbs" --header 'content-type: application/json' --data '{"name":"sample-db","type":"redis","memory_size":1073741824,"port":12000}'
```

To test the connection to the database, we will use the _redis-cli_ tool. Here is a simple set folowed by a get to validate the redis deployment.
```
kubectl exec -it redispack-deployment-709212938-765lg bash
# /opt/redislabs/bin/redis-cli -p 12000
# 127.0.0.1:12000> set a 1
# OK
# 127.0.0.1:12000> get a
# "1"
# 127.0.0.1:12000>
```

## Quick Links ##
* [Working with Redis Enterprise Pack and Docker](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/)
* Getting Started with Redis Enterprise Pack and [Docker on Windows](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/windows/), 
* Getting Started with Redis Enterprise Pack and [Docker on Mac OSx](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/macos/), 
* Getting Started with Redis Enterprise Pack and [Docker on Linux](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/linux/)
* [Setting up a Redis Enterprise Pack Cluster](https://redislabs.com/redis-enterprise-documentation/initial-setup-creating-a-new-cluster/)
* [Documentation](https://redislabs.com/resources/redis-pack-documentation/)
* [How To Guides](https://redislabs.com/resources/how-to-redis-enterprise/)