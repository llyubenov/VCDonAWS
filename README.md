# vCloud Director (vCD) on AWS - CloudFormation Templates

This repository contains AWS CloudFormation Templates that deploy scaleable multi cell vCloud Director Environment leveraging AWS services.
The project was created for pure testing purposes with a long term goal to be leveraged in conjunction with the VMware Cloud on AWS service offering and provide fully automated mechanism to provision public cloud vCD instances on AWS.
This vCD Stack is deployed in a Multi-AZ fashion by placing the stack components across Two Availability Zones in a Single AWS Region.

![picture](https://github.com/llyubenov/VCDonAWS/blob/master/DiagramsVCDonAWS.jpg)

The vCD Stack infrastructure is laid out leveraging Nested CloudFormation templates, which allows us to break the deployment of the necessary infrastructure into a smaller chunks.
Leveraging Nested CloudFormation templates allows us also to have smaller templates with less repeatable code in them.

## Templates
The nested templates are broken down into different categories :

* [Orchestrator](#orchestrator)
* [Infrastructure](#infrastructure)
* [Bastion Hosts](#bastion-hosts)
* [Database](#database)
* [vCD deployment](#vcd-deployment)
* [Load Balancing](#load-balancing)
* [Autoscaling](#autoscaling)

### Orchestrator
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)
This is master templates that call all nested templates.

<table width="100%">
    <tr>
        <th align="left" colspan="2"><h4><a href="https://github.com/llyubenov/VCDonAWS/blob/master/main.template">main.template</a></h4></th>
    </tr>
    <tr>
        <td width="100%" valign="top">
            <p>Select the foundational pieces for building out an infrastructure from the ground up.</p>
            <h6>Creates the Complete vCD Stack</h6>
            <ol>
             <li>VPC</li>
             <li>Bastion Host/s</li>
             <li>Postgres RDS</li>
             <li>vCD Deployment</li>
             <li>Elastic Load Balancers</li>
             <li>AutoScaling Groups</li></li>
            </ol>
            <h6>Public S3 URL</h6>
            <ol>
             <oi>https://s3-us-west-2.amazonaws.com/vcd-cf-templates/main.template</li>
            </ol>
        </td>
        <td  nowrap width="200" valign="top">
            <table>
                <tr>
                    <th align="left">Launch</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/home?#/stacks/new?&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/main.template" target="_blank"><img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"></a>
                    </td>
                </tr>
            </table>
            <table>
                <tr>
                    <th align="left">View in Designer</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/main.template" target="_blank"><img src="https://github.com/llyubenov/VCDonAWS/blob/master/Diagrams/main.png" width:100% alt="View in Designer"></a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

### Infrastructure
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Bastion Hosts
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Database
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### vCD deployment
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Load Balancing
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Autoscaling
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)
