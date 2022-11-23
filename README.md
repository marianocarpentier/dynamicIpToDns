# dynamicIpToDns
I created this little script to be able to keep a DNS record up to date pointing to my home dynamic IP address. Uses AWS Route 53.

## Pre-requisites
 - Curl. Run if Debian based distro: `sudo apt install curl`
 - [AWS account](https://aws.amazon.com/console/)
 - [AWS Cli](https://aws.amazon.com/cli/) In my case I  will be running this script in a Raspberry Pi 4 with Ubuntu, So I installed it following this:
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#cliv2-linux-install
Note that since RPi is ARM you need to get the 'Linux ARM' version.
 - Follow the guide to link your AWS account: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html
 - Domain Route 53 where you can create an `A Record`

## Instructions
 - Create a user in the AWS console (IAM) that can alter Route53 records. Get access and secret keys.
 - Find your Hosted Zone ID for the record you want to alter in the Route 53 console.
 - Find the record name you want to alter
 - Create a file named `settings.properties` with the values from the previous steps. Use  `settings.properties.sample`
 - To run automatically use `cron` [How do I set up a Cron job?](https://askubuntu.com/questions/2368/how-do-i-set-up-a-cron-job)
My cron expression is:
`* * * * * touch /tmp/syncDns.log && /home/mariano/development/dynamicIpToDns/syncDns.sh >> /tmp/syncDns.log`