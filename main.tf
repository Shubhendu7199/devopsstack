// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("${var.credentials}")}"
  project     = "${var.gcp_project}"
  region      = "${var.region}"
}


//Harbor Instance (Ashoks Harbor)
resource "google_compute_address" "hbip" {
  name   = "${var.harbor_instance_ip_name}"
  region = "${var.harbor_instance_ip_region}"
}



resource "google_compute_instance" "harbor" {
  name         = "${var.harbor_instance_name}"
  machine_type = "${var.harbor_instance_machine_type}"
  zone         = "${var.harbor_instance_zone}"


  tags = ["name", "harbor", "http-server"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20180129"
    }
  }
  // Local SSD disk
  #scratch_disk {
  #}

  network_interface {
    # network = "default"

    network    = "${var.harbor_instance_vpc_name}"
    subnetwork = "${var.harbor_instance_subnet_name}"
    access_config {
      // Ephemeral IP
      nat_ip       = "${google_compute_address.hbip.address}"
      network_tier = "PREMIUM"
    }
  }



  metadata = {
    name = "harbor"
  }
  description             = "${google_compute_address.hbip.address}"
  metadata_startup_script = "sudo yum update -y; sudo yum install git -y; sudo yum install wget -y; git clone https://github.com/iamdaaniyaal/devopsstack.git; cd devopsstack; sudo chmod 777 hb.sh; sh hb.sh"


  service_account {
    scopes = ["cloud-platform"]
  }
  # metadata_startup_script = "sudo yum update; sudo yum install wget -y; sudo  echo \"root123\" | passwd --stdin root; sudo  mv /etc/ssh/sshd_config  /opt; sudo touch /etc/ssh/sshd_config; sudo echo -e \"Port 22\nHostKey /etc/ssh/ssh_host_rsa_key\nPermitRootLogin yes\nPubkeyAuthentication yes\nPasswordAuthentication yes\nUsePAM yes\" >  /etc/ssh/sshd_config; sudo systemctl restart  sshd;sudo useradd test; sudo echo  -e \"test    ALL=(ALL)  NOPASSWD:  ALL\" >> /etc/sudoers;"
}



//Jenkins Instance

resource "google_compute_address" "jip" {
  name   = "${var.jenkins_instance_ip_name}"
  region = "${var.jenkins_instance_ip_region}"
}

# data "template_file" "mydeamon" {
#   # template = "${file("conf.wp-config.php")}"

#   template = templatefile("${path.module}/mydeamon.json", { jenkinsip = "${google_compute_address.jenkinsip.address}" })

# }

