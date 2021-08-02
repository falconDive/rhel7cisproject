RHEL 7 SERVER HARDENING AND GCP IMAGE CREATION USING PACKER


Pre-requisite
Packer
GCP account

Introduction
Packer is the tool that helps to create custom images in an automated fashion. Imagine You want to make sure each instance that you create should have Nginx installed You could go with the following solutions.

Add the Startup script to the instance so that during the instance creation the startup script will install the necessary stuff
Custom image where we could create the image baked with all the software and configuration
The first solution is not the efficient way because

Every time when the instance is getting created we have to wait until the startup scripts finish the installation
Startup scripts are some times prone to error
So the second solution may seem efficient one

Creation of custom images may be achieved in two ways

Manually creating the custom Images
Automating the image creation process

Packer helps to create the custom images in an automated way

Below are the few advantages of the Packer

Multi Builder option allows building images for multiple cloud providers like Amazon, Google Cloud, azure and even for containers like Docker
Easily fits into the CI/CD pipelines
Easy to learn
Provisioning option which helps to install the necessary stuff





Creating Hardened Image using Packer
Creating Hardened Image is the two step process

Create the Service Account
Build the Image




COMMANDS
packer validate packer.json
packer build packer.json