FROM elasticsearch:1.7.1

# Install the head plugin
RUN /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head

# Install the AWS plugin
RUN /usr/share/elasticsearch/bin/plugin install elasticsearch/elasticsearch-cloud-aws/2.7.0
