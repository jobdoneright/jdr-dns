.PHONEY: all

all:
	terraform init
	terraform apply -auto-approve
