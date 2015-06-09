# Elasticsearch-aws

This docker image runs elasticsearch with the (AWS plugin)[https://github.com/elastic/elasticsearch-cloud-aws] installed. We use it to
run elasticsearch on (AWS ECS)[http://aws.amazon.com/ecs/].

## Base Image

We base our image from the official (docker elasticsearch)[https://registry.hub.docker.com/u/library/elasticsearch/]. Please refer to this resource for documentation on running, mounting and configuring elasticsearch with docker.

## Setup

You can begin deploying the image to existing infrastructure. However, if you have not built out an AWS cluster yet, we can help. Setup will be in two parts: 1) Bootstrap the AWS infrastructure using a (cloudformation)[http://aws.amazon.com/cloudformation/] template, and 2) create an ECS cluster with a task definition.

### Cloudformation
There is a cloudformation template provided at `aws/cloudformation/elasticsearch-cluster.json`. This will create all the resources needed to start running elasticsearch using the AWS container service. A number of the configuration options are exposed as parameters for you to input/select while creating your cloudformation.

Some pre-reqs to running this template:

* Create a VPC with three subnets, existing in each of the availability zones (TODO: link our VPC cloudformation template).
* Create an S3 bucket to host your `elasticsearch.yml` and `logging.yml` configuration files. Samples are provided in this repo.

### ECS

The `aws/ecs/elasticsearch.json` file provides the task builder json definition for the elasticsearch containers.
