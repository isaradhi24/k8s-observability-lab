## Start Docker Desktop first
## and then start WSL (Ubuntu-20.04)

## Kubernetes Lab Health Check

## 🧭 1. Cluster Basics

### Check nodes
```bash
kubectl get nodes -o wide
```
if you see errors like ---- "connection refused 127.0.0.1:39495"

## Troubleshooting

## Step 1: Verify wsl distros in PoserShell

  PS C:\Users\isara> wsl -l -v
  NAME              STATE           VERSION
* Ubuntu-20.04      Running         2
  Ubuntu            Stopped         2  <Ignore current WSL is Ubunt-20.04>
  docker-desktop    Running         2 

## 2. close docker desktop

## 3. Kill leftovers 

    taskkill /F /IM "Docker Desktop.exe"
    taskkill /F /IM "com.docker.backend.exe"
    taskkill /F /IM "com.docker.build.exe"

## 4. Restart everything
    wsl --shutdown

    PS C:\> wsl --shutdown
    PS C:\> wsl -l -v
    NAME              STATE           VERSION
    * Ubuntu-20.04    Stopped         2
    Ubuntu            Stopped         2
    docker-desktop    Stopped         2

## 3.  Re-open Docker Desktop

## 4. Re-nable WSL integration
    Settings --> REsources --> WSL Integration
    Ensure Enable integratin with my default WSL distro : Ubuntu-20.04

## 5. In Powershell - Enter Ubuntu again
    wsl -d Ubuntu-20.04

## 6. Verify WLS - in PowerShell
  PS C:\Users\isara> wsl -l -v
      NAME              STATE           VERSION
    * Ubuntu-20.04      Running         2  <=== ENSURE RUNNING ===>
      Ubuntu            Stopped         2  <--- IGNORE --->
      docker-desktop    Running         2 <=== ENSURE RUNNING ===>

  Note: Ubuntu (WSL) can be removed / deleted / Unregister using below
    wsl --unregister Ubuntu

    PS C:\Users\isara> wsl -l -v
    NAME              STATE           VERSION
    * Ubuntu-20.04      Running         2
      docker-desktop    Running         2


## 6. Verify Docker inside WSL
    docker version

    devops@DESKTOP-VTJP961:/mnt/c/Windows/system32$ docker version
      Client:
      Version:           29.4.1
      API version:       1.54
      Go version:        go1.26.2
      Git commit:        055a478
      Built:             Mon Apr 20 16:31:59 2026
      OS/Arch:           linux/amd64
      Context:           default

If Docker is still failing.....>>>>>>>

Verify Docker integration checkbox AGAIN

## In Docker Desktop:

      Settings → Resources → WSL Integration

      You should see:

      ✅ Enable integration with my default WSL distro
      ✅ Ubuntu-20.04 enabled

      Turn OFF Ubuntu-20.04 toggle.
      Click Apply & Restart.

      After restart:
      Turn ON Ubuntu-20.04 toggle again.
      Click Apply & Restart.
  

 ##  Verify Docker socket mount from WSL

  Inside Ubuntu-20.04:

  ls -l /mnt/wsl/docker-desktop/

  Do you see folders/files there?

  Especially:
        cli-tools
        shared-sockets
        docker.sock

  If directory DOES NOT exist:
      → integration is still broken.


Check PATH injection

Inside Ubuntu:

echo $PATH

Look for something similar to:

/mnt/wsl/docker-desktop/cli-tools/usr/bin

If missing, Docker Desktop did not inject tools.

Step 4 — Temporary manual fix (important)

Run inside Ubuntu:

export PATH=$PATH:/mnt/wsl/docker-desktop/cli-tools/usr/bin

Now test:

docker version

If it works now:
→ Docker integration/path injection is the only issue.

Then make permanent:

echo 'export PATH=$PATH:/mnt/wsl/docker-desktop/cli-tools/usr/bin' >> ~/.bashrc
source ~/.bashrc

If /mnt/wsl/docker-desktop does NOT exist

Then Docker Desktop integration service is corrupted.

Fastest fix:

Reset WSL integration

Docker Desktop →
Settings →
Resources →
WSL Integration

Disable ALL distros.

Apply & Restart.

Then enable ONLY:

Ubuntu-20.04

Apply & Restart.

Step 6 — Verify immediately

Inside Ubuntu:

which docker
docker version
kind get clusters
kubectl get nodes

=============================================

Once docker works, continue with cluster health checks