resource "google_compute_instance" "jenkins" {
  name         = "${var.jenkins_instance_name}"
  machine_type = "${var.jenkins_instance_machine_type}"
  zone         = "${var.jenkins_instance_zone}"

  tags        = ["name", "jenkins", "http-server"]
  description = "${google_compute_address.sonarip.address}+${google_compute_address.hbip.address}"

  boot_disk {
    initialize_params {
      image = "centos-7-v20180129"
    }
  }

  // Local SSD disk
  #scratch_disk {
  #}


  network_interface {
    network    = "${var.jenkins_instance_vpc_name}"
    subnetwork = "${var.jenkins_instance_subnet_name}"

    access_config {
      // Ephemeral IP

      nat_ip       = "${google_compute_address.jip.address}"
      network_tier = "PREMIUM"
    }
  }





  metadata = {
    name = "jenkins"
  }


  # metadata_startup_script = "sudo yum update -y; sudo yum install wget -y; sudo  echo \"root123\" | passwd --stdin root; sudo  mv /etc/ssh/sshd_config  /opt; sudo touch /etc/ssh/sshd_config; sudo echo -e \"Port 22\nHostKey /etc/ssh/ssh_host_rsa_key\nPermitRootLogin yes\nPubkeyAuthentication yes\nPasswordAuthentication yes\nUsePAM yes\" >  /etc/ssh/sshd_config; sudo systemctl restart  sshd;sudo useradd test; sudo echo  -e \"test    ALL=(ALL)  NOPASSWD:  ALL\" >> /etc/sudoers; sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo; sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key; sudo yum install jenkins maven google-cloud-sdk kubectl -y; sudo  wget -O  /opt/docker.sh  https://get.docker.com && sudo chmod 755 /opt/docker.sh; sudo wget -P /opt/  https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip; sudo unzip /opt/sonar-scanner-cli-3.3.0.1492-linux.zip -d /opt  &&  sudo mv /opt/sonar-scanner-3.3.0.1492-linux  /opt/sonar-scanner"
  # metadata_startup_script = "sudo yum update -y; sudo yum install wget -y; sudo  echo \"root123\" | passwd --stdin root; sudo  mv /etc/ssh/sshd_config  /opt; sudo touch /etc/ssh/sshd_config; sudo echo -e \"Port 22\nHostKey /etc/ssh/ssh_host_rsa_key\nPermitRootLogin yes\nPubkeyAuthentication yes\nPasswordAuthentication yes\nUsePAM yes\" >  /etc/ssh/sshd_config; sudo systemctl restart  sshd;sudo useradd test; sudo echo  -e \"test    ALL=(ALL)  NOPASSWD:  ALL\" >> /etc/sudoers; sudo yum install git -y; sudo git clone https://github.com/iamdaaniyaal/gcpterraform.git; cd gcpterraform/scripts; sudo chmod 777 *.*; sudo sh jenkins.sh;"
  metadata_startup_script = "sudo yum update -y; sudo yum install git -y; sudo git clone https://github.com/iamdaaniyaal/devopsstack.git; cd devopsstack; sudo chmod 777 *.*; sudo sh jenkins.sh;"

  service_account {
    email  = "jenkinskubernetes@cloudglobaldelivery-1000135575.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }




}


//SonarQube Instance
resource "google_compute_address" "sonarip" {
  name   = "${var.sonar_instance_ip_name}"
  region = "${var.sonar_instance_ip_region}"
}


resource "google_compute_instance" "sonarqube" {
  name         = "${var.sonar_instance_name}"
  machine_type = "${var.sonar_instance_machine_type}"
  zone         = "${var.sonar_instance_zone}"

  tags = ["name", "sonarqube", "http-server"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20180129"
    }
  }

  // Local SSD disk
  #scratch_disk {
  #}

  network_interface {
    network    = "${var.sonar_instance_vpc_name}"
    subnetwork = "${var.sonar_instance_subnet_name}"


    access_config {
      // Ephemeral IP
      nat_ip = "${google_compute_address.sonarip.address}"
    }
  }
  metadata = {
    name = "sonarqube"
  }

  metadata_startup_script = "sudo yum update -y;sudo yum install git -y; sudo git clone https://github.com/iamdaaniyaal/devopsstack.git; cd devopsstack; sudo chmod 777 *.*; sudo sh sonarqube.sh;"
}



//ELK

resource "google_compute_address" "elkip" {
  name   = "${var.elk_instance_ip_name}"
  region = "${var.elk_instance_ip_region}"
}


resource "google_compute_instance" "elk" {
  name         = "${var.elk_instance_name}"
  machine_type = "${var.elk_instance_machine_type}"
  zone         = "${var.elk_instance_zone}"

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20190816"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    # network = "default"
    network    = "${var.elk_instance_vpc_name}"
    subnetwork = "${var.elk_instance_subnet_name}"


    access_config {
      // Ephemeral IP

      nat_ip       = "${google_compute_address.elkip.address}"
      network_tier = "PREMIUM"
    }
  }

  #metadata = {
  # foo = "bar"
  #}

  metadata_startup_script = "sudo apt-get update; sudo apt-get install git -y; sudo echo 'export ip='$(hostname -i)'' >> ~/.profile; source ~/.profile; echo \"export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\" >>/etc/profile; echo \"export PATH=$PATH:$HOME/bin:$JAVA_HOME/bin\" >>/etc/profile; source /etc/profile; mkdir chandu; cd chandu; sudo apt-get install wget -y; git clone https://github.com/iamdaaniyaal/devopsstack.git; cd devopsstack; sudo chmod 777 elk.sh; sh elk.sh"





}


//Kubernetes

resource "google_container_cluster" "primary" {
  name     = "${var.kube_cluster_name}"
  location = "${var.kube_cluster_location}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
#   remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

# resource "google_container_node_pool" "primary_preemptible_nodes" {
#   name       = "${var.kube_node_pool_name}"
#   location   = "${var.kube_node_pool_location}"
#   cluster    = "${google_container_cluster.primary.name}"
#   node_count = 1

#   node_config {
#     preemptible  = true
#     machine_type = "n1-standard-1"

#     metadata = {
#       disable-legacy-endpoints = "true"
#     }

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]
#   }
# }
