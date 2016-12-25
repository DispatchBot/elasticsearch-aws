FROM elasticsearch:5.1.1-alpine

# Install the AWS plugin
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install repository-s3
