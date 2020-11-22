# Weather Forecast API

A Terraform project to deploy weather-forcast API to AWS EKS. The resources that it creates are:
* EKS cluster with one worker node
* Ingress resource
* AWS ALB Ingress Controller

## Assumptions
* _APIKey_ should be stored in AWS secret manager as a plain_text secret called _apikey-secret_
* Make sure that the user has the required permissions to access the cluster
* User's AWS credentials should be set as environment variables
  | Environment Variable | Description |
  |------|-------------|
  | AWS_ACCESS_KEY_ID | AWS Access key ID|
  | AWS_SECRET_ACCESS_KEY | AWS Secret Access Key |
  | AWS_DEFAULT_REGION | AWS Region |

## Getting started
You can deploy the code either from you local machine or through Github action as below.

### Deploy from Github Action
[_Github Action_](https://github.com/skianoosh/wooliesx-weather-api/actions) has been configued and can be manually triggered to deploy the infra to AWS:  
![Alt text](github.jpg?raw=true "Title")

### Deploy from local
Run these in command line:

* cd infra
* terraform init
* terraform plan
* terraform apply (You'll be asked to enter the APIKey)

### How to access the API:
The output of the _terraform apply_ is the DNS name of the API, in happy scenario _/health_ should return _Healthy_.

### Usage example

```
$ terraform init
....
$ terraform plan
.....
$ terraform apply --auto-approve
....
....

Outputs:

weather_alb_dns_name = k8s-default-weatheri-XXXXXXX-XXXXXX.ap-southeast-2.elb.amazonaws.com

$ curl weather_alb_dns_name = k8s-default-weatheri-XXXXXXX-XXXXXX.ap-southeast-2.elb.amazonaws.com/health

200 OK
Healthy


```

### TODO

1. Setup HTTPS and external-dns of the ingress controller to automagically create relevant domain name in Route53, and then communicate the name servers with your domain name provider.
2. Replace EKS worker group by EKS Fargate
3. Export the API through and API Gateway:
* AWS API Gateway
* Ingress Controller API Gateways such as [Kong API Gateway](https://konghq.com/kong/)
