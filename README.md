# KUBERNETES_FAN_VADOR

## Introduction

### Qu'est-ce que k3s ? 

K3s est une distribution de Kubernetes proposée par Rancher qui vise à permettre une intégration de Kubernetes sur des systèmes contraints (ressources limitées, isolées …).

Ce projet déploie un cluster **K3s** avec les applications suivantes :
- **WordPress** : vador-fans.lan (avec un accès restreint à `/wp-admin`)
- **PrestaShop** : vador-fans.lan/eshop
- **phpMyAdmin** : pma.vador-fans.lan (sécurisé)

Le cluster Kubernetes repose sur les composants suivants :
- **Stockage distribué** : Longhorn
- **Load Balancer** : MetalLB
- **Ingress Controller** : Nginx

---

## Prérequis

### Infrastructure
- **3 nœuds sous Linux** voici une configuration pour petre confortable lors des déploiements :
  - 6 Go de RAM
  - 4 CPU
  - 100 Go de stockage

## Schéma 
Schéma disponible sur Draw.IO :

![Texte remplacement](schema_projet.drawio.png)

## Versions :

- Kubernetes :
  - Client Version: v1.31.5+k3s1 
  - Kustomize Version: v5.4.2 
  - Server Version: v1.31.5+k3s1
- MetalLb : 0.14.9
- LongHorn : 1.7.2
- Ingress Nginx : 1.12.0
- WordPress : 6.2.1-apache
- MariaDb : 10.7.8
- Prestashop : 8
- phpMyAdmin : 5.2.1-apache
- Redict : 7.3

### Installation
1. Exécuter le script `deployment_kube.sh` sur le **nœud master**.
2. Exécuter le script `deployment_node.sh` sur chaque **nœud worker**.
3. Adapter les valeurs d'adresse IP et de `K3S_TOKEN` selon votre infrastructure.
4. Attention changer les secrets !! Configurez vos secrets.yml en utilisant `echo -n 'exemple | base64`, placez le base64 dans la variable.
   
   Pour récupérer votre `K3S_TOKEN` sur le master :
   ```sh
   cat /var/lib/rancher/k3s/server/node-token
   ```

---

## Applications

### 1. Redict (Fork open-source de Redis)
**Redict** (Remote Dictionary Server) est une base de données NoSQL en mémoire, utilisée principalement pour le cache applicatif.

#### Déploiement
1. Aller dans le dossier `cache` :
   ```sh
   cd cache
   ```
2. Créer le namespace `cache` :
   ```sh
   kubectl create ns cache
   ```
3. Déployer le `deployment` et le `service` :
   ```sh
   kubectl apply -f deployment.yml
   kubectl apply -f service.yml
   ```

---

### 2. WordPress
WordPress est un CMS open-source largement utilisé pour la création de sites internet.

#### Déploiement
1. Aller dans le dossier `wordpress` :
   ```sh
   cd ../wordpress
   ```
2. Créer le namespace `wordpress` :
   ```sh
   kubectl create ns wordpress
   ```
3. Déployer la base de données MariaDB :
   ```sh
   kubectl apply -f mariaDb/pvc.yml
   kubectl apply -f mariaDb/secret.yml
   kubectl apply -f mariaDb/service.yml
   kubectl apply -f mariaDb/deployment.yml
   ```
4. Déployer WordPress :
   ```sh
   kubectl apply -f pvc.yml
   kubectl apply -f secret.yml
   kubectl apply -f secret-wp-admin.yml
   kubectl apply -f service.yml
   kubectl apply -f deployment.yml
   kubectl apply -f ingress.yml
   kubectl apply -f ingress-wp-admin.yml
   ```

---

### 3. PrestaShop
PrestaShop est une solution e-commerce open-source permettant de créer et gérer une boutique en ligne.

#### Déploiement
1. Aller dans le dossier `prestashop` :
   ```sh
   cd ../prestashop
   ```
2. Créer le namespace `prestashop` :
   ```sh
   kubectl create ns prestashop
   ```
3. Déployer la base de données MariaDB :
   ```sh
   kubectl apply -f mariaDb/pvc.yml
   kubectl apply -f mariaDb/secret.yml
   kubectl apply -f mariaDb/service.yml
   kubectl apply -f mariaDb/deployment.yml
   ```
4. Déployer PrestaShop :
   ```sh
   kubectl apply -f pvc.yml
   kubectl apply -f secret.yml
   kubectl apply -f service.yml
   kubectl apply -f deployment.yml
   kubectl apply -f ingress.yml
   ```

---

### 4. phpMyAdmin
phpMyAdmin est une application open-source permettant la gestion des bases de données MySQL/MariaDB via une interface web.

#### Déploiement
1. Aller dans le dossier `phpmyadmin` :
   ```sh
   cd ../phpmyadmin
   ```
2. Créer le namespace `phpmyadmin` :
   ```sh
   kubectl create ns phpmyadmin
   ```
