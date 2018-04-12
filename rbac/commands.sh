minikube start --extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
--extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key" \
--extra-config=apiserver.Authorization.Mode=RBAC \
--iso-url=https://storage.googleapis.com/minikube/iso/minikube-v0.25.1.iso



k create namespace lfs158
take rbac
openssl genrsa -out erdem.key 2048
openssl req -new -key erdem.key -out erdem.csr -subj "/CN=erdem/O=cloudyuga"\n
cat erdem.csr | base64 -
kaf signing-request.yaml
k get csr
k certificate approve erdem-csr
k get csr
k get csr erdem-csr -o jsonpath='{.status.certificate}' | base64 --decode > erdem.crt
k config set-credentials erdem --client-certificate=erdem.crt --client-key=erdem.key
kctx
k config set-context erdem-context --cluster=minikube --namespace=lfs158 --user=erdem
k config view
k run nginx --image=nginx:alpine -n lfs158
k --context erdem-context get pod
kaf role.yaml
kaf rolebindings.yaml
k --context erdem-context get pod