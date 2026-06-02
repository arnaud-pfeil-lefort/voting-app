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

  # Ansible doit être disponible dans le conteneur pour ansible-local
  provisioner "shell" {
    inline = ["pip install --quiet ansible"]
  }

  # Lance le playbook depuis l'intérieur du conteneur
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
