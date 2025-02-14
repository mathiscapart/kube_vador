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

### Schéma 
Schéma disponible sur Draw.IO :

![Texte remplacement](schema_projet.drawio.png)

### Versions :

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

## Vérification 

Une fois toutes les applications déployées, exécutez la commande `kubectl get pods -A` 

Vous devriez avoir quelque chose qui ressemble à ça :
```sh
cache             cache-7bc4cc97fc-cq884                                   1/1     Running   3 (5m24s ago)     36h
ingress-nginx     ingress-nginx-controller-65d47ff7f5-jf6qg                1/1     Running   9 (5m40s ago)     32h
kube-system       coredns-ccb96694c-dlw4k                                  1/1     Running   9 (5m24s ago)     32h
kube-system       local-path-provisioner-5cf85fd84d-qq5q8                  1/1     Running   3 (5m40s ago)     31h
kube-system       metrics-server-5985cbc9d7-82xc6                          1/1     Running   6 (5m40s ago)     31h
longhorn-system   csi-attacher-565dc55c47-58nj6                            1/1     Running   12 (5m40s ago)    31h
longhorn-system   csi-attacher-565dc55c47-jqhdp                            1/1     Running   13 (5m24s ago)    32h
longhorn-system   csi-attacher-565dc55c47-qfc4l                            1/1     Running   13 (5m24s ago)    32h
longhorn-system   csi-provisioner-77f995b56c-52wht                         1/1     Running   12 (5m40s ago)    31h
longhorn-system   csi-provisioner-77f995b56c-j569k                         1/1     Running   15 (5m24s ago)    32h
longhorn-system   csi-provisioner-77f995b56c-r2lrr                         1/1     Running   6 (5m24s ago)     31h
longhorn-system   csi-resizer-8677f4c959-5zml9                             1/1     Running   13 (5m24s ago)    32h
longhorn-system   csi-resizer-8677f4c959-wj7sx                             1/1     Running   5 (5m24s ago)     31h
longhorn-system   csi-resizer-8677f4c959-wq4q9                             1/1     Running   12 (5m40s ago)    31h
longhorn-system   csi-snapshotter-6d96ddbf4-8q9jk                          1/1     Running   11 (5m40s ago)    31h
longhorn-system   csi-snapshotter-6d96ddbf4-lmq99                          1/1     Running   6 (5m24s ago)     31h
longhorn-system   csi-snapshotter-6d96ddbf4-t48x8                          1/1     Running   12 (5m24s ago)    32h
longhorn-system   engine-image-ei-51cc7b9c-4cbt4                           1/1     Running   18 (5m24s ago)    9d
longhorn-system   engine-image-ei-51cc7b9c-hb82n                           1/1     Running   11 (5m30s ago)    8d
longhorn-system   engine-image-ei-51cc7b9c-ng86l                           1/1     Running   17 (5m40s ago)    9d
longhorn-system   instance-manager-09fbe318f6d84cf1db0945e5eed3a242        1/1     Running   0                 5m7s
longhorn-system   instance-manager-2fbf15e7b8f426bf9730aa6cb98b2d93        1/1     Running   0                 5m6s
longhorn-system   instance-manager-aa0ad7b00229df6920eba104e52a078e        1/1     Running   0                 5m5s
longhorn-system   longhorn-csi-plugin-hnbhp                                3/3     Running   79 (5m14s ago)    8d
longhorn-system   longhorn-csi-plugin-jp6rp                                3/3     Running   94 (5m4s ago)     8d
longhorn-system   longhorn-csi-plugin-zpt49                                3/3     Running   68 (5m10s ago)    8d
longhorn-system   longhorn-driver-deployer-679f5d87fd-svqcn                1/1     Running   2 (5m24s ago)     31h
longhorn-system   longhorn-iscsi-installation-9q9zc                        1/1     Running   9 (5m30s ago)     8d
longhorn-system   longhorn-iscsi-installation-dd66j                        1/1     Running   8 (5m24s ago)     8d
longhorn-system   longhorn-iscsi-installation-hvjhw                        1/1     Running   9 (5m41s ago)     9d
longhorn-system   longhorn-manager-dwcbf                                   2/2     Running   18 (5m24s ago)    8d
longhorn-system   longhorn-manager-kfvnw                                   2/2     Running   19 (5m40s ago)    8d
longhorn-system   longhorn-manager-nzcgq                                   2/2     Running   18 (5m30s ago)    8d
longhorn-system   longhorn-nfs-installation-6542m                          1/1     Running   9 (5m40s ago)     9d
longhorn-system   longhorn-nfs-installation-kmsll                          1/1     Running   9 (5m30s ago)     8d
longhorn-system   longhorn-nfs-installation-qw2kx                          1/1     Running   8 (5m24s ago)     8d
longhorn-system   longhorn-ui-87977fc97-mfsw9                              1/1     Running   13 (5m16s ago)    31h
longhorn-system   longhorn-ui-87977fc97-qd7w9                              1/1     Running   8 (5m15s ago)     32h
longhorn-system   share-manager-pvc-1dc1bce1-fffa-4404-ad19-e250685877e4   1/1     Running   0                 4m7s
longhorn-system   share-manager-pvc-4864ae8a-aae5-4a16-ae14-dbf8dfd570f5   0/1     Running   0                 67s
metallb-system    controller-74b6dc8f85-glhwx                              1/1     Running   27 (5m24s ago)    36h
metallb-system    speaker-jp4jp                                            1/1     Running   38 (5m30s ago)    7d12h
metallb-system    speaker-lkgxk                                            1/1     Running   36 (5m40s ago)    7d12h
metallb-system    speaker-mhxnc                                            1/1     Running   167 (5m24s ago)   7d12h
phpmyadmin        pma-644b4f45f8-fgqbz                                     1/1     Running   1 (5m30s ago)     9h
prestashop        mariadb-prestashop-6ccf47d9f8-jcnv9                      1/1     Running   0                 3m39s
prestashop        prestashop-5bb54b5cbb-75gcd                              1/1     Running   4 (97s ago)       11h
prestashop        prestashop-5bb54b5cbb-mjwgx                              1/1     Running   3 (5m30s ago)     11h
wordpress         mariadb-wordpress-7fbd6dcc-bhfdq                         1/1     Running   0                 3m39s
wordpress         wordpress-bbf68bdcf-l2lbs                                1/1     Running   2 (5m40s ago)     31h
wordpress         wordpress-bbf68bdcf-lrzhp                                1/1     Running   3 (5m24s ago)     34h
   ```

Placez dans votre hosts :
```sh
ip_ingress vador-fans.lan
ip_ingress pma.vador-fans.lan
```

Rendez-vous sur votre navigateur, allez sur les différents liens `http://vador-fans.lan` `http://vador-fans.lan/wp-admin` `http://vador-fans.lan/eshop` `http://pma.vador-fans.lan`
Vous n'avez plus qu'à configurer vos différents sites ;) 
---

## Conclusion
Ce projet met en place un cluster Kubernetes avec K3s, contenant plusieurs applications WordPress, PrestaShop et phpMyAdmin. 
Grâce à Longhorn pour le stockage, MetalLB pour le load balancing et Nginx comme ingress controller, l’infrastructure est robuste et facilement extensible. 
Ce déploiement permet d’expérimenter et d’héberger des applications web modernes dans un environnement Kubernetes optimisé.

