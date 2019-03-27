#!/bin/bash
export WORKDIR=/home/centos/TensorFlow
cd  ${WORKDIR}
#2)
#export KUBECONFIG=/etc/kubernetes/admin.conf
NAMESPACE=ds-platform
kubectl delete namespace ${NAMESPACE}
kubectl create namespace ${NAMESPACE}
#3) install ksonnet
export KS_VER=0.13.1
export KS_PKG=ks_${KS_VER}_linux_amd64
wget -O /tmp/${KS_PKG}.tar.gz https://github.com/ksonnet/ksonnet/releases/download/v${KS_VER}/${KS_PKG}.tar.gz --no-check-certificate
mkdir -p ${HOME}/bin
tar -xvf /tmp/$KS_PKG.tar.gz -C ${HOME}/bin
export PATH=$PATH:${HOME}/bin/$KS_PKG
#4) install & init  kubeflow
export KUBEFLOW_SRC=${WORKDIR}/kubeflow
rm -R ${KUBEFLOW_SRC}
#git clone https://github.com/kubeflow/kubeflow.git
APP_NAME=ds-kubeflow
rm -R ${APP_NAME}
ks init ${APP_NAME}
cd ${APP_NAME}
ks env set default --namespace ${NAMESPACE}
export GITHUB_TOKEN=98281cf26249ae6b6320186267e308f2b04634c9
ks registry add kubeflow github.com/kubeflow/kubeflow/tree/master/kubeflow
#ks pkg install kubeflow/core
#in newer version use common instead of core
ks pkg install kubeflow/common
ks pkg install kubeflow/tf-training
ks pkg install kubeflow/tf-serving
ks generate tf-job-operator tf-job-operator
ks apply default -c tf-job-operator