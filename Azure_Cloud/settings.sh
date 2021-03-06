#!/bin/sh

# The MIT License (MIT)
#
# Copyright (c) 2018 Redis Labs
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Script Name: settings.sh
# Author: Cihan Biyikoglu - github:(cihanb)

#!/bin/sh	
	
# The MIT License (MIT)	
#	
# Copyright (c) 2015 Redis Labs	
#	
# Permission is hereby granted, free of charge, to any person obtaining a copy	
# of this software and associated documentation files (the "Software"), to deal	
# in the Software without restriction, including without limitation the rights	
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell	
# copies of the Software, and to permit persons to whom the Software is	
# furnished to do so, subject to the following conditions:	
# 	
# The above copyright notice and this permission notice shall be included in all	
# copies or substantial portions of the Software.	
# 	
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR	
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,	
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE	
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER	
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,	
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE	
# SOFTWARE.	
#	
# Script Name: my_private_settings.sh	
# Author: Cihan Biyikoglu - github:(cihanb)	
	
##rp settings	
#total nodes in cluster	
rp_total_nodes=3	
#rp docker image to use	
rp_image="redislabs/redis:latest"	
#default cluster name	
rp_fqdn="cluster1.local"	
#add a reference to the local rp license file if one exists in the form of a local file reference "~/path_to_rp_license_file.txt".	
rp_license_file=""	
#TODO: change this username	
rp_admin_account_name="<redis cluster admin email>"	
#TODO: change this password	
rp_admin_account_password="<admin password>"	
	
	
##azure settings	
resource_group_name="redis-aks-rg"	
aks_cluster_name="redis-aks"	
#TODO: use "azure login -u account" +  "azure account show" to get  account and subscriptionid	
azure_account="<azure account>"	
azure_subscription_id="<subscription ID>"	
#TODO: certs for ssh. use ssh-keygen to generate the keys - public and private	
vm_auth_cert_public="~/.ssh/id_rsa.pub"	
vm_auth_cert_private="~/.ssh/id_rsa"	
#prefix to use for the VM name for all nodes 	
vm_name_prefix="redis-"	
#vnet name to keeps azure vms in the same subnet - pick from "azure network vnet list"	
vnet_name="rpvnet" 	
#azure service name for all nodes	
service_name="redislabs-service"	
#region where to provision all nodes	
location="eastus"	
#number of data-disks to attach - check the max data-disk allowed on each SKU	
data_disk_count=0	
#size of the data-disk in GB max is 1023	
data_disk_size=1023	
	
	
##cluster settings	
#ubuntu OS image to use on azure	
rp_vm_image_name="Canonical:UbuntuServer:14.04.5-LTS:14.04.201802221"	
#cluster vm sku to use. Standard_D2 can be used as the minimum HW. 	
rp_vm_sku="Standard_D2_v2"	
#rp cluster vm admin account name	
rp_vm_admin_account_name="rl_vmadmin"	
	
#misc settings	
#this will enable removing the .ssh/known_hosts file under MacOS. The file gets in the way of reprovisioning the same node names for the cluster.	
remove_known_hosts=1	
#enable fast delete will supress confirmation on deletes of each VM. do this only if you are certain delete will not harm your existing VMs and you have tried the script multiple times.	
enable_fast_delete=1	
#enable fast restart will supress confirmation on restarts of each VM. do this only if you are certain restart will not harm your existing VMs and you have tried the script multiple times.	
enable_fast_restart=1	
#enable fast start will supress confirmation on start of each VM. do this only if you are certain start will not harm your existing VMs and you have tried the script multiple times.	
enable_fast_start=1	
#enable fast shutdown will supress confirmation on shutdowns of each VM. do this only if you are certain shutdown will not harm your existing VMs and you have tried the script multiple times.	
enable_fast_shutdown=1	
#print colors	
info_color="\033[1;32m"	
warning_color="\033[0;32m"	
error_color="\033[0;31m"	
no_color="\033[0m" 


