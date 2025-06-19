# Deployment and provissioning know how

This is help file for provissioning and deploying this application, but not limited to that.

## Provissioning

You should setup your server and add public key to that, key should be available on the host you
are calling ansible from.

- python3 -m venv .venv/
- source .venv/bin/activate
- install ansible `pip3 install ansible`
- install passlib pip3 install passlib
- modify host file to include production servers
- test ansible by running ansible command from this directory `ansible prod -m ping -u root`
- run provissioning playbook `ansible-playbook ./provision.yml`
- run setup playbook `ansible-playbook ./setup.yml --ask-vault-pass` to setup needed structure and files for the project

## Deployment

When provissioning and setup is done on the server. One can deploy the application.

- checkout correct application tag `git checkout v0.1.3` if needed
- run deployment playbook `ansible-playbook --extra-vars app_version=0.1.0 ./deploy.yml`

This will ask for vault password, its in iCloud passwords for `kood.pro` `Vault`

> [!IMPORTANT]
> All secrets should be encrypted with the same vault password using following command, before adding to playbook. [OK Vault Guide](https://www.edureka.co/blog/ansible-vault-secure-secrets)

- ansible-vault encrypt_string 'Some_secret_1' --name 'app_secret_key'

> [!IMPORTANT]
> To decrypt in case you forgot some secret

- echo '$ANSIBLE_VAULT;1.1;AES256 ... with all enters and without witespace' | ansible-vault decrypt --output=stats_password.txt'

## SSL certs request with ansible

- run deployment ansible during the setup it will create private key and CSR and also display CSR
- copy CSR into CAs webpage
- you will need to run ansible deploy second time once you have the certs signed and received
- copy signed certs into `roles/project/files` and running deploy add extra var `app_ca_path=~/code/project/ansible/roles/project/files/`
- mentioned directory should contain `kood.crt` and `kood.ca-bundle` from CA authority

## SSL certs request and install manually

- to generate new csr and also new private key:

    > openssl req -key kood.key.pem -new -sha256 -out kood.csr.pem

- to use existing key and generate new CSR (certificate signing request):

    > openssl req -new -key certs/kood.key.pem -out certs/kood.2023.csr.pem

- CSR will need to be copied into SSL certificate authority page
- After CSR will be signed, to activate it you should prove that you are the owner of the domain name (there are several options, DNS TXT record seems the easiest)
- when receive certificate and ca-bundle need to convert them for use in nginx:

    > cat www_kood.crt www_kood.ca-bundle > kood.2023.cert.pem

- then you can symlink new certificate to correct place

    > ln -s /abs/path/to/certs/kood.2023.cert.pem /abs/path/to/certs/kood.cert.pem

- nginx should use the kood.cert.pem and private key used for CSR signing

- test the ssl afterwards, for example SSL labs or other sites/tools can be used
