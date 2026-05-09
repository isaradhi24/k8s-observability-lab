
## ArgoCD OutOfSync

In you see your applications are OutOfSync in ArgoCD UI:

    EX: nginx-app   OutOfSync   Healthy

    Usually caused by one of these:

       * HPA modifies replicas dynamically
       * ArgoCD compares live replicas vs Git replicas
       * HPA + Deployment replica drift

## Verify wht is OutOfSync

    ```bash
    kubectl describe application <app-name> -n argocd
    ```
    You likely see:
        ``` spec.replicas```
    this is because: 
        * Git manifest says one replica count
        * HPA changes actual live replica count
    
    # Learning Poing:
    When using HPA: Do NOT manually control replicas in deployment ; HPA owns scaling.


