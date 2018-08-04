# Kubernetes Cluster

### Installation

- `brew install gnu-sed jq awscli terraform`
- `cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH`
- `echo 'export PATH=$HOME/bin:$PATH' >> ~/.bash_profile`
```
`kubectl version --short --client`
Example output:

Client Version: v1.10.3
```

### Getting Started

We are Using EKS to setup/manage Kubernetes cluster. Also we are Using it with terraform, so that infrastructure can be git commited. Then we have all the power of revision control (Answer "what/why changed?" if we write good commit messages, so please do!!).


### How to modified cluster?

- `cd` into this project
- Edit whichever file is needed.
- Verify Changes Using `terraform`
    ```sh
    terraform plan | less
    ```
- Modify Cluster Using `terraform`
    ```sh
    terraform apply
    ```
- Push all changes to GitHub with commit message containing what and why these changes.
