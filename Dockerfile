# ELK4 Dockerfile
#
# VERSION 16.03.7
FROM ubuntu:14.04.4
MAINTAINER bsollar@redhat.com

# Setup env and apt
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y && \
    apt-get dist-upgrade -y

# Get and install packages
RUN apt-get install -y supervisor wget openjdk-7-jdk openjdk-7-jre-headless python-pip && \
    cd /root/ && \
    wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.3.4/elasticsearch-2.3.4.deb && \
    wget https://download.elastic.co/logstash/logstash/packages/debian/logstash_2.3.4-1_all.deb && \
    wget https://download.elastic.co/kibana/kibana/kibana_4.5.3_amd64.deb && \
    dpkg -i elasticsearch-2.3.4.deb && \
    dpkg -i logstash_2.3.4-1_all.deb && \
    dpkg -i kibana_4.5.3_amd64.deb && \
    rm -rf *.deb && \
    pip install elasticsearch-curator

# Setup user, groups and configs
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
ADD logstash.conf /etc/logstash/conf.d/logstash.conf
ADD kibana.svg /opt/kibana/src/ui/public/images/kibana.svg
ADD kibana.svg /opt/kibana/optimize/bundles/src/ui/public/images/kibana.svg
ADD elk.ico /opt/kibana/src/ui/public/images/elk.ico
ADD elk.ico /opt/kibana/optimize/bundles/src/ui/public/images/elk.ico
RUN addgroup --gid 2000 tpot && \
    adduser --system --no-create-home --shell /bin/bash --uid 2000 --disabled-password --disabled-login --gid 2000 tpot && \
    sed -i 's/# kibana.defaultAppId: "discover"/kibana.defaultAppId: "dashboard\/Default"/' /opt/kibana/config/kibana.yml && \
    mkdir -p /usr/share/elasticsearch/config && \
    cp -R /etc/elasticsearch/* /usr/share/elasticsearch/config/ && \
    chown -R tpot:tpot /usr/share/elasticsearch/ && \
    /opt/kibana/bin/kibana plugin -i tagcloud -u https://github.com/stormpython/tagcloud/archive/master.zip && \
    /opt/kibana/bin/kibana plugin -i heatmap -u https://github.com/stormpython/heatmap/archive/master.zip && \
    mkdir -p /data/ \
             /data/elk/ /data/elk/log/ /data/elk/data/ \
             /data/conpot/log/ \
             /data/cowrie/log/tty/ /data/cowrie/downloads/ /data/cowrie/keys/ /data/cowrie/misc/ \
             /data/dionaea/log/ /data/dionaea/bistreams/ /data/dionaea/binaries/ /data/dionaea/rtp/ /data/dionaea/wwwroot/ \
             /data/elasticpot/log/ \
             /data/glastopf/ \
             /data/honeytrap/log/ /data/honeytrap/attacks/ /data/honeytrap/downloads/ \
             /data/emobility/log/ \
             /data/ews/log/ /data/ews/conf/ /data/ews/dionaea/ /data/ews/emobility/ \
             /data/suricata/log/

# Clean up
RUN apt-get remove wget -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 5601 9200 9300

# Start ELK
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
