#!/bin/bash
set -o errexit  # exit if some command fails
set -o nounset  # check if all variables are fill
set -o pipefail # exit if some command in pipe fails
set -o xtrace   # print all executed commands

# Get variables
EMAIL="${1}"

export resourceGroup="jenkins-runner-rg"
export aksIdentity="aks-identity"
export aksName="aks-jenkins-runner"
export kubeletIdentity="kubelet-identity"
export acrName="jenkinsacr$RANDOM"

az group create --name $resourceGroup --location eastus

export aksIdentityId=$(az identity create --name $aksIdentity --resource-group $resourceGroup --query id --output tsv)
export kubeletIdentityId=$(az identity create --name $kubeletIdentity --resource-group $resourceGroup --query id --output tsv)
export kubeletIdentityClientId=$(az identity show --name $kubeletIdentity --resource-group $resourceGroup --query clientId --output tsv)

export groupId=$(az ad group create --display-name "AKSADMINS" --mail-nickname "AKSADMINS" --query id -o tsv)

export userId=$(az ad user show --id ${EMAIL} --query id -o tsv)

export acrId=$(az acr create --name $acrName --resource-group $resourceGroup --sku Basic --query id -o tsv)

az ad group member add --group $groupId --member-id $userId

az aks create \
--resource-group $resourceGroup \
--name $aksName \
--location eastus \
--assign-identity $aksIdentityId \
--assign-kubelet-identity $kubeletIdentityId \
--enable-managed-identity \
--enable-aad \
--aad-admin-group-object-ids $groupId \
--attach-acr $acrId \
--node-count 2 \
--node-vm-size "Standard_B8ms" \
--kubernetes-version 1.24.6
zsh