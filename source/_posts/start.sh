#!/bin/sh
 
echo "开始执行shell脚本"
 
# 在jenkins环境中一定要加这句话，否则这个脚本进程最后会被杀死
export BUILD_ID=dontKillMe
 
# 指定最后编译好的jar的存放位置
JAR_PATH=/usr/java/spring-application-jar

# 如果路径不存在，就创建路径
[ ! -e $JAR_PATH ] && mkdir -p $JAR_PATH 

# 指定jenkins中存放编译好的jar的位置
JENKINS_JAR_PATH=/usr/lib/jenkins/workspace/distribute-id-ms/target
 
# 如果路径不存在，就创建路径
[ ! -e $JENKINS_JAR_PATH ] && mkdir -p $JENKINS_JAR_PATH
 
# 指定jenkins中存放编译好的jar的名称(这个jar的名字和pom文件配置有关)
JENKINS_JAR_NAME=distribute-id-ms-1.0.jar
 
# 获取该项目的进程号，用于重新部署项目前杀死进程
pid=`ps -ef|grep distribute-id-ms-1.0.jar | grep -v grep|awk '{print $2}'`

echo "  =====关闭Java应用======"

for i in $pid
do
  echo "Kill the $1 process [ $i ]"
  kill -9 $i
done

echo "  =====启动Java应用======"

# 进入Jenkins中编译好的jar的位置
cd ${JENKINS_JAR_PATH}
 
# 将Jenkins中编译好的jar复制到最终存放项目jar的位置
cp $JENKINS_JAR_PATH/$JENKINS_JAR_NAME $JAR_PATH
 
# 进入到存放项目jar的位置
cd ${JAR_PATH}
 
# 后台启动项目，并且将控制台日志输出到nohup.out中
 
nohup java -jar ${JENKINS_JAR_NAME} >/dev/null &
 
echo "shell脚本执行完毕"



