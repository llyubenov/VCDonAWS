# vCloud Director (vCD) on AWS - CloudFormation Templates

This repository contains AWS CloudFormation Templates that deploy scaleable multi cell vCloud Director Environment leveraging AWS services.
The intention of the vCD stack is to be used in conjunction with the VMware on AWS Cloud service offering, but if could also be leveraged in other scenarios as well.
This vCD Stack is deployed in a Multi-AZ fashion by placing the stack components across two Availability Zones in the same AWS Region.

![picture](https://github.com/llyubenov/VCDonAWS/blob/master/VCDonAWS.jpg)

The vCD Stack infrastructure is laid out leveraging Nested CloudFormation templates, which allows us to break the deployment of the necessary infrastructure into a smaller chunks.
Leveraging Nested CloudFormation templates allows us also to have smaller templates with less repeatable code in them.
