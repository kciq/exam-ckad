# Question 004 - Fix ServiceAccount RBAC Issues

## Objective

Practice troubleshooting and fixing RBAC (Role-Based Access Control) issues with ServiceAccounts in Kubernetes.

## Tasks

A Pod within the Deployment named **dev-deployment** in namespace **meta** is logging errors.

1. Look at the logs and identify error messages. Find errors including:
   
   ```
   User "system:serviceaccount:meta:default" cannot list resource "deployment..." in the namespace meta
   ```

2. Update the Deployment **dev-deployment** to resolve the errors in the logs of the Pod.

   The dev-deployment's manifest can be found at:
   
   ```bash
   ~/dev-deployment.yaml
   ```

## Notes

- The deployment uses a ServiceAccount that needs proper RBAC permissions
- You'll need to create appropriate Role and RoleBinding resources
- The ServiceAccount is likely the default ServiceAccount in the meta namespace


