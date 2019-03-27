put here your private and public keys to access bastion server
the name should be 

* deployer-key
* deployer-key.pub

under the linux you can use the following command to generate key pair:

```
ssh-keygen -t rsa -f ./deployer-key
```

you can change location and filename name in `<ROOT>/terraform/aws/variables.tf`
