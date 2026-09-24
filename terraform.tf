provider "aws" {
  region = "eu-west-1"
}

#
# Modules come from the Terraform registry, pinned to an exact version.
#
#   https://registry.terraform.io/modules/jobdoneright/google-workspace-dns/aws
#
# These blocks previously sourced github.com/jobdoneright/r53-gsuite-mx-cname
# unpinned. That repository was renamed and published on 2026-09-23, and its
# master now requires `aws >= 4.0`, which conflicts with the old `~> 2.0`
# constraint and fails init.
#
# The module renamed its resources and moved the CNAMEs from `count` to
# `for_each`. Its `moved` blocks cover the default `gsuite_cnames` list, which
# every block here uses, so the first plan should show moves and no record
# changes.
#
# Exact version, not `~> 0.2`: a 0.x minor may break. Bumping is a pull request.
#

# jobdoneright.ie
# jobdoneright.mobi
# jobdoneright.co.uk

module "jobdoneright_ie" {
  source   = "jobdoneright/google-workspace-dns/aws"
  version  = "0.2.0"
  dns_zone = "jobdoneright.ie"
}

module "jobdoneright_co_uk" {
  source   = "jobdoneright/google-workspace-dns/aws"
  version  = "0.2.0"
  dns_zone = "jobdoneright.co.uk"
}

module "jobdoneright_mobi" {
  source   = "jobdoneright/google-workspace-dns/aws"
  version  = "0.2.0"
  dns_zone = "jobdoneright.mobi"
}

# enablingenergy.net
# enablingenergy.org
# greenislandcommunications.com
# greenislandcommunications.net
