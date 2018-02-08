# vCloud Director (vCD) on AWS - CloudFormation Templates

This repository contains AWS CloudFormation Templates that deploy scaleable multi cell vCloud Director Environment leveraging AWS services.
The vCD stack can be leveraged in conjunction with the VMware Cloud on AWS service offering, or in a numerous different scenarios as well.
This vCD Stack is deployed in a Multi-AZ fashion by placing the stack components across Two Availability Zones in a Single AWS Region.

![picture](https://github.com/llyubenov/VCDonAWS/blob/master/VCDonAWS.jpg)

The vCD Stack infrastructure is laid out leveraging Nested CloudFormation templates, which allows us to break the deployment of the necessary infrastructure into a smaller chunks.
Leveraging Nested CloudFormation templates allows us also to have smaller templates with less repeatable code in them.

## Templates
The nested templates are broken down into different categories :

* [Orchestrator (main.template)](#orchestrator)
* [Infrastructure (vpc.template)](#infrastructure-vpc)
* [Bastion Hosts (linux-bastion.template)](#infrastructure)
* [Database (rds.template)](#database)
* [vCD deployment (vcd-main.template)](#database)
* [Load Balancing (vcd-elb.template)](#loadbalancing)
* [Autoscaling (vcd-cells.template)](#autoscaling)

### Orchestrator
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)


### Infrastructure (vpc)
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Bastion Hosts
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Database (rds)
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### vCD deployment (vcd-main.template)
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Load Balancing (vcd-elb.template)
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Autoscaling (vcd-cells.template)
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)
