# vCloud Director (vCD) on AWS - CloudFormation Templates

This repository contains AWS CloudFormation Templates that deploy scaleable multi cell vCloud Director Environment leveraging AWS services.
The vCD stack can be leveraged in conjunction with the VMware Cloud on AWS service offering, or in a numerous different scenarios as well.
This vCD Stack is deployed in a Multi-AZ fashion by placing the stack components across Two Availability Zones in a Single AWS Region.

![picture](https://github.com/llyubenov/VCDonAWS/blob/master/VCDonAWS.jpg)

The vCD Stack infrastructure is laid out leveraging Nested CloudFormation templates, which allows us to break the deployment of the necessary infrastructure into a smaller chunks.
Leveraging Nested CloudFormation templates allows us also to have smaller templates with less repeatable code in them.

## Templates
The nested templates are broken down into different categories :

* [Orchestrator](#orchestrator)
* [Infrastructure (vpc)](#infrastructure)
* [Database (rds)](#database)
* [vCD deployment (vcd_main)](#database)
* [Load Balancing (elb)](#loadbalancing)
* [Autoscaling (vcd_cells)](#autoscaling)

### Orchestrator
[Back to Top](# vCloud Director (vCD) on AWS - CloudFormation Templates)


### Infrastructure (vpc)
[Back to Top](# vCloud Director (vCD) on AWS - CloudFormation Templates)


### Database (rds)
[Back to Top](# vCloud Director (vCD) on AWS - CloudFormation Templates)
