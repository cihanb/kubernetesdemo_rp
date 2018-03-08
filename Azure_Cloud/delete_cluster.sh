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

# login required
echo $info_color"INFO"$no_color": First we need to log you in."
az login -u $azure_account

# check if resource group exists already
exists=$az aks show -g $resource_group_name -n $aks_cluster_name --output table | grep $resource_group_name)
if [ "$exists" != '' ]
then
    az aks show -g $resource_group_name -n $aks_cluster_name --output table
    echo $warning_color"WARNING"$no_color": This will wipe out your AKS cluster nodes and delete all your data on containers [y/n]"
    read yes_no

    if [ $yes_no == 'y' ]
    then
        echo $warning_color"WARNING"$no_color": Deleting AKS cluster "$aks_cluster_name" and resource group "$resource_group_name
        # delete the resource group
        az group delete -g $resource_group_name -y 
    else
        echo $warning_color"WARNING"$no_color": Aborted deleting AKS cluster "$aks_cluster_name" and resource group "$resource_group_name
    fi
else
    echo $warning_color"WARNING"$no_color": No AKS cluster "$aks_cluster_name" under resource group "$resource_group_name
fi