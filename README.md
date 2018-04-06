# quickstart-microsoft-rdgateway
## Remote Desktop Gateway on AWS

AWS provides a comprehensive set of services and tools for deploying Microsoft Windows-based workloads on its highly reliable and secure cloud infrastructure. This Quick Start deploys Remote Desktop Gateway (RD Gateway) on the AWS Cloud.

RD Gateway uses the Remote Desktop Protocol (RDP) over HTTPS to establish a secure, encrypted connection between remote users and EC2 instances running Microsoft Windows, without needing to configure a virtual private network (VPN). This helps reduce the attack surface on your Windows-based instances while providing a remote administration solution for administrators.

You can use the AWS CloudFormation templates included with the Quick Start to deploy a fully configured RD Gateway infrastructure in your AWS account. The Quick Start automates the following:

- Deploying RD Gateway into a new VPC
- Deploying RD Gateway into an existing VPC (standalone)
- Deploying RD Gateway into an existing VPC (domain-joined)

You can also use the AWS CloudFormation templates as a starting point for your own implementation.

![Quick Start architecture for RD Gateway on AWS](https://d0.awsstatic.com/partner-network/QuickStart/datasheets/rd-gateway-architecture-on-aws.png)

For architectural details, best practices, step-by-step instructions, and customization options, see the [deployment guide](https://fwd.aws/5VrKP).

To post feedback, submit feature ideas, or report bugs, use the **Issues** section of this GitHub repo.
If you'd like to submit code for this Quick Start, please review the [AWS Quick Start Contributor's Kit](https://aws-quickstart.github.io/). 
