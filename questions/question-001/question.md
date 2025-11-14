# Question 001 - Build and Export Container Image

## Objective

Practice building and exporting container images using Dockerfile.

## Tasks

1. A **Dockerfile** has been prepared at `~/home/Dockerfile`.

2. Using the prepared Dockerfile, build a container image with the name **devmaq** and **Tag 3.0**. To install use the tool of your choice (docker, podman, buildah or img).

   **Important:** Please don't push the build image to a registry, run a container or otherwise consume it.

3. Using the tool of your choice, export the built container image in OCI-format and store it at `~/human-stork/devmac3.0.tar`.

## Notes

- The environment already has the necessary tools installed
- Make sure the directory `~/human-stork/` exists before exporting
- The validation will verify if the image was built correctly and if the tar file was created in the specified location
