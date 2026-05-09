## Verify any app is OutofSync in ArgoCD

If you find any like " <app-name> OutOfSunc Healthy"

Usually caused by one of these:

HPA modifies replicas dynamically
ArgoCD compares live replicas vs Git replicas
HPA + Deployment replica drift

## Verify What Is OutOfSync

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


