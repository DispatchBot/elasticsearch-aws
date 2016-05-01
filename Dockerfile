FROM elasticsearch:2.3.2

# Install the AWS plugin
RUN /usr/share/elasticsearch/bin/plugin install cloud-aws

# Plugin to report key metrics to statsd
RUN /usr/share/elasticsearch/bin/plugin install com.automattic/elasticsearch-statsd/2.3.0.0

RUN ulimit -n 65536
