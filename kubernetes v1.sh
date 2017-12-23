############################
# Autor   : Luis Merino Troncoso
# Fecha   : 02/12/2017
# Version : 1.0
#
# Descripcion : kubernetes  - sentencias instalacion y  ejemplo
#
#############################

minikube start

# pode de ejemplo para probar la instalacion

kubectl run hello-minikube --image=gcr.io/google_containers/echoserver:1.4 --port=8080

kubectl expose deployment hello-minikube --type=NodePort

# hacemos curl para conseguir los metadatos del pod
curl $(minikube service hello-minikube --url)

#borramos el deployment que acabammos de crear para la prueba
kubectl delete deployment hello-minikube

# consultamos la sitacion de los replication cntrollers qu se encargan de tener siempre la
# aplicacion activa y funcionado

kubectl get rc redis -o yaml

# podemos escalar el numero de replicas en tiempo real

kubectl scale rc redis --replica=5

# ACtualmnete se ha creado una nueva entidad, que se llama deployments
# aunque se sigue considerando extension
# deberiamos usaer en vez de replication controllers

kubectl run nginx --image=niginx
kubectl get deployments,pods
kubectl get nodes

systemctl status kubelet

kubectl get pods --all--namespaces

kubectl apply -f https://git.io/weave-kube-1.6


#######################################################################
# instalacion cluster kubernetes
######################################################################3
# para descargarse de gcloud . kubectl y demas
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# deshabilitar swap en todas las maquinas

swapoff -a
# comprobar uuid y mac adreess en todas las maquinas. tienen que ser diferentes

sudo cat /sys/class/dmi/id/product_uuid
ip link or ifconfig -a

# instalacion docker en todas las maquinas

apt-get update
apt-get install -y docker.io

# teniendo especial cuidado en que el cgroup sea el mismo
# es decir --cgroup-driver kubelet flag tiene que tener el mismo valor  que docker es decir cgroupfs

cat << EOF > /etc/docker/daemon.json
{
	"exec-opts" : ["native.cgroupdriver=systemd"]
}
EOF

# curl - comprobar que este instalado en las maquinas
# modificar el KUBELET_CGROUP_ARGS si no coincide con el de docker
vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd"

systemctl daemon-reload
service kubelet restart



apt-get install curl

# Instalacion de kubeadm kubelet kubectl

apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

# en el master node ejecutamos kubeadm

kubeadm init

# Hay que ejecutar esto desde un usuario no root
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

# despues en los nodos hay que añadirlos al cluster

# para volver a sacar el token

kubeadm token create --print-join-command

You can now join any number of machines by running the following on each node
as root:

 kubeadm join --token 59f01a.d6142d346464c960 10.0.1.4:6443 --discovery-token-ca-cert-hash sha256:b83ffee4d5e20961fb1de396665257d06e3154c2305178a3ea03a92bf76a02c0
kubeadm join --token de5440.5aa9dbad9a0fab20 192.168.1.109:6443 --discovery-token-ca-cert-hash sha256:8096a19ca633ce9512e7ad06c51faba6bb9f5382d418eda3dcc68edf6bafeb60

# para drenar un nodo para reseteralo y volver a hacer join
https://kubernetes.io/docs/reference/kubectl/cheatsheet/

kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>

kubeadm join
# Hay que instalar la pod network para poder comunicar los pods entre ellos y tener mas seguridad
# lo primero este requerimiento para la mayoria de las cni

sudo sysctl net.bridge.bridge-nf-call-iptables=1

# Kubeadm solo soporta redes cni y la que vamos a instalar es la de weavenet
# desde el usuario que ejecutamos antes no root

export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"

#comprobar que esta levantado el pod

kubectl get pods --all-namespaces

# deployment del dashboard

kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

# Creacion de un pod de pruebas

 kubectl create -f https://k8s.io/docs/tasks/access-application-cluster/redis-master.yaml

 kubectl run ghost --image=ghost

 # exponer laapp via un servicio

 $ kubectl expose deployment/ghost --port=2368 --type=NodePort

# ejecutar un contenedor dentrp de un pod
# crear un fichero en el volumen

kubectl exec -ti vol -c box -- touch /box/foobar

# ejecutar ls en el otro contenedor y ver que
# el volumen con el fichero es visible en los docs

kubectl exec -ti vol -c busy -- ls -l /busy

PersistentVolume and PersistentVolumeClaim

A PersistentVolume (PV) is a piece of storage in the cluster
that has been provisioned by an administrator

A PersistentVolumeClaim (PVC) is a request for storage by a user.
 It is similar to a pod. P

Cluster administrators need to be able to offer a
variety of PersistentVolumes that differ in more ways than
just size and access modes
For these needs there is the StorageClass resource

PersistentVolume types are implemented as plugins. Kubernetes currently supports the following plugins:

GCEPersistentDisk
AWSElasticBlockStore
AzureFile
AzureDisk
FC (Fibre Channel)
FlexVolume
Flocker
NFS
iSCSI
RBD (Ceph Block Device)
CephFS
Cinder (OpenStack block storage)
Glusterfs
VsphereVolume
Quobyte Volumes
HostPath (Single node testing only – local storage is not supported in any way and WILL NOT WORK in a multi-node cluster)
VMware Photon
Portworx Volumes
ScaleIO Volumes
StorageOS
# volumenes PersistentVolume y PersistentVolumeClaim
kubectl get Pv
kubectl get PVC

# creacion de secrets para informacion sensible
# puede ser encrptada o controller
kubectl get secrets
kubectl create secret generic --help
kubectl create secret generic mysql --from-literal=password=root
kubectl create secret generic my-secret --from-file=path/to/bar

# crecion del tipo volumen configmap para el pod

 kubectl create configmap map --from-file=configmap.md
#conexion contenedor mysql dentro del pod mysql
# con secret del usuario que creamos antes
kubectl exec -ti mysql -- mysql -uroot -p

##################
# api extensions
#############
Horizontal pod autoextension con heapster autoextension

curl localhost:8080/apis/autoscaling/v1

# monitorizacion y visualizacion
# influxdb y grafana
desplegar estos :
grafana.yaml , heapster.yaml, influxdb.yaml

# cargar pod apache
kubectl run php-apache --image=gcr.io/google_containers/hpa-example --requests=cpu=200m --expose --port=80

# desplegamos el autoscaler
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

# generamos carga de trabajo
kubectl run -i --tty load-generator --image=busybox /bin/sh

Hit enter for command prompt

while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done
