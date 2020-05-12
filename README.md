
## Prerequisites
1. Need an SSH key
2. Need a Security Group that is SSH open and HTTP open (maybe not).
3. Instance profile for future use, if not you can either create a dummy one with no permissions or just take it out of the script.

You should use a Compute intensive instance the one that is chosen in the script is a c5n.4xlarge.
This is a large instance type but it is needed since we are running about 14 or 15 docker containers.

Set the following variables in `script.sh`:
* __KEY\_PAIR\_NAME__ to an ssh key you can use to log into the instance.
* __AWS__ To the aws command you execute.
* __SECURITY\_GROUP\_Name__ A name of the security group you are using.
* __INSTANCE\_PROFILE__ Instance profile you will use.

Now run the script:
```
bash script.sh
```

Everything else should set up properly. Two files will be generated that makes it easy to manage
the one instance environment, `.instance_ip` and `.instance_ids`. They are used as such:

To log into the environment:
```
ssh -i ./KEY ec2-user@$(cat .instance_ip)
```

To delete the instance:
```
aws ec2 terminate-instance --instance-ids $(cat .instance_ids)
```

Once the instance is up and running and you can log into the instance and wait
for user-data script to complete:
```
sudo tail -f /var/log/cloud-init-
```

Once user-data script is done you should switch to the `quorum` user
and run docker-compose:
```
sudo su - quorum
cd quorum-example
docker-compose up -d
```

You should test out and make sure everything is working by following, https://github.com/jpmorganchase/quorum-examples#running-with-docker.
Step 6 demonstrates how to log into one of the nodes and execute a contract.

Now that everything is up and running you can log into each of the nodes and follow
the examples in https://github.com/jpmorganchase/quorum-examples/tree/master/examples/7nodes#demonstrating-privacy.

