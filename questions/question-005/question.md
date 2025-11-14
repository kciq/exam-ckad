# Question 005 - Scale Deployment and Create NodePort Service

## Objective

Practice scaling deployments and creating NodePort services to expose applications.

## Tasks

You need to scale an existing deployment for availability and create a service to expose the deployment within your infrastructure.

### Steps

1. Start with the deployment named **nov2025-deployment** which has already been deployed to the namespace **nov2025**.
   
   - Add the **func=webFrontend** key/value label to the **pod template metadata** to identify the pod for the service definition
   - Have **4 replicas**

2. Next, create and deploy in namespace nov2025 a **service** that accomplishes the following:
   
   - Is of type **NodePort** & Name of **Berry**.
   - **Expose** the service **TCP** port 8080.
   - Mapped to pods defined by the specification of **nov2025-deployment**.

## Notes

- The deployment must have 4 replicas
- The pod template must have the label func=webFrontend
- The service must be named Berry
- The service must be of type NodePort
- The service must expose port 8080


