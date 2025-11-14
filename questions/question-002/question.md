# Question 002 - Modify Deployment Security Context

## Objective

Practice modifying deployment security contexts to configure user ID and prevent privilege escalation.

## Tasks

1. Modify the existing Deployment named **hotfix-deployment** running in namespace **quetzal** so that its containers:

   - Run with user ID **30.000** and
   - Privilege escalation is forbidden

   The hotfix-deployment manifest file can be found at:
   
   ```bash
   ~/broker-deployment/hotfix-deployment.yaml
   ```

## Notes

- Make sure the namespace **quetzal** exists
- The deployment must be modified in place
- The security context should be applied to the container level


