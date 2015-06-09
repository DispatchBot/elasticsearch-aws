FROM elasticsearch:1.5.2

# Install the head plugin
RUN /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head

# Install the AWS plugin
RUN /usr/share/elasticsearch/bin/plugin install elasticsearch/elasticsearch-cloud-aws/2.5.1
