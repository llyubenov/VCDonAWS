# vCloud Director (vCD) on AWS - CloudFormation Templates

This repository contains AWS CloudFormation Templates that deploy scaleable multi cell vCloud Director Environment leveraging AWS services.
The project was created for pure testing purposes with a long term goal to be leveraged in conjunction with the VMware Cloud on AWS service offering and provide fully automated mechanism to provision public cloud vCD instances on AWS.
This vCD Stack is deployed in a Multi-AZ fashion by placing the stack components across Two Availability Zones in a Single AWS Region.

![picture](https://github.com/llyubenov/VCDonAWS/blob/master/Diagrams/VCDonAWS.jpg)

The vCD Stack infrastructure is laid out leveraging Nested CloudFormation templates, which allows us to break the deployment of the necessary infrastructure into a smaller chunks.
Leveraging Nested CloudFormation templates allows us also to have smaller templates with less repeatable code in them.

## Prerequisites
In order to be able to successfully deploy the vCD stack, there are a few prerequisites that needs to be performed before you can deploy this stack:
* [EC2 Key Pairs]
* [ELB Certificate]
* [vCD Binaries]


## Templates
The nested templates are broken down into different categories :

* [Orchestrator](#orchestrator)
* [Infrastructure](#infrastructure)
* [Bastion Hosts](#bastion-hosts)
* [Database](#database)
* [vCD deployment](#vcd-deployment)
* [Load Balancing](#load-balancing)
* [vCD Autoscaling Groups](#vcd-autoscaling-groups)


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


<table width="100%">
    <tr>
        <th align="left" colspan="2"><h4><a href="https://github.com/llyubenov/VCDonAWS/blob/master/vcd-main.template">vcd-main.template</a></h4></th>
    </tr>
    <tr>
        <td width="100%" valign="top">
            <p>Deploys the Primary vCD cell</p>
            <h6>This template deploys</h6>
            <ol>
             <li>EC2 Instance</li>
             <li>vCD Cells Access Security Group</li>
             <li>S3 Bucket for vCD Transfer Store</li>
             <li>Configures first vCD Cell</li>
             </br>
            </ol>
            <h6>Public S3 URL</h6>
            <ol>
             <oi>https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vcd-main.template</li>
            </ol>
        </td>
        <td  nowrap width="200" valign="top">
            <table>
                <tr>
                    <th align="left">Launch</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/home?#/stacks/new?&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vcd-main.template" target="_blank"><img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"></a>
                    </td>
                </tr>
            </table>
            <table>
                <tr>
                    <th align="left">View in Designer</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vcd-main.template" target="_blank"><img src="https://github.com/llyubenov/VCDonAWS/blob/master/Diagrams/vcd-main.png" width:100% alt="View in Designer"></a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

### Load Balancing
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)


<table width="100%">
    <tr>
        <th align="left" colspan="2"><h4><a href="https://github.com/llyubenov/VCDonAWS/blob/master/vcd-elb.template">vcd-elb.template</a></h4></th>
    </tr>
    <tr>
        <td width="100%" valign="top">
            <p>Deploys Elastic Load Balancers for vCD</p>
            <h6>This template deploys</h6>
            <ol>
             <li>vCD UI Elastic Load Balancer</li>
             <li>vCD Console Proxy Elastic Load Balancer</li>
             </br>
             </br>
             </br>
            </ol>
            <h6>Public S3 URL</h6>
            <ol>
             <oi>https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vcd-elb.template</li>
            </ol>
        </td>
        <td  nowrap width="200" valign="top">
            <table>
                <tr>
                    <th align="left">Launch</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/home?#/stacks/new?&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vcd-elb.template" target="_blank"><img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"></a>
                    </td>
                </tr>
            </table>
            <table>
                <tr>
                    <th align="left">View in Designer</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vcd-elb.template" target="_blank"><img src="https://github.com/llyubenov/VCDonAWS/blob/master/Diagrams/vcd-elb.png" width:100% alt="View in Designer"></a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

### vCD Autoscaling Groups
[Back to Top](#vcloud-director-vcd-on-aws---cloudformation-templates)

<table width="100%">
    <tr>
        <th align="left" colspan="2"><h4><a href="https://github.com/llyubenov/VCDonAWS/blob/master/vcd-cells.template">vcd-cells.template</a></h4></th>
    </tr>
    <tr>
        <td width="100%" valign="top">
            <p>Deploys Autoscaling Groups for vCD Cells</p>
            <h6>This template deploys</h6>
            <ol>
             <li>vCD UI Autoscaling Group</li>
             <li>Adds vCD UI Autoscaling Group to ELB UI Target Group</li>
             <li>vCD Console Proxy Autoscaling Group</li>
             <li>Adds vCD Console Proxy Autoscaling Group to ELB UI Target Group</li>
             </br>
            </ol>
            <h6>Public S3 URL</h6>
            <ol>
             <oi>https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vcd-cells.template</li>
            </ol>
        </td>
        <td  nowrap width="200" valign="top">
            <table>
                <tr>
                    <th align="left">Launch</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/home?#/stacks/new?&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vcd-cells.template" target="_blank"><img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"></a>
                    </td>
                </tr>
            </table>
            <table>
                <tr>
                    <th align="left">View in Designer</th>
                </tr>
                <tr>
                    <td>
                        <a href="https://console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateURL=https://s3-us-west-2.amazonaws.com/vcd-cf-templates/vcd-cells.template" target="_blank"><img src="https://github.com/llyubenov/VCDonAWS/blob/master/Diagrams/vcd-cells.png" width:100% alt="View in Designer"></a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

## TO-DO List