## Vefify kind inside WSL
 kind get clusters  --- if failed
 
 Verify path 
  which kind
  find / -name kind 2>/dev/null

## Reinstall KIND
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
kind get clusters
kind export kubeconfig --name devops-lab
kubectl get nodes

if kind not present then recreate cluster
kind create cluster --name devops-lab --config ~/kind-multi.yaml


## Step 1: Check if API Server container is running
```bash
sudo crictl ps | grep kube-apiserver
```



## Step1: Check Container runtime
```bash
  sudo systemctl status containerd
```
if you see inactive, restart containerd and verify again
```bash
  sudo systemctl restart containerd
```
## Step2: Check kubelet (most common root cause)
    The API server is managed by the kubelet as a static pod.
    If it’s not active (running), that’s your problem.
      ```bash
        sudo systemctl status kubelet
      ```
    Also check logs:
      ```bash
        sudo journalctl -u kubelet -n 50 --no-pager
      ```
      Typical issues you might see:
          swap not disabled
          container runtime not running
          config file missing  

## Step 3: Check static pod manifests
    Kubernetes control plane runs from:
    ```bash
        ls /etc/kubernetes/manifests/
    ```
    You should see:
      kube-apiserver.yaml
      kube-controller-manager.yaml
      kube-scheduler.yaml
      etcd.yaml
      If these are missing → cluster was never fully initialized.

## Step 4: Check etcd (API server depends on it)
    ```bash
      sudo crictl ps | grep etcd
    ```
      If etcd is down → API server will refuse connections exactly like this.

## Step 5: Verify port 6443
    ```bash
        sudo netstat -tulnp | grep 6443
    ```
        No output = nothing is listening → confirms API server is dead.






### Cluster info
```bash
kubectl cluster-info
```

### Component status
```bash
kubectl get componentstatuses
```

## 📦 2. System Pods (kube-system)
```bash
kubectl get pods -n kube-system -o wide
kubectl get ds -n kube-system
kubectl get deploy -n kube-system
```

## 🔥 3. ArgoCD Health Check

### Namespace
```bash
kubectl get ns argocd
```
### Pods
```bash
kubectl get pods -n argocd -o wide
```
### if ArgoCD not installed
```bash
sudo -u vagrant kubectl create namespace argocd --dry-run=client -o yaml | \
sudo -u vagrant kubectl apply -f -

sudo -u vagrant kubectl apply \
  -n argocd \
  -f /vagrant/manifests/argocd-install.yaml \
  --server-side
```
### if something looks "stuck"
```bash
kubectl get events -n argocd --sort-by=.metadata.creationTimestamp
or
kubectl describe pod -n argocd <pod>
```
### After ArgoCD up and verything is running
## Portfowarding
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
or
### if your on vm run below
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443  
```
## Login password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```
## login to ArgoCD in browser

url : https://localhost:8080
or
url : https://120.0.0.1:8080

user: admin
passowd: from above step


### Services
```bash
kubectl get svc -n argocd
```
### Applications
```bash
kubectl get applications -n argocd
```

## ⚙️ 4. Workload Overview
### All resources
```bash
kubectl get all -A
```
### Deployments
```bash
kubectl get deployments -A
```
### DaemonSets
```bash
kubectl get ds -A
```
### ReplicaSets
```bash
kubectl get rs -A
```

## 📊 5. Node Deep Dive
```bash
kubectl describe node k8s-master
kubectl describe node k8s-worker1
```

## 🚨 6. Debugging

### Events
```bash
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

### Problem pods
```bash
kubectl get pods -A | grep -E "Crash|Pending|Error"
```

### ⚡ Quick Daily Check
```bash
kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -n argocd
```
========================================

Current Stage
✅ KIND
✅ kubectl
✅ metrics-server
✅ Helm
✅ Prometheus
✅ Grafana
✅ Bash automation
✅ Declarative manifests

Next Stage
GitOps
✅ ArgoCD
⬜ Application manifests
⬜ Auto-sync
⬜ Self-healing
⬜ Drift detection

Then Later
Advanced Platform Engineering
⬜ Ingress Controller
⬜ cert-manager
⬜ ExternalDNS
⬜ Loki
⬜ Tempo
⬜ OpenTelemetry
⬜ HPA/VPA
⬜ Kyverno
⬜ Network Policies
⬜ Service Mesh

You now have a proper foundation for:


DevOps interviews


Kubernetes operations


platform engineering learning


GitOps workflows


observability practice


troubleshooting scenarios


This is becoming a strong hands-on lab environment.