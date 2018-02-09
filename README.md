# vCloud Director (vCD) on AWS - CloudFormation Templates

This repository contains AWS CloudFormation Templates that deploy scaleable multi cell vCloud Director Environment leveraging AWS services.
The project was created for pure testing purposes with a long term goal to be leveraged in conjunction with the VMware Cloud on AWS service offering and provide fully automated mechanism to provision public cloud vCD instances on AWS.
This vCD Stack is deployed in a Multi-AZ fashion by placing the stack components across Two Availability Zones in a Single AWS Region.

![picture](https://github.com/llyubenov/VCDonAWS/blob/master/Diagrams/VCDonAWS.jpg)

The vCD Stack infrastructure is laid out leveraging Nested CloudFormation templates, which allows us to break the deployment of the necessary infrastructure into a smaller chunks.
Leveraging Nested CloudFormation templates allows us also to have smaller templates with less repeatable code in them.

## Prerequisites

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

This is master templates that calls all nested templates.

<table width="100%">
    <tr>
        <th align="left" colspan="2"><h4><a href="https://github.com/llyubenov/VCDonAWS/blob/master/main.template">main.template</a></h4></th>
    </tr>
    <tr>
        <td width="100%" valign="top">
            <p>Creates the Complete vCD Stack</p>
            <h6>The template deploy the following nested templates</h6>
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

This is a nested templated that can be run as a stand alone templates as well.

<table width="100%">
    <tr>
        <th align="left" colspan="2"><h4><a href="https://github.com/llyubenov/VCDonAWS/blob/master/vpc.template">vpc.template</a></h4></th>
    </tr>
    <tr>
        <td width="100%" valign="top">
            <p>Creates the VPC with single or multi-az network topology</p>
            <h6>This template deploys</h6>
            <ol>
             <li>VPC</li>
             <li>Public Network/s</li>
             <li>Private Network/s</li>
             <li>Nat Gateways/s</li>
             <li>EIP/s</li>
             <li>Routing tables</li>
             <li>S3 endpoint</li></li>
            </ol>
            <h6>Public S3 URL</h6>
            <ol>
             <oi>https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vpc.template</li>
            </ol>
        </td>
        <td  nowrap width="200" valign="top">
            <table>
                <tr>
                    <th align="left">Launch</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/home?#/stacks/new?&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vpc.template" target="_blank"><img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"></a>
                    </td>
                </tr>
            </table>
            <table>
                <tr>
                    <th align="left">View in Designer</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vpc.template" target="_blank"><img src="https://github.com/llyubenov/VCDonAWS/blob/master/Diagrams/vpc.png" width:100% alt="View in Designer"></a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

### Bastion Hosts
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

This is a nested templated that can be run as a stand alone templates as well.

<table width="100%">
    <tr>
        <th align="left" colspan="2"><h4><a href="https://github.com/llyubenov/VCDonAWS/blob/master/linux-bastion.template">linux-bastion.template</a></h4></th>
    </tr>
    <tr>
        <td width="100%" valign="top">
            <p>This template is based of the <a href="https://aws.amazon.com/quickstart/architecture/linux-bastion/">Linux Bastion Hosts on AWS</a> - Quick starts template.</p>
            <h6>This template deploys</h6>
            <ol>
             <li>Security Groups</li>
             <li>EIP/s</li>
             <li>Bastion host/s in Auto Scaling Group</li>
             <li>Bastion host/s Access Security Group</li>
             <li>Private instances Access Security Group</li>
            </ol>
            <h6>Public S3 URL</h6>
            <ol>
             <oi>https://s3-us-west-2.amazonaws.com/vcd-cf-templates/linux-bastion.template</li>
            </ol>
        </td>
        <td  nowrap width="200" valign="top">
            <table>
                <tr>
                    <th align="left">Launch</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/home?#/stacks/new?&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/linux-bastion.template" target="_blank"><img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"></a>
                    </td>
                </tr>
            </table>
            <table>
                <tr>
                    <th align="left">View in Designer</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/linux-bastion.template" target="_blank"><img src="https://github.com/llyubenov/VCDonAWS/blob/master/Diagrams/bastion.png" width:100% alt="View in Designer"></a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

### Database
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

This is a nested templated that can be run as a stand alone templates as well.

<table width="100%">
    <tr>
        <th align="left" colspan="2"><h4><a href="https://github.com/llyubenov/VCDonAWS/blob/master/rds.template">rds.template</a></h4></th>
    </tr>
    <tr>
        <td width="100%" valign="top">
            <p>Deploys the Postgres RDS in single or multi-az deployment</p>
            <h6>This template deploys</h6>
            <ol>
             <li>RDS Security Group</li>
             <li>Postgres RDS</li>
             </br>
             </br>
            </ol>
            <h6>Public S3 URL</h6>
            <ol>
             <oi>https://s3-us-west-2.amazonaws.com/vcd-cf-templates/rds.template</li>
            </ol>
        </td>
        <td  nowrap width="200" valign="top">
            <table>
                <tr>
                    <th align="left">Launch</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/home?#/stacks/new?&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/rds.template" target="_blank"><img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"></a>
                    </td>
                </tr>
            </table>
            <table>
                <tr>
                    <th align="left">View in Designer</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/rds.template" target="_blank"><img src="https://github.com/llyubenov/VCDonAWS/blob/master/Diagrams/rds.png" width:100% alt="View in Designer"></a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

### vCD deployment
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Load Balancing
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

### Autoscaling
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

## TO-DO List