3. Déployer phpMyAdmin :
   ```sh
   kubectl apply -f secret.yml
   kubectl apply -f service.yml
   kubectl apply -f deployment.yml
   kubectl apply -f ingress.yml
   ```

---

## Monitoring

Nous monitorons nos volumes, mais aussi le site web avec BlackBox. Nous allons déployer un Prometheus et un Grafana

##  Prometheus

Prometheus est un outil open-source de surveillance et d'alerte de systèmes open source initialement conçue sur SoundCloud.

### Déploiement
1. Aller dans le dossier `prometheus` :
   ```sh
   cd ../monitoring/prometheus
   ```
2. Créer le namespace `monitoring` :
   ```sh
   kubectl create ns monitoring
   ```
3. Déployer Prometheus :
   ```sh
   helm upgrade --install prometheus prometheus-community/prometheus -f values.yml -n monitoring
   ```
   
## Grafana
   
Grafana est une plateforme de visualisation de données interactive Open Source développée par Grafana Labs.

### Déploiement

1. Aller dans le dossier `grafana` :
   ```sh
   cd ../grafana
   ```
3. Déployer Grafana :
   ```sh
   helm upgrade --install grafana grafana/grafana -f values.yml -n monitoring
   ```
   
Une fois déployés, accédez à :

- prometheus.vador-fans.lan (vérifier les cibles dans l'onglet Targets)
- grafana.vador-fans.lan (importer les dashboards BlackBox `7587` et Longhorn `16888`, avec Prometheus comme DataSource)

---

## Vérification 

Une fois toutes les applications déployées, exécutez la commande `kubectl get pods -A` 

Vous devriez avoir quelque chose qui ressemble à ça :
```sh
NAMESPACE         NAME                                                             READY   STATUS             RESTARTS         AGE
cache             cache-7bc4cc97fc-cwmqk                                           1/1     Running            1 (24h ago)      2d2h
ingress-nginx     ingress-nginx-controller-65d47ff7f5-jf6qg                        1/1     Running            10 (24h ago)     3d10h
kube-system       coredns-ccb96694c-52j65                                          1/1     Running            1 (24h ago)      2d2h
kube-system       local-path-provisioner-5cf85fd84d-qq5q8                          1/1     Running            4 (24h ago)      3d10h
kube-system       metrics-server-5985cbc9d7-82xc6                                  1/1     Running            7 (24h ago)      3d10h
longhorn-system   csi-attacher-565dc55c47-42gb2                                    1/1     Running            1 (24h ago)      2d2h
longhorn-system   csi-attacher-565dc55c47-58nj6                                    1/1     Running            13 (24h ago)     3d10h
longhorn-system   csi-attacher-565dc55c47-xgd56                                    1/1     Running            1 (24h ago)      2d2h
longhorn-system   csi-provisioner-77f995b56c-52wht                                 1/1     Running            13 (24h ago)     3d10h
longhorn-system   csi-provisioner-77f995b56c-q2rbh                                 1/1     Running            1 (24h ago)      2d2h
longhorn-system   csi-provisioner-77f995b56c-r4qs8                                 1/1     Running            1 (24h ago)      2d2h
longhorn-system   csi-resizer-8677f4c959-6f4xm                                     1/1     Running            1 (24h ago)      2d2h
longhorn-system   csi-resizer-8677f4c959-gwqz4                                     1/1     Running            1 (24h ago)      2d2h
longhorn-system   csi-resizer-8677f4c959-wq4q9                                     1/1     Running            13 (24h ago)     3d10h
longhorn-system   csi-snapshotter-6d96ddbf4-4gvnc                                  1/1     Running            1 (24h ago)      2d2h
longhorn-system   csi-snapshotter-6d96ddbf4-8q9jk                                  1/1     Running            12 (24h ago)     3d10h
longhorn-system   csi-snapshotter-6d96ddbf4-9m5z5                                  1/1     Running            1 (24h ago)      2d2h
longhorn-system   engine-image-ei-51cc7b9c-4cbt4                                   1/1     Running            19 (24h ago)     11d
longhorn-system   engine-image-ei-51cc7b9c-hb82n                                   1/1     Running            12 (24h ago)     10d
longhorn-system   engine-image-ei-51cc7b9c-ng86l                                   1/1     Running            18 (24h ago)     11d
longhorn-system   instance-manager-09fbe318f6d84cf1db0945e5eed3a242                1/1     Running            0                24h
longhorn-system   instance-manager-2fbf15e7b8f426bf9730aa6cb98b2d93                1/1     Running            0                24h
longhorn-system   instance-manager-aa0ad7b00229df6920eba104e52a078e                1/1     Running            0                24h
longhorn-system   longhorn-csi-plugin-hnbhp                                        3/3     Running            83 (24h ago)     10d
longhorn-system   longhorn-csi-plugin-jp6rp                                        3/3     Running            98 (24h ago)     10d
longhorn-system   longhorn-csi-plugin-zpt49                                        3/3     Running            73 (24h ago)     10d
longhorn-system   longhorn-driver-deployer-679f5d87fd-ctrn6                        1/1     Running            1 (24h ago)      2d2h
longhorn-system   longhorn-iscsi-installation-9q9zc                                1/1     Running            10 (24h ago)     10d
longhorn-system   longhorn-iscsi-installation-dd66j                                1/1     Running            9 (24h ago)      10d
longhorn-system   longhorn-iscsi-installation-hvjhw                                1/1     Running            10 (24h ago)     11d
longhorn-system   longhorn-manager-dwcbf                                           2/2     Running            20 (24h ago)     10d
longhorn-system   longhorn-manager-kfvnw                                           2/2     Running            21 (24h ago)     10d
longhorn-system   longhorn-manager-nzcgq                                           2/2     Running            20 (24h ago)     10d
longhorn-system   longhorn-nfs-installation-6542m                                  1/1     Running            10 (24h ago)     11d
longhorn-system   longhorn-nfs-installation-kmsll                                  1/1     Running            10 (24h ago)     10d
longhorn-system   longhorn-nfs-installation-qw2kx                                  1/1     Running            9 (24h ago)      10d
longhorn-system   longhorn-ui-87977fc97-mfsw9                                      1/1     Running            15 (24h ago)     3d10h
longhorn-system   longhorn-ui-87977fc97-nt2l7                                      1/1     Running            4 (24h ago)      2d2h
longhorn-system   share-manager-pvc-4864ae8a-aae5-4a16-ae14-dbf8dfd570f5           1/1     Running            0                24h
longhorn-system   share-manager-pvc-846c1e16-071a-4547-8636-0f395e55d6d9           1/1     Running            0                58s
metallb-system    controller-74b6dc8f85-wm4wz                                      1/1     Running            1 (24h ago)      2d2h
metallb-system    speaker-jp4jp                                                    1/1     Running            39 (24h ago)     9d
metallb-system    speaker-lkgxk                                                    1/1     Running            37 (24h ago)     9d
metallb-system    speaker-mhxnc                                                    1/1     Running            168 (24h ago)    9d
monitoring        blackbox-exporter-prometheus-blackbox-exporter-bd9d44f8d-wx96l   1/1     Running            0                18h
monitoring        debug                                                            0/1     CrashLoopBackOff   216 (2m6s ago)   18h
monitoring        grafana-7b459849c-pf8c8                                          1/1     Running            0                17h
monitoring        prometheus-alertmanager-0                                        1/1     Running            0                17h
monitoring        prometheus-kube-state-metrics-6777668f6-mqqz9                    1/1     Running            0                17h
monitoring        prometheus-prometheus-node-exporter-4fmsx                        1/1     Running            0                17h
monitoring        prometheus-prometheus-node-exporter-tc74p                        1/1     Running            0                17h
monitoring        prometheus-prometheus-node-exporter-w88kb                        1/1     Running            0                17h
monitoring        prometheus-prometheus-pushgateway-66c5444c7b-5js9w               1/1     Running            0                17h
monitoring        prometheus-server-7c5794cb9f-bwjqt                               2/2     Running            0                17h
phpmyadmin        pma-644b4f45f8-fgqbz                                             1/1     Running            2 (24h ago)      2d12h
prestashop        mariadb-prestashop-6ccf47d9f8-98qcj                              1/1     Running            0                24m
prestashop        prestashop-5bb54b5cbb-f6wk7                                      1/1     Running            0                70s
wordpress         mariadb-wordpress-7fbd6dcc-pn5mj                                 1/1     Running            0                24h
wordpress         wordpress-bbf68bdcf-f7jhm                                        1/1     Running            1 (24h ago)      2d2h
wordpress         wordpress-bbf68bdcf-nlccj                                        1/1     Running            1 (24h ago)      2d2h
```

Placez dans votre hosts :
```sh
ip_ingress vador-fans.lan
ip_ingress pma.vador-fans.lan
ip_ingress prometheus.vador-fans.lan
ip_ingress grafana.vador-fans.lan
ip_ingress longhorn.vador-fans.lan
```

Rendez-vous sur votre navigateur, allez sur les différents liens `http://vador-fans.lan` `http://vador-fans.lan/wp-admin` `http://vador-fans.lan/eshop` `http://pma.vador-fans.lan`
Vous n'avez plus qu'à configurer vos différents sites ;) 

---

## Conclusion
Ce projet met en place un cluster Kubernetes avec K3s, contenant plusieurs applications WordPress, PrestaShop et phpMyAdmin. 
Grâce à Longhorn pour le stockage, MetalLB pour le load balancing et Nginx comme ingress controller, l’infrastructure est robuste et facilement extensible. 
Ce déploiement permet d’expérimenter et d’héberger des applications web modernes dans un environnement Kubernetes optimisé.

