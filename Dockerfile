FROM openjdk:latest
MAINTAINER Etienne Koekemoer <me@etiennek.com>

ENV BOOTAPP_JAVA_OPTS -Xms256m -Xmx256m

ENV BOOTAPP_USR bootapp
ENV BOOTAPP_GROUP bootapp_group
ENV BOOTAPP_HOME /home/$BOOTAPP_USR
ENV BOOTAPP_PATH $BOOTAPP_HOME/app.jar
ENV BOOTAPP_DATA_VOLUME $BOOTAPP_HOME/data
ENV SERVER_PORT 8007

COPY wrapper.sh $BOOTAPP_HOME/wrapper.sh

RUN mkdir -p $BOOTAPP_DATA_VOLUME && \
    groupadd -r $BOOTAPP_GROUP -g 433 && \
    useradd -u 431 -r -g $BOOTAPP_GROUP -d $BOOTAPP_HOME -s /sbin/nologin -c "Spring Boot Application User" $BOOTAPP_USR && \
    chown -R $BOOTAPP_USR:$BOOTAPP_GROUP $BOOTAPP_HOME && chmod -R 500 $BOOTAPP_HOME && chmod -R 700 $BOOTAPP_DATA_VOLUME

WORKDIR $BOOTAPP_HOME

EXPOSE $SERVER_PORT

HEALTHCHECK --interval=30s --timeout=5s --retries=4 \
  CMD curl -f http://localhost:$SERVER_PORT/health/ || exit 1

VOLUME /tmp
VOLUME $BOOTAPP_DATA_VOLUME

USER $BOOTAPP_USR

ONBUILD USER root
ONBUILD COPY app.jar $BOOTAPP_PATH
ONBUILD RUN chown -R $BOOTAPP_USR:$BOOTAPP_GROUP $BOOTAPP_HOME && \
            chmod 700 $BOOTAPP_PATH && \
            touch $BOOTAPP_PATH
ONBUILD USER $BOOTAPP_USR

ENTRYPOINT ["./wrapper.sh"]
