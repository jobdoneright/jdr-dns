# jobdoneright.ie
# jobdoneright.mobi
# jobdoneright.co.uk

module "jobdoneright_ie" {
  source   = "github.com/jobdoneright/r53-gsuite-mx-cname"
  dns_zone = "jobdoneright.ie"
}

module "jobdoneright_co_uk" {
  source   = "github.com/jobdoneright/r53-gsuite-mx-cname"
  dns_zone = "jobdoneright.co.uk"
}

module "jobdoneright_mobi" {
  source   = "github.com/jobdoneright/r53-gsuite-mx-cname"
  dns_zone = "jobdoneright.mobi"
}

# enablingenergy.net
# enablingenergy.org
# greenislandcommunications.com
# greenislandcommunications.net
# hillsboroughparish.org.uk

