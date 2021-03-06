Kubernetes provides simple orchestration with containers and has been widely adapted. It is simple to get a Redis Enterprise cluster on kubernetes with the new Redis Enterprise Docker container. 

# What is Redis Enterprise?
Redis is the most popular database used with Docker containers. Redis Enterprise extends open source Redis and delivers stable high performance, linear scaling and high availability with significant operational savings. 

We will use the Docker container for 4.5 version of Redis Enterprise for the steps here. You can find more information on the container image on [Docker Hub](https://hub.docker.com/r/redislabs/redis/) and see details on how to deploy the container locally with Docker below:
* [Working with Redis Enterprise and Docker](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/)
* Getting Started with Redis Enterprise and [Docker on Windows](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/windows/), 
* Getting Started with Redis Enterprise and [Docker on Mac OSx](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/macos/), 
* Getting Started with Redis Enterprise and [Docker on Linux](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/linux/)

# Deploying Redis Enterprise with Kubernetes on Google Cloud 
We will go through 4 steps to set up our cluster with Redis Enterprise
* Step #1 - Create a kubernetes cluster on Google Cloud
* Step #2 - Deploy the Redis Enterprise containers to Kubernetes cluster
* Step #3 - Setup Redis Enterprise cluster
* Step #4 - Create a Redis database and test your connectivity

_Note: The deployment is deliberately simplified and is great for getting started with Kubernetes and Redis Enterprise fast. It certainly isn't intended for production use._

## Requirements
The steps below were performed using the latest [Google Cloud SDK](https://cloud.google.com/sdk/) on MacOS. There may be slight differences in detailed instructions with another operating system.

## Step #1 - Create a kubernetes cluster on Google Cloud
I'll assume you have gcloud and kubectl already installed. If you have not installed the tools, you can find detailed instructions on how to get these to your machine here:
* 
* 

Lets get you authenticated first;
```
gcloud auth login 
```

There are a few things to configure in your environment. 

Get the project_ID setup. You will get some random name like mine (`speedy-lattice-166011`) if you have not explicitly specified an ID
```
gcloud projects list
gcloud config set project speedy-lattice-166011
```

Get the geography where you want your cluster set up.
```
gcloud compute zones list
gcloud config set compute/zone us-central1-b
```

Create kubernetes cluster. I used n1-standard-2 nodes.
```
gcloud container clusters create redis-demo --num-nodes=3 -m n1-standard-2
```
For availability zone settings, it is also required to upgrade the cluster to 1.6.2.
```
gcloud container clusters upgrade redis-demo --master --cluster-version=1.6.2
```


Connect to the kubernetes cluster
```
gcloud container clusters get-credentials redis-demo --project speedy-lattice-166011
```
The output will read; 

_# Fetching cluster endpoint and auth data._
_# kubeconfig entry generated for redis-demo._

And finally start the kubernetes proxy
```
kubectl proxy
```

## Step #2 - Deploy the Redis Enterprise containers to Kubernetes cluster
You now need to feed the container yaml file to provision Redis Enterprise cluster. It is important to note that the container used for kubernetes is tuned for kubernetes used. It can be found under docker hub under redislabs/redis:kuber-4.5.0-18
```
kubectl apply -f redispack-headless.yaml
kubectl apply -f redispack-service.yaml
kubectl apply -f redispack-volumes.yaml
kubectl create -f redispack-deployment.yaml
```

You can now see the list of container nodes deployed on the kubernetes cluster. Simply run the following to see the list of nodes
```
kubectl get po
```

The output will look something like this;
```
NAME          READY     STATUS    RESTARTS   AGE
redispack-0   1/1       Running   0          3m
redispack-1   1/1       Running   0          2m
```


---------------- IN PROGRESS BELOW -----------------------------------------------------------------------
## Step #3 - Setup Redis Enterprise cluster
We are now ready to create the Redis Enterprise cluster. 

With this, let's provision the first node or the Redis Enterprise cluster.
```
kubectl exec -it redispack-0 "/opt/redislabs/bin/rladmin" cluster create name cluster.local username cihan@redislabs.com password redislabs123 flash_enabled
```

We will need the ip address of the first node to be able to instruct the following nodes to join the cluster.
```
kubectl exec -it redispack-0 ifconfig | grep "inet addr"
```
In my case the output was 10.0.2.10.
Lets add node 2 and 3 to the cluster 
```
kubectl exec -it redispack-1 "/opt/redislabs/bin/rladmin" cluster join username cihan@redislabs.com password redislabs123 nodes 10.0.2.10 flash_enabled
```


## Step #4 - Create a Redis database and test your connectivity
We are now ready to create the database and connect to it. The following curl command can be used to create a database on port 12000. the database will be named _sample-db_.
```
kubectl exec -it redispack-deployment-709212938-765lg bash
# curl -k -u "cihan@redislabs.com:redislabs123" --request POST --url "https://localhost:9443/v1/bdbs" --header 'content-type: application/json' --data '{"name":"sample-db","type":"redis","memory_size":1073741824,"port":12000}'
```

To test the connection to the database, we will use the _redis-cli_ tool. Here is a simple set followed by a get to validate the redis deployment.
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
* [Working with Redis Enterprise and Docker](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/)
* Getting Started with Redis Enterprise and [Docker on Windows](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/windows/), 
* Getting Started with Redis Enterprise and [Docker on Mac OSx](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/macos/), 
* Getting Started with Redis Enterprise and [Docker on Linux](https://redislabs.com/redis-enterprise-documentation/installing-and-upgrading/docker/linux/)
* [Setting up a Redis Enterprise Cluster](https://redislabs.com/redis-enterprise-documentation/initial-setup-creating-a-new-cluster/)
* [Documentation](https://redislabs.com/resources/redis-pack-documentation/)
* [How To Guides](https://redislabs.com/resources/how-to-redis-enterprise/)