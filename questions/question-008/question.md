# Question 008 - Create Redis Pod

## Objective

Practice creating pods with specific image tags and port configurations.

## Tasks

A web application requires a specific version of redis to be used as a cache.

Create a **pod**, and leave it running when complete:

- The pod must run in the **web** namespace.

- The namespace has already been created.

- The name of the pod should be **cache**

- Use the redis image with the **3.2 tag**

- **Expose** port **6379**

## Notes

- The namespace **web** already exists
- Pod name must be exactly **cache**
- Image must be **redis:3.2**
- Port **6379** must be exposed
- Pod must be running (not just created)

