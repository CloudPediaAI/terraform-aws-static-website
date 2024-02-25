variable "domain_name" {
  type        = string
  description = "Domain for the Static Website eg. mywebsite.com"
  validation {
    condition = (can(regex("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])\\.)*([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])$", var.domain_name))
      && !strcontains(var.domain_name, "..")
      && !startswith(var.domain_name, "xn--")
      && !startswith(var.domain_name, "sthree-")
      && !endswith(var.domain_name, "-s3alias")
    && !endswith(var.domain_name, "--ol-s3"))
    error_message = "Provide a valid domain name. Since S3 bucket will be created with the same name, all bucket naming rules are applicable here.  Please refer https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html"
  }
}

variable "hosted_zone_id" {
  type        = string
  default = null
  description = "Id of the Hosted Zone in Route 53"
}

variable "need_www_redirect" {
  type        = bool
  default     = false
  description = "Whether redirect from wwww required or not. If yes, this module will create 2 sites with domain_name.com and www.domain_name.com"
}

variable "s3_access_method" {
  type = string
  default = "public"
  description = "Access method for S3: OAC/OAI/public"
  validation {
    condition     = contains(["oac", "oai", "public"], lower(var.s3_access_method))
    error_message = "Unsupported method <${var.s3_access_method}>. Supported values are <OAC, OAI, public>"
  }  
}

variable "website_source_folder" {
  type        = string
  default     = null
  description = "Source folder of your website build"
}

variable "tags" {
  type = map(any)
  description = "Key/Value pairs for the tags"
  default = {
    created_by = "Terraform Module cloudpediaai/static-website/aws"
  }
}
