# install tools
yum install -y git
yum install -y openssl

yum install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source /etc/profile.d/bash_completion.sh


git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
ln -s /opt/kubectx/kubectx /usr/local/bin/kctx
ln -s /opt/kubectx/kubens /usr/local/bin/kns

curl -o ~/.kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases
source ~/.kubectl_aliases

#install k8s
kubeadm init --apiserver-advertise-address $(hostname -i)
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -n kube-system -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 |tr -d '\n')"


--

hash=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
token=$(kubeadm token list | sed -n '2,3p' | awk '{print $1}')
join_command="kubeadm join --token $token $(hostname -i):6443 --discovery-token-ca-cert-hash sha256:$hash"
echo $join_command


watch kubectl get node
watch kubectl get pod --all-namespaces -o wide

kubectl run my-nginx --image=nginx --replicas=2 --port=80
kubectl expose deployment my-nginx --port=80 --type=LoadBalancer
kubectl expose deployment my-nginx --port=80 --type=NodePort
kubectl expose deployment my-nginx --port=80 --target-port=8000

kubectl delete svc my-nginx
kubectl delete deployment my-nginx


-------------nginx---------
git clone https://github.com/nginxinc/kubernetes-ingress.git
cd kubernetes-ingress

cd install
kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml
kubectl apply -f rbac/rbac.yaml
kubectl apply -f daemon-set/nginx-ingress.yaml
kubectl apply -f service/nodeport.yaml #nodePort should be added
watch kubectl get pods --namespace=nginx-ingress


k get ns
k get ServiceAccount -n nginx-ingress
k get Secret -n nginx-ingress
k get DaemonSet -n nginx-ingress
k get ClusterRole -n nginx-ingress
k get ClusterRoleBinding -n nginx-ingress
k get ConfigMap -n nginx-ingress
k get Service -n nginx-ingress

cd ../examples/complete-example

IC_IP=192.168.58.228
kubectl apply -f cafe.yaml
kubectl apply -f cafe-secret.yaml
kubectl apply -f cafe-ingress.yaml
curl --resolve cafe.example.com:443:$IC_IP https://cafe.example.com/coffee --insecure


#directly from github
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/install/common/ns-and-sa.yaml
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/install/common/default-server-secret.yaml
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/install/common/nginx-config.yaml
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/install/rbac/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/install/daemon-set/nginx-ingress.yaml
watch kubectl get pods --namespace=nginx-ingress

IC_IP=192.168.58.228
IC_IP=192.168.99.100

#https
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/examples/complete-example/cafe.yaml
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/examples/complete-example/cafe-secret.yaml
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/examples/complete-example/cafe-ingress.yaml
curl --resolve cafe.example.com:443:$IC_IP https://cafe.example.com/coffee --insecure

#http

kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/examples/complete-example/cafe.yaml
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/master/examples/complete-example/cafe-secret.yaml
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: cafe-ingress
spec:
  rules:
  - host: cafe.example.com
    http:
      paths:
      - path: /tea
        backend:
          serviceName: tea-svc
          servicePort: 80
      - path: /coffee
        backend:
          serviceName: coffee-svc
          servicePort: 80
EOF

curl --resolve cafe.example.com:80:$IC_IP http://cafe.example.com/coffee
curl http://cafe.example.com/coffee



curl --resolve cafe.example.com:80:$IC_IP http://cafe.example.com/coffee



#clean up
kubectl delete all --all
k delete ns ingress
k delete ingress --all
k delete secret cafe-secret
k delete secret mysecret

k delete clusterrolebinding nginx-ingress
k delete clusterrolebinding nginx-role