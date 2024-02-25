# Static Website in AWS
This [Terraform module](https://registry.terraform.io/modules/cloudpediaai/static-website/aws/latest)  will create all required AWS resources to host a Static Website on S3 Bucket and distribute using CloudFront CDN.  This module will also host a simple __index.html__ file to show the message **Coming Soon** as a placeholder.

# Pre-requisites

Following are the pre-requisites to start using this module

1. Create a Hosted Zone in Router 53 with your domain name (eg. sample.com) and assign your domain name to variable **domain_name**. 
   
2. If the Hosted Zone name is different from the domain name (eg. admin.sample.com), assign Hosted Zone ID to the variable **hosted_zone_id**.  eg. if you created Hosted Zone with the root domain name (sample.com) and trying to create website with a sub-domain (eg. admin.sample.com), then you should provide Hosted Zone Id. if not, this module will retrieve Hosted Zone Id from Route 53 using domain name. 

3. Define 2 AWS providers. 
   1. One with __region = "us-east-1"__ an alias name (see below example).  This is to provision SSL/TLS certificate in US-East region.
   2. Default AWS provider with any region you would like to create S3 buckets for website hosting.  You can define an alias name if you want to specify the purpose (see below example), but alias is optional for default provider.

Below is code sample to declare providers  

```
# AWS provider for creating SSL/TLS certificate for your website
provider "aws" {
  profile = "profile name configured in %USERPROFILE%\.aws\credentials"
      or 
      access_key = "access key of IAM user created in your aws account"
      secret_key = "access secret of IAM user created in your aws account"
  region  = "us-east-1" # (AWS will create SSL/TLS certificate in US-East-1 region only)
  alias = "provder_for_ssl"
}

# default AWS provider for creating website and other resources
provider "aws" {
  profile = "profile name configured in %USERPROFILE%\.aws\credentials"  
      or 
      access_key = "access key of IAM user created in your aws account"
      secret_key = "access secret of IAM user created in your aws account"
  region  = "any-aws-region"
  alias = "provder_for_website" # (alias name for default provider is optional)
}
```

Here is sample code to execute the module and assign above declared providers

```
module "static-website-prod" {
  source  = "cloudpediaai/static-website/aws"
  version = "*.*.*"  # use latest version 
  domain_name = "your-domain.com"
  hosted_zone_id = "Id of Hosted Zone you created in Route 53"
  providers = {
    aws.us-east-1 = aws.provder_for_ssl
    aws = aws.provder_for_website     # assign aws if there is no alias provided above
  }
}
```

# What will this module do?

This module will create below resources:

1. Create a S3 bucket to host your website.
2. Create a S3 bucket to redirect from www.sample.com to sample.com (if you assign variable **need_www_redirect = true**) .
3. Create a SSL/TLS Certificate in AWS Certificate Manager (ACM) for the domain (sample.com) in US-East region.  Also add addition name www.sample.com if you like to redirect from www.sample.com to sample.com.  
4. Create a CloudFront distribution which is a Content Distribution Network (CDN) to speeds up the distribution of your website content to your users worldwide.  Also it will create one more CloudFront to redirect from www, if you assign variable **need_www_redirect = true**
5. Create A record in Route 53 Hosted Zone to route traffic to your website.
6. Host a placeholder website with a **Coming Soon** message, if you assign **need_placeholder_website = true**

Now you can host your own website to this S3 bucket.

# Security
## SSL/TLS Certificate

This module will create a SSL/TLS certificate (issued by AWS) which is used by CloudFront for all HTTPS connections.  **TLSv1.2_2021** is configured as Minimum version of the SSL/TLS protocol. 

## S3 Bucket Access Methods 
This module offers three options to configure the access to S3 bucket.  You can select your option by assigning OIC, OIA, or Public to the variable **s3_access_method**.  All three methods are explained below. 

### 1. Public Access
All objects in the S3 bucket will have PUBLIC-READ access.

### 2. Origin Access Control (OAC)

If you select OAC, this module will configure Origin Access Control (OAC) on CloudFrond to access objects from S3.  OAC restrict users to access S3 content through CloudFront only.  AWS recommend using OAC for its latest security best practices.

**How OAC works**

CloudFront service principal will sign each request with SigV4. The signature will then be included, along with additional data, to form an Authorization header which will be sent to your S3 origin. When your S3 origin receives this request, it will perform the same steps to calculate the signature and compare its calculated signature to the one CloudFront sent with the request. If the signatures match, the request is processed. If the signatures don’t match, the request is denied.

### 3. Origin Access Identity (OAI)

If you select OAI, this module will create an Origin Access Identity to restrict access through CloudFront.  Eventhough AWS recommends OAC, OAI will continue to work and you can continue to use OAI for new distributions.

# Cost Estimate
Below is the Monthly cost estimate you will incur when you use this module. 

| **Resource**	| **Cost**  |
|--------------|---------|
| S3 Buckets (Root and www)	|
|    -  Storage of less than 500MB data	                            | $0.15 |
|    -  Content access/requests by user (free as we use CloudFront)	| $0.00 |
| SSL/TLS certificates (free)	                                      | $0.00 |  
| CloudFront Distribution	                                          | $2.50 |
| Route 53 Hosted Zone	                                            | $0.60 |
| **Total Cost/Month**	|**$3.25**|
__*This cost is calculated based on US-East-1 pricing and is for your reference only, actual cost may vary.__

