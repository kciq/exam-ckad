# Question 007 - Create CronJob

## Objective

Practice creating and configuring CronJobs in Kubernetes.

## Tasks

Create a **CronJob** that in **production** namespace:

- Runs a **busybox** container executing **date**.

- The CronJob runs every **30 minutes**.

- The CronJob must have:

  - **2 completions** and **3 retries** on failure.

  - Terminate if running longer than **30 seconds**.

- CronJob named **log-cleaner** and **log** container

- **Verify** execution of CronJob.

## Notes

- The CronJob must be in the production namespace
- Schedule should be every 30 minutes (cron: */30 * * * *)
- completions: 2
- parallelism: not specified (defaults to 1)
- backoffLimit: 3 (retries on failure)
- activeDeadlineSeconds: 30 (terminate if running longer than 30 seconds)
- Container name should be "log"

