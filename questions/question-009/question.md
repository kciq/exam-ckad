# Question 009 - Deploy Pod and Retrieve Logs/CPU Metrics

## Objective

Practice deploying pods from YAML files, retrieving logs, and analyzing resource consumption.

## Tasks

### Task 1: Deploy Pod and Retrieve Logs

1. Deploy the **winter** pod to the cluster using the provided yaml spec file at **/opt/ckadnov2025/winter.yaml**

2. Retrieve all currently available application logs from the running pod and store them in the file **/opt/ckadnov2025/log_output.txt**, which has already been created.

### Task 2: Find Pod with Highest CPU Usage

It is always useful to look at the resources your applications are consuming in a cluster.

From the pods running in namespace **cpu-stress**, write the **name only** of the **pod** that is consuming the most **CPU** to file **/opt/ckadnov2025/pod.txt**, which has already been created.

## Notes

- The YAML file is located at /opt/ckadnov2025/winter.yaml
- Logs should be saved to /opt/ckadnov2025/log_output.txt
- Pod name with highest CPU should be saved to /opt/ckadnov2025/pod.txt
- Both output files already exist and should be written to
- Use kubectl top pods to check CPU usage

