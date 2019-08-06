## Download ansible roles

```
$ ansible-galaxy install --force -r requirements.yml -p roles
```

## Set alicloud access_key and security_key

```
$ export ALICLOUD_ACCESS_KEY=<access_key>
$ export ALICLOUD_SECRET_KEY=<security_key>
```

## Create resources

```
$ terraform init
$ terraform plan
$ terraform apply
```

## Destroy resources

```
$ terraform destroy
```