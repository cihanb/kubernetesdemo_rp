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

source ./my_private_settings.sh

# # login required
echo $info_color"INFO"$no_color": First we need to log you in."
az login -u $azure_account > /dev/null

# create resource group
echo $info_color"INFO"$no_color": Creating the resource group "$resource_group_name" in "$location
echo $info_color"INFO"$no_color": az group create --name $resource_group_name --location $location"
echo ""
az group create --name $resource_group_name --location $location > /dev/null

# create aks cluster
echo $info_color"INFO"$no_color": Creating the cluster "$aks_cluster_name
echo $info_color"INFO"$no_color": az aks create --resource-group $resource_group_name  --name $aks_cluster_name --node-count $rp_total_nodes --generate-ssh-keys"
echo ""
az aks create --resource-group $resource_group_name  --name $aks_cluster_name --node-count $rp_total_nodes --generate-ssh-keys --node-vm-size $rp_vm_sku

# get aks credentials
echo $info_color"INFO"$no_color": Save credentials"
echo $info_color"INFO"$no_color": az aks get-credentials --resource-group $resource_group_name --name $aks_cluster_name"
echo ""
az aks get-credentials --resource-group $resource_group_name --name $aks_cluster_name

# create public IP
echo $info_color"INFO"$no_color": create a public IP"
echo $info_color"INFO"$no_color": az network public-ip create --resource-group $rg --name redis-ip --allocation-method static"
echo ""
rg="MC_"$resource_group_name"_"$aks_cluster_name"_"$location
az network public-ip create --resource-group $rg --name redis-ip --allocation-method static
cmd="az network public-ip list --resource-group $rg --query [0].ipAddress --output tsv"
ip=$(eval $cmd)

# deploy redis enterpise
echo $info_color"INFO"$no_color": deploy redis enterprise"
echo $info_color"INFO"$no_color": kubectl create -f redis-enterprise.yaml"
echo ""
sed -e "s/\${ip}/$ip/" redis-enterprise.yaml | kubectl create -f -


echo "Get Started: Connect to your cluster at https://$ip:8443"
echo "For more details on how to administer Redi Enterprise, visit - https://redislabs.com/redis-enterprise-documentation/overview/"