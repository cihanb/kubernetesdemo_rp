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
az login -u $azure_account

# # create resource group
echo $info_color"INFO"$no_color": Creating the resource group "$resource_group_name" in "$location
az group create --name $resource_group_name --location $location

# # create aks cluster
echo $info_color"INFO"$no_color": Creating the cluster "$aks_cluster_name
az aks create --resource-group $resource_group_name  --name $aks_cluster_name --node-count $rp_total_nodes --generate-ssh-keys

# #get aks credentials
echo $info_color"INFO"$no_color": Save credentials"
az aks get-credentials --resource-group $resource_group_name --name $aks_cluster_name

# #create public IP
echo $info_color"INFO"$no_color": create a public IP"
rg="MC_"$resource_group_name"_"$aks_cluster_name"_"$location
az network public-ip create --resource-group $rg --name redis-ip --allocation-method static
cmd="az network public-ip list --resource-group $rg --query [0].ipAddress --output tsv"
ip=$(eval $cmd)

# #deploy redis enterpise
sed -e "s/\${ip}/$ip/" redis-enterprise.yaml | kubectl create -f -
