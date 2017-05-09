FROM openjdk:8
#SSH server config
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo 'AuthorizedKeysFile /root/authorized_keys' >> /etc/ssh/sshd_config
ADD id_rsa.pub /root/authorized_keys
#RUN cat /home/root/id_rsa.pub >> /home/root/.ssh/authorized_keys

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

#Download Gatling
WORKDIR /gatling
RUN wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/2.2.5/gatling-charts-highcharts-bundle-2.2.5-bundle.zip
RUN unzip gatling-charts-highcharts-bundle-2.2.5-bundle.zip

#Start
CMD ["/usr/sbin/sshd", "-D"]