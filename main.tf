#############################################
#Define the providers to use
#############################################

provider "ibm" {
  softlayer_username = "${var.ibm_sl_username}"
  softlayer_api_key = "${var.ibm_sl_api_key}"
}

########################################################
#Create SSH key for VSIs
########################################################

resource "ibm_compute_ssh_key" "ssh_key" {
  label = "${var.ssh_label}"
  notes = "${var.ssh_notes}"
  public_key = "${var.ssh_key}"
}

##################################################
#Create web file storage
##################################################

resource "ibm_storage_file" "webVS" {
  type = "Performance"
  datacenter = "${var.datacenter}"
  capacity = "20"
  iops = "100"
}

##################################################
#Create app file storage
##################################################

resource "ibm_storage_file" "appVS" {
  type = "Performance"
  datacenter = "${var.datacenter}"
  capacity = "20"
  iops = "100"
}
########################################################
#Create Web Tier VS
########################################################

resource "ibm_compute_vm_instance" "burstvs" {
  count = "2"
  os_reference_code = "${var.osrefcode}"
  hostname = "${format("webvs-%02d", count.index + 1)}"
  domain = "${var.domain}"
  datacenter = "${var.datacenter}"
  file_storage_ids = ["${ibm_storage_file.burstvs.id}"]
  network_speed = 10
  cores = 1
  memory = 1024
  disks = [25, 10]
  ssh_key_ids = ["${ibm_compute_ssh_key.ssh_key.id}"]
  local_disk = false
  # undefined module- security
  # private_security_group_ids = "${module.security.sg1_id}"
  private_vlan_id = "${var.privatevlanid}"
}

########################################################
#Create App Tier VS
########################################################

resource "ibm_compute_vm_instance" "burstvs" {
  count = "2"
  os_reference_code = "${var.osrefcode}"
  hostname = "${format("appvs-%02d", count.index + 1)}"
  domain = "${var.domain}"
  datacenter = "${var.datacenter}"
  file_storage_ids = ["${ibm_storage_file.burstvs.id}"]
  network_speed = 10
  cores = 1
  memory = 1024
  disks = [25, 10]
  ssh_key_ids = ["${ibm_compute_ssh_key.ssh_key.id}"]
  local_disk = false
  private_security_group_ids = "${module.security.sg1_id}"
  private_vlan_id = "${var.privatevlanid}"
}
