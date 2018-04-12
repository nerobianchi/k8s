kubectl apply -f app-deployment.yaml -f app-service.yaml
kubectl apply -f ingress-namespace.yaml
kubectl apply -f default-backend-deployment.yaml -f default-backend-service.yaml -n=ingress
kubectl apply -f nginx-ingress-controller-config-map.yaml -n=ingress
kubectl apply -f nginx-ingress-controller-roles.yaml -n=ingress
kubectl apply -f nginx-ingress-controller-deployment.yaml -n=ingress
kubectl apply -f nginx-ingress.yaml -n=ingress
kubectl apply -f app-ingress.yaml
kubectl apply -f nginx-ingress-controller-service.yaml -n=ingress
VBoxManage modifyvm "worker_node_vm_name" --natpf1 "nodeport,tcp,127.0.0.1,30000,,30000"
VBoxManage modifyvm "worker_node_vm_name" --natpf1 "nodeport2,tcp,127.0.0.1,32000,,32000"
echo "127.0.0.1 test.akomljen.com" | sudo tee -a /etc/hosts

http://test.akomljen.com:31000/app1
http://test.akomljen.com:31000/app2
http://test.akomljen.com:32000/nginx_status

curl http://test.akomljen.com:31000/app1
curl http://test.akomljen.com:31000/app2
curl http://test.akomljen.com:32000/nginx_status
