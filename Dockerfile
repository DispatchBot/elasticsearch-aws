FROM elasticsearch:2.3.0

# Install the AWS plugin
RUN /usr/share/elasticsearch/bin/plugin install cloud-aws
