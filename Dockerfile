FROM    ubuntu:precise
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update && apt-get upgrade
#Prevent daemon start during install
#RUN rm -rf /sbin/initctl && dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

# And then there is the locale-mess https://github.com/dotcloud/docker/issues/2424
RUN locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales && update-locale LANG=en_US.UTF-8 

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server && mkdir /var/run/sshd && \
        echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat build-essential make gcc gfortran redis-server unzip dialog

#Install Oracle Java 7
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main' > /etc/apt/sources.list.d/java.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer

#Install R 3+
RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu precise/' > /etc/apt/sources.list.d/r.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base r-base-dev libreadline6-dev libxt-dev libcairo2-dev libxml2-dev libcurl4-openssl-dev

#Begin RCloud
RUN R --vanilla -e "install.packages(c('devtools','Cairo', 'png', 'knitr', 'markdown', 'base64enc', 'rjson', 'uuid', 'RCurl'),,repos='http://cran.us.r-project.org')"
RUN R --vanilla -e "install.packages(c('Rserve','rediscc'),,repos='http://rforge.net')" #unixtools as well


# now install unixtoold because head is broken
RUN wget --no-check-certificate -O /tmp/unixtools.zip https://github.com/s-u/unixtools/archive/2c8e13b169e5eff7bf1cb200607db826d843bc7a.zip && \
    unzip -o /tmp/unixtools.zip -d /tmp/ && \
    R CMD INSTALL /tmp/unixtools-2c8e13b169e5eff7bf1cb200607db826d843bc7a/

# Install bundle and force install packages
RUN mkdir /data/ && \
    wget --no-check-certificate -O /tmp/rcloud.zip https://github.com/att/rcloud/archive/0.9.zip && \
    unzip -o /tmp/rcloud.zip -d /data/ && \
    mv /data/rcloud-0.9/ /data/rcloud/ && \
    cd /data/rcloud/ && mkdir run && \
    R CMD INSTALL rcloud.support/ && \
    R --vanilla -e "library(rcloud.support);rcloud.support::check.installation(force=T)"

# add configuration files
ADD restart /data/rcloud/restart
ADD rcloud.conf /data/rcloud/conf/rcloud.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /data/rcloud/restart
EXPOSE 22 8080 8081
CMD ["/usr/bin/supervisord"]
