
### IMPORTANT GitOps Learning 

``` bash
Git is the source of truth in GitOps.
Any manual kubectl changes may be reverted automatically by ArgoCD self-heal.
```

### Observability Verification Commands

## Prometheus

Port-forwarding:
```
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090 > /dev/null 2>&1 &
```
Open in browser: http://localhost:9090

## Verify Targets In Prometheus UI:

``` Status --> Targets ```
        Expected UP for most targets like:
                - kubelet
                - node-exporter
                - kube-state-metrics
                - apiserver

        NOTE:
        etcd, scheduler, controller-manager, kube-proxy may show DOWN in KIND clusters because of local container networking limitations.
        This is expected in local labs.
        In lab YOU CAN IGNORE THEM SAFELY.  
    

## Grafana

Port-forward:
``` bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 > /dev/null 2>&1 &
```
## Get Grafana Password
``` bash
kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d && echo
```
Open:  http://localhost:3000

Username: admin
Password:  <from above step>

## Grafana Checks

# 1. Login Success
       * Grafana accessible
       * admin password works
       * Prometheus datasource healthy

# 2. Verify Dashboards
    Search these dashboards: kubernetes / Compute Resources / Cluster
    Check:
        * cluster CPU
        * memory
        * pod count

# 3. Verify Kubernetes / Compute Resources / Node
        * all 3 KIND nodes visible
        * CPU + RAM graphs updating

# 4. Verify Kubernetes / Compute Resources / Pod
        * nginx pods visible
        * CPU/memory metrics flowing

# 5. Verify Node Exporter Full
        ** This is the important infra dashboard.

          * filesystem
          * network
          * load averages
          * memory
          * CPU utilization

# 6. Cross Verify With kubectl ( Very important operational habit)

    Run in wsl terminal
    ```bash
        kubectl top nodes
        kubectl top pods -A
    ```
    Then compare with Grafana graphs.
    This proves:
            metrics-server
            Prometheus
            Grafana
    are all functioning correctly.

## Verify any app is OutofSync in ArgoCD

If you find any like " <app-name> OutOfSunc Healthy"

Usually caused by one of these:

   * HPA dynamically manages Deployment replica count based on metrics.
   * ArgoCD may detect drift if replicas are also statically defined in deployment.yaml.
 

## Troubleshoot why it is OutOfSync

In terminal
```kubectl describe application nginx-app -n argocd```

or in ArgoCD UI:
    App --> Diff
    You may see ```spec.replicas```

Because:
        Git manifest says one replica count
        HPA changes actual live replica count

Fix :
    remoe ``` replicas:``` from ```deplyment.yaml```

Learning Poing:  
    When using HPA, ``` Do NOT manually controll replicas in deployment```

If still OutOfSync ---> (IMPROTANT)
    vefiy any typos, syntax errors in manifests