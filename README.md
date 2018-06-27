Hadoop image
====
&nbsp;

### 安装组件：
hadoop-2.7.6<br/>
&nbsp;

### 容器启动命令
docker run -itd --name <container name>  --hostname <hostname> ninecrow/centos6-hadoop2:0.1  -d <br/>
&emsp;建议用--hostname参数，方便hadoop及ssh需要；<br/>
&emsp;hostname不能包含字符“-”；<br/>
&emsp;--post参数可以自行添加，也可以容器启动后，通过在host（宿主机）通过iptables方式添加；<br/>
&nbsp;

### 进入容器方式
如果是docker exec 方式登陆，在最后加上参数“-l“ ，这样会加载/etc/profile 中的hadoop相关环境配置； <br/>
docker exec -it <container> /bin/bash -l <br/>
&nbsp;

### 集群试验
image可以作为模板，在Master节点修改好配置文件，通过scp将配置文件同步到其他节点上；

&emsp;&emsp;master1启动服务：NameNode,ResourceManager<br/>
&emsp;&emsp;master2启动服务：SecondaryNameNode,JobHistroyServer<br/>
&emsp;&emsp;Slave1/Slave2启动服务：NodeManager,DataNode<br/>

&nbsp;
container-Master： <br/>
&emsp;&emsp;修改container内的 ${Hadoop_home}/etc/hadoop/slaver文件，指定datanode节点（container） <br/>
&emsp;&emsp;参照hadoop官网说明，hdfs dfs -format <br/>


&nbsp;
container-secondaryNameNode:<br/>
&emsp;&emsp;secondaryNameNode节点，修改hdfs-site.xml <br/>
&emsp;&emsp;此节点上可以启动jobHistoryServer， sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver<br/>

