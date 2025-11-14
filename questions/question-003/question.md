# Question 003 - Secret and Pod with Environment Variables

## Objective

Practice creating Kubernetes Secrets and using them as environment variables in Pods.

## Tasks

You are tasked with deploying a pod that has sensitive credentials stored in a Kubernetes Secret.

1. Create a **Secret** named **db-credentials** in the **default** namespace with the following key-value pairs:
   - username: admin
   - password: P@ssw0rd123

2. Create a Pod named **env-secret-pod** that runs a single container using the image **busybox**, and keeps running (**sleep 3600**).

3. The container should expose the Secret values as **environment variables**:
   - Environment variable **DB_USER** should use the value from **username**.
   - Environment variable **DB_PASS** should use the value from **password**.

4. Verify the environment variables are correctly set inside the pod.

## Notes

- The Secret must be created in the default namespace
- The Pod must be created in the default namespace
- Use busybox image and keep it running with sleep 3600
- Environment variables must be correctly mapped from the Secret


