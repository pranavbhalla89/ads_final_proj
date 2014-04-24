Setting up RHIPE on Mac OSX 10.9
========================================================

RHIPE (hree-pay) is the R and Hadoop Integrated Programming Environment. It means "in a moment" in Greek.

## Hadoop Setup
1. $ java -version (It must be 1.6* in the least)
2. $ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" (Homebrew :)
3. $ ssh localhost (Set it up, if not)
4. $ brew install hadoop
5. goto /usr/local/Cellar/hadoop/2.3.0/libexec/etc/hadoop
6. in <HADOOP>/etc/hadoop/hadoop-env.sh add or edit these lines:

```{r}
# The java implementation to use.
export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
# Extra Java runtime options.  Empty by default.
export HADOOP_OPTS=”$HADOOP_OPTS -Djava.net.preferIPv4Stack=true”
export HADOOP_OPTS=”$HADOOP_OPTS  -Djava.awt.headless=true -Djava.security.krb5.realm=-Djava.security.krb5.kdc=”
YARN_OPTS=”$YARN_OPTS -Djava.security.krb5.realm=OX.AC.UK -Djava.security.krb5.kdc=kdc0.ox.ac.uk:kdc1.ox.ac.uk -Djava.awt.headless=true”
```

7. Add the following lines to conf/core-site.xml inside the configuration tags:

```{r}
<property>
    <name>fs.default.name</name>
    <value>hdfs://localhost:9000</value>
</property>
```

8. Add the following lines to conf/hdfs-site.xml inside the configuration tags:

```{r}
<property>
    <name>dfs.replication</name>
    <value>1</value>
</property>
```

9. Add the following lines to conf/mapred-site.xml inside the configuration tags:

```{r}
<property>
    <name>mapred.job.tracker</name>
    <value>localhost:9001</value>
</property>
```

Go to System Preferences > Sharing. <br>
Make sure “Remote Login” is checked.<br>
$ ssh-keygen -t rsa<br>
$ cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys<br>

# Hadoop Startup
PATH: /usr/local/hadoop/sbin<br>
$ bin/hadoop namenode -format<br>
$ ./start-dfs.sh<br>
$ ./start-yarn.sh<br>
$ ./mr-jobhistory-daemon.sh start historyserver<br>

Make sure that all Hadoop processes are running (6 of them):<br>
$ jps<br>

# Hadoop Stop
$ ./start-all.sh<br>
$ ./mr-jobhistory-daemon.sh stop historyserver<br>

# Localhost
NameNode- http://localhost:50070<br>
ResourceManager- http://localhost:8088<br>
MapReduce JobHistory-Server- http://localhost:19888<br>

Hadoop Version 2.3.0 documentation <br>
http://hadoop.apache.org/docs/r2.3.0/hadoop-project-dist/hadoop-common/ClusterSetup.html