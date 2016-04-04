FROM elasticsearch:2.2.2

# Install the AWS plugin
RUN /usr/share/elasticsearch/bin/plugin install cloud-aws
