# My Portfolio Application - Infrastructure

This repository contains the code related to the creation and management of AWS resources used by the portfolio system. The following technologies have been used for this purpose:

1. AWS Lightsail

2. Terraform

3. Github Actions


The infrastructure of the entire system is managed using Terraform. I have used AWS as the cloud hosting provider. Terraform will persist the state files in AWS S3 Buckets. I have used Github Actions to create the CI/CD pipeline for deployment of the infrastructure. You can download this repository and make some minor changes as instructed below to get your own Infrastructure As Code up and running.


## 1. Configuring AWS Account

Make sure that you have an AWS account to host your applications and other resources. You can use a different provider as well. In that case, you need to modify the codebase to suit your own cloud hosting provider. To configure your AWS account perform the following steps:

### 1.1 Create a new user for your Github Actions deployment agent

- Navigate to [AWS IAM console](https://us-east-1.console.aws.amazon.com/iam/home) of your AWS account.

- Navigate to 'users' and click on 'create user'.

- Provide a username and make sure it is unique and reflects the purpose of this user. For example, the name of the user can be 'my_application_deployment_github_terraform'.

- Navigate to 'User groups' and click on 'Create Group'. Instead of attaching permissions directly to the user, we will create a user group and attach the user and the permissions to the group. This will help us to add more similar users in the future. We can just add the new users to the group and they will automatically receive the neccessary permissions for deployment to lightsail.

- Add the user that you created to the user group.

- Navigate to the user group's detail page and click on 'permissions'.

- We will attach the following permissions to deploy our code to AWS: IAMFullAccess, AmazonS3FullAccess. We have to provide IAM and S3 full access to Terraform because it may throw unauthorized errors during deployment if some of the permissions are missing. **The best approach is to provide minimal permission but to do that you need to thouroughly test deployment by adding/removing individual permission.**

- We will attach a new custom permission to our user group so that the account can manage AWS Lightsail. To do that, navigate to **user group > Permissions > Add permissions > Create inline policy > JSON**. Then copy the following JSON file to the editor and save it with a meaningful name.

```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"lightsail:GetRelationalDatabaseEvents",
				"lightsail:GetActiveNames",
				"lightsail:GetOperations",
				"lightsail:GetBlueprints",
				"lightsail:GetBundles",
				"lightsail:GetRelationalDatabaseMasterUserPassword",
				"lightsail:ExportSnapshot",
				"lightsail:UnpeerVpc",
				"lightsail:GetRelationalDatabaseLogEvents",
				"lightsail:GetRelationalDatabaseBlueprints",
				"lightsail:GetRelationalDatabaseBundles",
				"lightsail:CopySnapshot",
				"lightsail:GetRelationalDatabaseMetricData",
				"lightsail:PeerVpc",
				"lightsail:IsVpcPeered",
				"lightsail:UpdateRelationalDatabaseParameters",
				"lightsail:GetRegions",
				"lightsail:GetOperation",
				"lightsail:GetDisks",
				"lightsail:GetRelationalDatabaseParameters",
				"lightsail:GetBundles",
				"lightsail:GetRelationalDatabaseLogStreams",
				"lightsail:ImportKeyPair",
				"lightsail:DeleteKeyPair",
				"lightsail:GetInstance",
				"lightsail:DeleteInstance",
				"lightsail:GetDomains",
				"lightsail:GetDomain",
				"lightsail:DeleteDomain",
				"lightsail:GetStaticIp",
				"lightsail:AllocateStaticIp",
				"lightsail:AttachStaticIp",
				"lightsail:DetachStaticIp",
				"lightsail:ReleaseStaticIp",
				"lightsail:Create*",
				"lightsail:TagResource"
			],
			"Resource": "*"
		}
	]
}
```
This provides the user access to manage Lightsail instances.

**Bug fix Note: You will notice that I have provided access to all resources by using Resource: "*". However, in practice we should only provide access to the required resource. But using region specific reason was throwing unauthorized error during deployment for some reason. We need to fix it later.**

### 1.2 Create a S3 Bucket for Terraform state management

- Navigate to [AWS S3](https://us-east-1.console.aws.amazon.com/s3/get-started) and create a new bucket. You can provide a meaningful name. For my purposes, I have used the name 'myportfolioinfrastructurebucket'. The bucket needs to be private as Terraform can access it using the access key.

- Select an appropriate AWS region. I usually keep the region same for all the services used by one system to avoid cross-region configuration.

- Click on 'Create bucket'. Provide a bucket name and select 'ACLs disabled'. Make sure that 'Block all public access' is selected. You can enable 'Bucket Versioning' if you desire.

- Navigate to the newly created bucket and create a new folder where Terraform will save its state information.

### 1.3 Generate access key for the user

To manage our AWS resources via Terraform and GitHub, we need to generate an access key that Terraform will use to access the AWS resources. To generate an access key navigate to the user account inside IAM > Users and do the following:

- Navigate to 'Security credentials'.

- Scroll down to the section called 'Access keys' and click on 'Create access key'.

- Select 'Application running outside AWS' for 'Use case' as we will access AWS from Github.

- Click Next and complete rest of the configuration until you receive the access key and secrey key. Keep a note of these as we will use it when creating our CI/CD pipeline for Terraform.

- To test that the key was generated successfully, you can navigate to the '.aws' folder in your computer's profile directory. This folder is created by [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). Open the file called 'credentials' and add the following to the file:

```
[myaws]
aws_access_key_id = some_access_key
aws_secret_access_key = some_secret_key
```

Here, 'myaws' is name of the profile that you mentioning when trying to use the credentials. You need to add this to 'variables.tf' file of Terraform.

## 2. Generating ssh key for lightsail

1. Generate a SSH key using the following command:

```
ssh-keygen -q -t rsa -b 2048 -N '' -f ~/.ssh/myportfolio && chmod 400 ~/.ssh/myportfolio
```

2. Import the key to lightsail using the command:

```
aws lightsail import-key-pair --key-pair-name my_portfolio_github_actions_terraform --public-key-base64 file://./myportfolio.pub
```

**Note: You need to have AWS CLI installed for this and AWS account available. To configure AWS CLI, visit [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)**


## 3. Configuring the terraform codebase

The terraform codebase is located inside infrastructure/aws/terraform directory. It contains all the configuration required to deploy and manage an AWS Lightsail instance to terraform. **However, you need to update the following variables to suit your need:**

### 3.1 Filename provider.tf

This file contains the code for S3 configuration. Terraform will store the deployment configuration files there. Update the following parameters:

1. region: Use the AWS region in which you have created your S3 bucket. For example, ap-south-1.

2. bucket: Provide the name of the bucket that you created in the first step.

3. key: The name of the key should be the path inside the bucket where Terraform will save its state file. For example, in my case I created a folder called 'myportfolioinfrastructurebucket' inside the S3 bucket. So, the value for my key will be 'myportfolioinfrastructurebucket/terraform.tfstate'.

### 3.2 variables.tf

This file contains the variables used by the Terraform. It contains the following parameters:

1. region: The AWS region being used by your services. Terraform will create Lightsail instance in that region.

2. profile: The profile being used in your 'credentials' file of your AWS CLI. For more information on credentials please read the documentation related to [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

3. vps_configuration_script_path: You do not need to update the path of this file as I have already kept the file in this repository. This file configures docker after installing the Lightsail instance.

### 3.3 AWS Lightsail pricing

The pricing of your AWS Lightsail instance will depend on the 'bundle_id' that you set in modules/lightsail/variables.tf file. I have used 'small_3_1'. You can see the list of the available bundles and pricing by running the following command in your AWS CLI:

```
aws lightsail get-bundles
```

You can find more documentation related to it in [Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lightsail_instance) and [AWS documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lightsail/get-bundles.html). You can always start with a small instance and increase the size from your Terraform configuration. **But please do remember, changing the instance type may or may not create a new instance with your existing applications installed in it (I have not tried that approach yet). If it does recreate a new instance without the applications, you need to redeploy your applications installed in the VPS. If all your applications have a CI/CD pipeline, all you need to do is update the pipeline variables to point to your new instance and perform a redeploy of your latest changes - simple as that!**

### 3.4 Updating the GitHub Actions pipeline

The repository already contains the pipeline configuration in .github/workflows/ folder. However, you need to create the required 'Secrets and Variables' in your Github repository so that Terraform can fetch the secret variables from the environment. To learn more about secrets and variables, please visit [Github documentation](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions).

- Navigate to the repository where you uploaded the infrastructure codebase and then to 'Settings > Secrets and variables > Actions'. Make sure that you have the administrative access to the repository and its secrets. Navigate to the 'secrets' tab and click on 'New repository secret'.

- Add the following secrets:

    - AWS_ACCESS_KEY_ID: This is the access key that you created for your terraform deployment user.

    - AWS_SECRET_ACCESS_KEY: This is the secret access key returned by the user in your AWS account that you created for deployment.

    - BUCKET_TF_STATE: This will contain name of the S3 bucket where you want to store your Terraform state files.


### 3.5 Updating the vps_configuration_script.sh

The file infrastructure/aws/terraform/configuration/scripts/vps_configuration_script.sh contains the code that will be executed by Terraform after creating a new instance. The script installs docker and creates a network called 'my-portfolio-network'. This is the external network that will be used by all containers running in the system. Replace this with the name of your own network.

### 3.6 Try your first deployment

That's it! These are all the configurations that you need to update to deploy your own Lightsail instance to AWS and manage it through Terraform and CI/CD pipeline. **Always make sure to check the pricing before using any AWS resources to keep your cost under control.** To run your first deployment, navigate to your 'GitHub repository > Actions'. Select 'Terraform Build' and click 'Run workflow'. This will run a build to check the Terraform configuration and state. Don't worry. Running the build will not actually deploy the resources but it will run a simulation to check that everything is configured properly. If the build succeeds and you are confident enough, run 'Terraform Deployment' pipeline to deploy your resources to AWS. Cheers!


### 3.6 Check your Lightsail instance

Once the deployment succeeds, you can navigate to your AWS console to make sure that your Lightsail instance was configured properly. Then you can ssh into your Lightsail instance using the SSH key that you generated in step 2.

```
ssh -i ~/.ssh/myportfolio ubuntu@<ip addres of lightsail>
```

Once you successfully SSH into your VPS, make sure that docker is running using the following command:

```
docker container ls
```

Install nginx by running the commands provided in infrastructure/aws/terraform/configuration/scripts/install_nginx.sh. You can also modify your 'vps_configuration_script.sh' file to include the code for nginx installation there. This will install nginx when Terraform creates the Lightsail instance. But I like to keep it separate, as we may use different web servers in different instances. Once the installation succeeds, visit your nginx server by navigating to the ip address of your server e.g. http://3.5.52.13. It should show you the nginx welcome screen.

Finally, if you have a domain, update your DNS records to point your domain to the IP address of your server. If the site works with IP address but not with domain (e.g. http://vip3rtech6069.com), wait for a while to let your domain complete its DNS propagation. If it does not show up after that, you may need to configure 'Domain & DNS' in your lightsail account. You can find the DNS server configuration in AWS Account > Lightsail > Domain & DNS > Domains.

### 3. 7 Configuring the Domain & DNS

- Navigate to your AWS account and browse to 'Lightsail'.

- Navigate to 'Domain & DNS' tab and then to 'DNS records'.

- Click on 'Add record' and create a 'A' record to route requests from your domain to the Lightsail ip. Add the following record:

| Record name | Record Type | Resolves to |
| --- | --- | --- |
| vip3rtech6069.com | A record | 3.5.52.13 |

Replace the record name with your domain and the resolved IP address to your Lightsail public IP.

## 4. Post Deployment Configration

In this section we will discuss about installing the different software required to run and manage web applications in the VPS. For example, we need to:

- Configuring nginx

- Adding configuration for reverse proxy to access our applications using our domain.

- Configure SSL using Let's encrypt.

For this step, you need to have your nginx installed and atleast one application running on a local port (preferrably via Docker) to which nginx will route your requests.

### 4.1 Creating the nginx configuration file

1. SSH into your Lightsail instance.

2. Navigate to nginx directory using the following command:

```
cd /etc/nginx/sites-available
```
3. Create a new configuration file for your domain. For example, if your domain is vip3rtech6069.com, the nginx configuration file will be as follows:

```
server {
  server_name vip3rtech6069.com 3.5.52.13;

  access_log  /var/log/nginx/vip3rtech6069.com.log;
  error_log /var/log/nginx/vip3rtech6069.error.log;

  location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header    X-Forwarded-For    $proxy_add_x_forwarded_for;
    proxy_set_header    X-Forwarded-Proto  $scheme;
    proxy_set_header    X-Forwarded-Host   $host;
    proxy_set_header    X-Forwarded-Port   $server_port;
    proxy_set_header    X-Real-IP          $remote_addr;

  }

  listen 80;
  listen [::]:80;

}
```

Make sure to replace the url of 'proxy_pass' with the URL in which your application is running locally inside the VPS. Also replace 'vip3rtech6069.com' with your domain and '3.5.52.13' with your Lightsail IP. Save the file.

4. Link your nginx configuration file using the following command:

```
sudo ln /etc/nginx/sites-available/vip3rtech6069.com /etc/nginx/sites-enabled/vip3rtech6069.com
```

Replace 'vip3rtech6069.com' with your configuration file name.

5. unlink the default configuration file using the following command:

```
sudo rm /etc/nginx/sites-enabled/default
```

5. Test your nginx configuration using:

```
sudo nginx -t
```

If the configuration succeeds, restart your nginx server using:

```
sudo service nginx restart
```

### 4.2 Configuring SSL

To configure SSL with our application, we will use [let's encrypt](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04). The commands provided in infrastructure/configuration/nginx_configurations/install_ssl.sh can be used to configure SSL.

```
#!/bin/bash
sudo apt install certbot python3-certbot-nginx

sudo certbot --nginx -d vip3rtech6069.com

# Query status
sudo systemctl status certbot.timer
sudo certbot renew --dry-run


# Autorenwal section starts here
# Add the following line to /etc/crontab using command: sudo crontab -e
# 0 12 * * * /usr/bin/certbot renew --quiet
```

Replace vip3rtech6069.com with your own domain. **If you configure your domain before creating the instance in AWS, you should be able to customize the vps_configuration_script.sh file to install and configure SSL when the instance starts.**

### 4.3 Enable HTTPS port

Enable HTTPS port in your Lightsail instance to allow HTTPS traffic. Currently, Terraform does not allow adding such rules for AWS (reference: [Stackoverflow](https://stackoverflow.com/questions/58754160/how-to-set-up-a-firewall-rule-using-terraform-for-an-aws-lightsail-instance)). Therefore, I have configured it manually from AWS. However, you can run the AWS CLI command through Terraform as mentioned in the [document](https://stackoverflow.com/questions/58754160/how-to-set-up-a-firewall-rule-using-terraform-for-an-aws-lightsail-instance).