# Question 006 - Rolling Update and Rollback

## Objective

Practice configuring deployment strategies, performing rolling updates, and rolling back deployments.

## Tasks

Please complete the following:

1. Update the **app deployment** in the **nov2025** namespace with a **maxSurge** of **5%** and a **maxUnavailable** of **2%**

2. Perform a **rolling update** of the **web1** deployment, changing the repo/nginx image version to **1.13**

3. **Rollback** the **app** deployment to the **previous** version.

## Notes

- The app deployment must have maxSurge: 5% and maxUnavailable: 2% in rolling update strategy
- The web1 deployment should be updated to use nginx:1.13 image
- The app deployment should be rolled back to its previous version
- Both deployments should be in the nov2025 namespace


