## k0s_deploy

## Pre-requsite on the Machine/Laptop from where you execute.
Export the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN 
Install the k0sctl binary using "https://github.com/k0sproject/k0sctl/releases"

- Install the terraform
   https://learn.hashicorp.com/tutorials/terraform/install-cli
  ```python
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
  apt update && apt install terraform
  ```
- Install the k0sctl binary
  use the link https://github.com/k0sproject/k0sctl/releases/

## Installation ( Infra build & K0s installation )
- Terraform Steps
  ```python
   terraform init
   terraform apply
   terraform output -raw k0s_cluster | k0sctl apply --config -
  ```
NOTE: this assumes that `k0sctl` binary is available in the `PATH`
This will create a cluster with single controller and worker nodes.
If you want to override the default behaviour. Create a `terraform.tfvars` file with the needed details. You can use the provided `terraform.tfvars.example` as a template.

## k0sctl kubeconfig
Connects to the cluster and outputs a kubeconfig file that can be used with kubectl or kubeadm to manage the kubernetes cluster.
Example
```python
terraform output -raw k0s_cluster | k0sctl kubeconfig --config - > k0s.config
kubectl get node --kubeconfig k0s.config
NAME               STATUS   ROLES    AGE   VERSION
ip-172-31-42-117   Ready    <none>   75s   v1.26.2+k0s
ip-172-31-42-230   Ready    <none>   69s   v1.26.2+k0s
```
Note: You also save the kubeconfig to you $HOME/.kube, so that you don't need to mention path "--kubeconfig k0s.config"

## k0sctl reset
Uninstall k0s from the hosts listed in the configuration.

## To destroy the infra, run the below terraform command, this will destroy infra & k0s both.
```python
terraform destroy --auto-approve
```
