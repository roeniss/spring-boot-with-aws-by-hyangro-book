#!/bin/bash

REPOSITORY=/home/ec2-user/app/step2
PROJECT_NAME=hyangro

echo "> Build 파일 복사"

JAR_NAME=$(ls $REPOSITORY/zip/ | grep .jar | head)

cp $REPOSITORY/zip/$JAR_NAME $REPOSITORY/

echo "> 현재 구동중인 애플리케이션 pid 확인"

CURRENT_PID=$(pgrep java)

echo "현재 구동중인 어플리케이션 pid: $CURRENT_PID"

if [ -z "$CURRENT_PID" ]; then
    echo "> 현재 구동중인 애플리케이션이 없으므로 종료하지 않습니다."
else
    echo "> kill -15 $CURRENT_PID"
    kill -15 $CURRENT_PID
    sleep 5
fi

echo "> 새 어플리케이션 배포"

JAR_NAME_FULLPATH=$(ls $REPOSITORY/zip/*.jar)

echo "> JAR Name: JAR_NAME_FULLPATH"

echo "> $JAR_NAME_FULLPATH 에 실행권한 추가"

chmod +x $JAR_NAME_FULLPATH

echo "> $JAR_NAME_FULLPATH 실행"

nohup java -jar \
    -Dspring.config.location=classpath:/application.properties,classpath:/application-real.properties,/home/ec2-user/app/application-oauth.properties,/home/ec2-user/app/application-real-db.properties \
    -Dspring.profiles.active=real \
    $JAR_NAME_FULLPATH > $REPOSITORY/nohup.out 2>&1 &
