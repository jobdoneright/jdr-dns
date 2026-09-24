provider "aws" {
  region = "eu-west-1"
}

# Registry module, pinned to an exact version. The previous unpinned git source
# (github.com/jobdoneright/r53-gsuite-mx-cname) was renamed and published on
# 2026-09-23; its master requires aws >= 4.0 and broke init against ~> 2.0.
#
# The module's `moved` blocks cover the renamed resources and the CNAMEs'
# count -> for_each change for the default gsuite_cnames list, so the plan
# should show moves and no record changes. Exact version, not `~> 0.2`: a 0.x
# minor may break.

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

