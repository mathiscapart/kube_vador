apt install -y vim open-iscsi sudo curl nfs-common cryptsetup dmsetup jq # run to different server pods
curl -sfL https://get.k3s.io | sh -s - --disable=traefik --disable=servicelb
cat  /var/lib/rancher/k3s/server/node-token
cat /etc/rancher/k3s/k3s.yaml #change .kube/config

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
kubectl apply -f metallb/ippool.yml
kubectl apply -f metallb/l2adv.yml

kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/prerequisite/longhorn-iscsi-installation.yaml
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/prerequisite/longhorn-nfs-installation.yaml

kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/longhorn.yaml
kubens longhorn-system
kubectl apply -f longhorn/longhorn-ingress.yml
kubectl apply -f longhorn/secret-longhorn.yml

