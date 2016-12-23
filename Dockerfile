FROM elasticsearch:5.1.1-alpine

# Install the AWS plugin
RUN /usr/share/elasticsearch/bin/plugin install cloud-aws

RUN ulimit -n 65536
