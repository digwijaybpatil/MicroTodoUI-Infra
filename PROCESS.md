# 🚀 Full Production Deployment Process — TODO Microservices on AKS (Step-by-Step)

(This file contains the entire guide exactly as requested.)

## 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

## 2. Terraform Infrastructure Setup
```bash
cd infra
terraform init
terraform plan
terraform apply -auto-approve
```

Get AKS credentials:
```bash
az aks get-credentials -g <resource-group> -n <aks-name> --overwrite-existing
```

## 3. Docker Image Builds
Login:
```bash
az acr login -n acrdigwimicrotodoappdev
```

Add service:
```bash
cd AddTaskTodoMicroservice
docker build -t acrdigwimicrotodoappdev.azurecr.io/todo-add-tasks-api:v1 .
docker push acrdigwimicrotodoappdev.azurecr.io/todo-add-tasks-api:v1
```

Get service:
```bash
docker build -t acrdigwimicrotodoappdev.azurecr.io/todo-get-task-api:v1 ./GetTasksTodoMicroservice
docker push acrdigwimicrotodoappdev.azurecr.io/todo-get-task-api:v1
```

Delete service:
```bash
docker build -t acrdigwimicrotodoappdev.azurecr.io/todo-delete-tasks-api:v1 ./DeleteTaskTodoMicroservice
docker push acrdigwimicrotodoappdev.azurecr.io/todo-delete-tasks-api:v1
```

UI:
```bash
docker build   --build-arg REACT_APP_GET_TASKS_API_BASE_URL=https://get.digwi.online   --build-arg REACT_APP_DELETE_TASK_API_BASE_URL=https://delete.digwi.online   --build-arg REACT_APP_CREATE_TASK_API_BASE_URL=https://add.digwi.online   -t acrdigwimicrotodoappdev.azurecr.io/todo-ui:v4 ./MicroTodoUI

docker push acrdigwimicrotodoappdev.azurecr.io/todo-ui:v4
```

## 4. Kubernetes Namespaces
```bash
kubectl apply -f k8s/namespaces.yaml
```

## 5. Ingress-NGINX Install
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
```

Check LoadBalancer IP:
```bash
kubectl get svc -n ingress-nginx
```

## 6. DNS Setup
Add A records:
```
ui     → <EXTERNAL-IP>
add    → <EXTERNAL-IP>
get    → <EXTERNAL-IP>
delete → <EXTERNAL-IP>
```

Test:
```bash
nslookup ui.digwi.online
```

## 7. Install cert-manager
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
kubectl get pods -n cert-manager
```

## 8. Create ClusterIssuer
```bash
kubectl apply -f argocd/cluster-issuer.yaml
```

## 9. Deploy Microservices
Add:
```bash
kubectl apply -f k8s/add/deployment.yaml
kubectl apply -f k8s/add/service.yaml
kubectl apply -f k8s/add/ingress.yaml
```

Get:
```bash
kubectl apply -f k8s/get/deployment.yaml
kubectl apply -f k8s/get/service.yaml
kubectl apply -f k8s/get/ingress.yaml
```

Delete:
```bash
kubectl apply -f k8s/delete/deployment.yaml
kubectl apply -f k8s/delete/service.yaml
kubectl apply -f k8s/delete/ingress.yaml
```

UI:
```bash
kubectl apply -f k8s/ui/deployment.yaml
kubectl apply -f k8s/ui/service.yaml
kubectl apply -f k8s/ui/ingress.yaml
```

## 10. Verify TLS
```bash
kubectl get certificate -A
kubectl get challenges -A
kubectl get orders -A
```

## 11. Test App
```
https://ui.digwi.online
https://add.digwi.online/tasks
https://get.digwi.online/tasks
https://delete.digwi.online/tasks/<id>
```

## 12. Install & Login ArgoCD
Get password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Port forward:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open:
```
https://localhost:8080
```

Deploy apps:
```bash
kubectl apply -f argocd/app-ui.yaml
kubectl apply -f argocd/app-add.yaml
kubectl apply -f argocd/app-get.yaml
kubectl apply -f argocd/app-delete.yaml
```

## 13. Debugging
```bash
kubectl get pods -A
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns>
kubectl get ingress -A
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller
```

## 14. Summary
You deployed:
- Terraform infra  
- AKS + ACR  
- 4 microservices  
- GitOps with ArgoCD  
- HTTPS with cert-manager  
- DNS with Namecheap  
- Full Ingress routing  
- UI + APIs working across domains  
