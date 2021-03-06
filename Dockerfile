#name of container: docker-dspace
#versison of container: 0.5.1
FROM quantumobject/docker-baseimage
MAINTAINER Angel Rodriguez  "angel@quantumobject.com"

# Set correct environment variables.
ENV HOME /root

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted " >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN apt-get update && apt-get install -y -q --force-yes python-software-properties \
                                            software-properties-common \
                                            postgresql \
                                            openjdk-7-jdk \
                                            tomcat7 \
                                            ant \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*


##startup scripts  
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't 
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh


##Adding Deamons to containers

# to add postgresqld deamon to runit
RUN mkdir /etc/service/postgresqld
COPY postgresqld.sh /etc/service/postgresqld/run
RUN chmod +x /etc/service/postgresqld/run

# to add tomcat7 deamon to runit
RUN mkdir /etc/service/tomcat7
COPY tomcat7.sh /etc/service/tomcat7/run
RUN chmod +x /etc/service/tomcat7/run

#pre-config scritp for different service that need to be run when container image is create 
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY dspace_tomcat7.conf /tmp/dspace_tomcat7.conf
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf \
    && /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf


##scritp that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convitation of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup
VOLUME /var/backups


# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 8080

#creatian of volume 
#VOLUME 

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
