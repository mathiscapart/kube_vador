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

### Installation
1. Exécuter le script `deployment_kube` sur le **nœud master**.
2. Exécuter le script `deployment_node` sur chaque **nœud worker**.
3. Adapter les valeurs d'adresse IP et de `K3S_TOKEN` selon votre infrastructure.
   
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

## Conclusion
Ce projet met en place un cluster Kubernetes avec K3s, contenant plusieurs applications WordPress, PrestaShop et phpMyAdmin. 
Grâce à Longhorn pour le stockage, MetalLB pour le load balancing et Nginx comme ingress controller, l’infrastructure est robuste et facilement extensible. 
Ce déploiement permet d’expérimenter et d’héberger des applications web modernes dans un environnement Kubernetes optimisé.

