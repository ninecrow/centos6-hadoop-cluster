FROM ninecrow/centos6-jdk8:1.0.0
MAINTAINER ninecrow <ninecrow@yeah.net>

RUN yum update -y \
    && yum install -y rsync \
    && yum clean all


#添加Hadoop用户
RUN useradd -m hadoop -G root -s /bin/bash \
	&& echo "hadoop:hadoop" | chpasswd \
	&& echo "hadoop  ALL=(ALL)  NOPASSWD:ALL">> /etc/sudoers \
	&& chmod 440 /etc/sudoers


ARG HADOOP_VERSION=2.7.6
ARG JAVA_VERSION=1.8.0_171
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ARG HADOOP_FILE_NAME=hadoop-${HADOOP_VERSION}.tar.gz
ARG HADOOP_SHA=F2327EA93F4BC5A5D7150DEE8E0EDE196D3A77FF8526A7DD05A48A09AAE25669
#ENV HADOOP_PREFIX=/opt/hadoop-${HADOOP_VERSION}
#ENV HADOOP_HOME=${HADOOP_PREFIX}
#ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
#ENV HADOOP_LOG_DIR=/hadoop_logs
#ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# bash login+interactive/non-interactive 两种方式都会加载 /etc/profile 配置文件；
# ssh远程登陆 login+interactive
# docker exec -i -t  ?
RUN sudo echo "export HADOOP_HOME=${HADOOP_HOME}" >> /etc/profile \
	&& sudo echo "export HADOOP_PREFIX=${HADOOP_HOME}" >> /etc/profile \
	&& sudo echo "export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop" >> /etc/profile \
	&& sudo echo "export HADOOP_LOG_DIR=/hadoop_logs" >> /etc/profile

USER hadoop
WORKDIR /tmp
#调试用
#COPY hadoop-${HADOOP_VERSION}.tar.gz /tmp/hadoop-${HADOOP_VERSION}.tar.gz
RUN sudo wget http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-${HADOOP_VERSION}/${HADOOP_FILE_NAME} \
#RUN sudo echo "aa" \
	&& sudo echo "${HADOOP_SHA}  ${HADOOP_FILE_NAME}">/tmp/${HADOOP_FILE_NAME}.sha \
	&& sudo sha256sum -c ${HADOOP_FILE_NAME}.sha \
	&& sudo tar -xvf /tmp/${HADOOP_FILE_NAME} -C /opt/ \
	&& sudo rm /tmp/${HADOOP_FILE_NAME}* \
	&& sudo cp ${HADOOP_HOME}/etc/hadoop/mapred-site.xml.template ${HADOOP_HOME}/etc/hadoop/mapred-site.xml \
	&& sudo mkdir /hadoop_tmp \
	&& sudo chown -R hadoop:root /hadoop_tmp \
	&& sudo rm -rf ${HADOOP_HOME}/share/doc/hadoop

WORKDIR ${HADOOP_HOME}

#hadoop默认配置文件
ADD core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml
ADD hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
ADD yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
ADD container-executor.cfg ${HADOOP_HOME}/etc/hadoop/container-executor.cfg

#修改hadoop_env.sh中JAVA_HOME等配置
RUN sudo sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/opt/jdk/jdk'${JAVA_VERSION}'\n:' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
RUN sudo chown -R hadoop:root ${HADOOP_HOME} 

ADD entrypoint.sh /entrypoint.sh
RUN sudo chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
