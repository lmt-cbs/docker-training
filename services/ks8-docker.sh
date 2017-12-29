############################
# Autor   : Luis Merino Troncoso
# Fecha   : 02/12/2017
# Version : 1.0
#
# Descripcion : kubernetes  - contenedores docker en kubernetes
#
#############################

#Los contenedores son la base se kubernetes y vamos a hacer  varios ejercicios para comprender bien como
# crear uno , crear una pequeña plocacion en node js y ejecutar dicha aplicacion dentro  del contenedor.
# se puede bajar de :
windows
  https://docs.docker.com/engine/installation/windows
MacOS
  https://docs.docker.com/engine/installation/mac
windows
  https://docs.docker.com/engine/installation/linux

# Elementos de docker para los primeros pasos , vamos a dockerizar una pequeña app en nodeJS
# primero
Dockerfile:
--------------
FROM node:4.6
WORKDIR /app
ADD ./app
RUN npm install
EXPOSE 3000
CMD npm start
---------------

index.js
---------------
var express = require("express");
var app = express();

app.get('/',function (req, res){
  res.send('Hola Mundo!');
});

var server = app.listen(3000, function (){
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening at http://%s:%s', host,port);
});
------------------

package.json
-------------------
{
  "name":"myapp",
  "version":"0.0.1"
  "private":true,
  "scripts": {
    "start":"node index.js"
  },
  "engines": {
    "node":"^4.6.1"
  },
  "dependencies":{
    "express":"^4.14.0"
  }
}

# Docker permite especificar diferentes tipos de redes para sus contenedores. Un tipo que es muy
# práctico y utilizado en Kubernetes es el container type. Permite compartir una red entre dos
# contenedores. En este ejercicio, ilustrará esto con tres comandos bash:

docker run -d --name=source busybox sleep 3600
docker run -d --name=same-ip --net=container:source busybox sleep 3600

## check the IP address of each container, something like the following should do:

docker exec -ti same-ip ifconfig

# Esto es lo que hace que un Kubernetes POD, un conjunto de contenedores que se ejecutan en el mismo host y
# que comparten el mismo espacio de nombre de red. Esto es lo que Kubernetes llama el modelo único de
# IP-per-Pod: hacer a Pod casi parece una máquina virtual que ejecuta múltiples procesos con una sola dirección IP.

# el primer nodo principal de Kubernetes
# En este ejercicio, creará el comienzo de un clúster de Kubernetes en su host Docker local.
# usar imágenes Docker para ejecutar etcd, el servidor API y el administrador del controlador.
docker run -d --name=k8s -p 8080:8080 gcr.io/google_containers/etcd:3.1.10 etcd --data-dir /var/lib/data

docker run -d --net=container:k8s gcr.io/google_containers/hyperkube:v1.7.6 /apiserver --etcd-servers=http://127.0.0.1:2379 --service-cluster-ip-range=10.0.0.1/24 --insecure-bind-address=0.0.0.0 --insecure-port=8080 --admission-control=AlwaysAdmit

# Para cambiar entre contextos
kubectl config use-context foobar

# Finalmente, puede iniciar el controlador de Admisión, que apunta al servidor API.
docker run -d --net=container:k8s gcr.io/google_containers/hyperkube:v1.7.6 /controller-manager --master=127.0.0.1:8080
