# LAMP_stack_deployment_on_Kubernetes_using_Ansible

# 🐧LAMP Stack on Kubernetes using Ansible | No Pre-built Images
This project provisions a complete LAMP stack (Linux, Apache, MySQL, PHP) inside a Kubernetes environment using Ansible and manually-built container images — no pre-built Docker Hub images used.

## 🔧 Tech Stack
- Kubernetes (minikube single node)
- Docker (for custom images)
- Ansible (inside a pod, used to configure other pods)
- Apache2 + PHP (web frontend)
- MySQL (backend DB with persistent storage)
- NodePort Services for external access
  
## 📁 Project Structure
```
├── ansible
│   ├── build_and_push.yml
│   ├── roles
│   │   ├── build_images
│   │   │   ├── files
│   │   │   │   ├── Dockerfile.apachephp
│   │   │   │   ├── Dockerfile.base
│   │   │   │   ├── Dockerfile.mysql
│   │   │   │   ├── index.php
│   │   │   │   └── mysqld.cnf
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── deploy_k8s
│   │       ├── files
│   │       │   ├── apachephp-deployment.yaml
│   │       │   ├── apachephp-service.yaml
│   │       │   ├── mysql-deployment.yaml
│   │       │   ├── mysql-service.yaml
│   │       │   ├── pvc-mysql.yaml
│   │       │   └── pv-mysql.yaml
│   │       └── tasks
│   │           └── main.yml
│   └── site.yml
├── load-images-in-minikube.sh
├── local-env-setup-for-k8sPlugin.sh
└── README.md
```
## ⚙️ How It Works
### 1. Custom Image Build
- All Docker images (apachephp, mysql-custom, and ansible) are manually built locally with imagePullPolicy: Never.
- ```apachephp``` contains Apache2 + PHP + DB connection logic.
- ```mysql-custom``` initializes mydb with root user.
  
### 2. Persistent Volume Setup
- MySQL uses emptyDir during testing.
- Optionally switch to hostPath-based PV + PVC for persistent DB.
  
### 3. Kubernetes Deployments
- ApachePHP pod runs the frontend, reads DB credentials from environment variables.
- MySQL pod runs with custom password and database.
- Services (NodePort for Apache, headless for MySQL) enable communication.

### 4. Ansible Configuration
- Ansible runs inside a Kubernetes pod and SSHes into the Apache pod.
- It copies PHP files and restarts Apache from inside the cluster.
  
## 📦 Environment Variables (ApachePHP Pod)
| Variable	  | Purpose
| ----------  | ----------
|```DB_HOST```| Hostname of MySQL service
|```DB_USER```|	MySQL user (e.g., apache)
|```DB_PASSWORD```|	MySQL password
|```DB_NAME```|	Target database (mydb)

# 🚀 Deployment Steps
1. Build Docker Images Locally
```
docker build -t apachephp:latest ./apachephp
docker build -t mysql-custom:latest ./mysql
docker build -t ansible-pod:latest ./ansible-pod
```
2. Deploy to Kubernetes
```
kubectl apply -f k8s-manifests/mysql-pv.yaml
kubectl apply -f k8s-manifests/mysql-pvc.yaml
kubectl apply -f k8s-manifests/mysql-deployment.yaml
kubectl apply -f k8s-manifests/mysql-service.yaml

kubectl apply -f k8s-manifests/apache-deployment.yaml
kubectl apply -f k8s-manifests/apache-service.yaml
```

3. Access the Web App
```
minikube service apachephp --url
# or use: http://<NodeIP>:30080
```
4. Run Ansible Playbooks (inside pod)
```
kubectl exec -it ansible-pod -- bash
ansible-playbook setup-apache.yml
```
# 🧪 Troubleshooting
- If MySQL login fails (Access denied for root):

  - Check if password is correctly set in MYSQL_ROOT_PASSWORD.
  - Optionally use init.sql to create users manually.
- If Apache can't reach DB:

   - Ensure DB_HOST=mysql matches MySQL service name.
   - Ensure clusterIP: None is set for MySQL for headless service.
- If PHP page doesn't load:

   - Verify Ansible pod has correctly copied index.php to /var/www/html/.
   - Check pod logs: kubectl logs apachephp-xxxxx.
     
# 📚 Learning Outcome
- Built a multi-tier LAMP stack on Kubernetes using pure infrastructure-as-code.
- Used Ansible in a pod to configure other running containers (via SSH).
- Emulated real-world provisioning without relying on prebuilt or official Docker images.
- Learned Kubernetes networking, persistent storage, and pod-to-pod communication.
# 🙌 Author
Sachin Singh

📘 DevOps | Cloud | CI/CD | Kubernetes
