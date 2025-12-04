#add Hostname and instance type as below format to provision servers.
instances = {
  AWSUSER1 = { instance_type = "t2.micro" }
  AWSUSER3 = { instance_type = "t3.small" }
}

ami_id    = "ami-0fa3fe0fa7920f68e"
subnet_id = "subnet-06c54934528a298fb"
tags = {
  Owner     = "A2232"
  createdby = "terraformadmin"

}

tags-all = {
  Application = "sandbox"
  availablity = "24*7"
  Projectcode = "TGSYE8899"
}
