packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "docker" "voting_app" {
  image  = "python:3.13"
  commit = true

  changes = [
    "WORKDIR /app/azure-vote",
    "EXPOSE 80",
    "CMD [\"python\", \"main.py\"]"
  ]
}

build {
  sources = ["source.docker.voting_app"]

  provisioner "shell" {
    inline = ["pip install --quiet ansible"]
  }

  provisioner "ansible-local" {
    playbook_file  = "./playbook.yml"
    playbook_dir   = "."
    inventory_file = "./inventory"
  }

  post-processor "docker-tag" {
    repository = "voting-app"
    tags       = ["latest"]
  }
}
