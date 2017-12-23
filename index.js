# ############################
# Autor   : Luis Merino Troncoso
# Fecha   : 23/12/2017
# Version : 1.0
#
# Descripcion : index.js para ejemplo hello-word Kubernetes en nodeJS
#
#############################

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
