FROM gcr.io/stacksmith-images/ubuntu:14.04
MAINTAINER Bitnami <containers@bitnami.com>

ENV BITNAMI_APP_NAME=wildfly \
    BITNAMI_APP_USER=wildfly \
    BITNAMI_APP_VERSION=9.0.2-1 \
    WILDFLY_PACKAGE_SHA256="82535dfdcdb22dbb194bd729cd0ea82d7a7c93674e00190457adfd428b7316e8" \
    BITNAMI_APP_LANG=java \
    BITNAMI_APP_LANG_VERSION=1.8.0_71-0 \
    JAVA_PACKAGE_SHA256="f61dd50fc207e619cec30d696890694d453f4ee861e25e05c101222514f52df6"

ENV BITNAMI_APP_DIR=/opt/bitnami/$BITNAMI_APP_NAME \
    BITNAMI_APP_VOL_PREFIX=/bitnami/$BITNAMI_APP_NAME


RUN bitnami-pkg install $BITNAMI_APP_LANG-$BITNAMI_APP_LANG_VERSION

ENV PATH=/opt/bitnami/$BITNAMI_APP_LANG/bin:$PATH

RUN bitnami-pkg unpack $BITNAMI_APP_NAME-$BITNAMI_APP_VERSION

# these symlinks should be setup by harpoon at unpack
RUN mkdir -p $BITNAMI_APP_VOL_PREFIX && \
    ln -s $BITNAMI_APP_DIR/standalone $BITNAMI_APP_VOL_PREFIX/data && \
    ln -s $BITNAMI_APP_DIR/conf $BITNAMI_APP_VOL_PREFIX/conf && \
    ln -s $BITNAMI_APP_DIR/logs $BITNAMI_APP_VOL_PREFIX/logs

ENV PATH=$BITNAMI_APP_DIR/bin:$PATH

COPY rootfs/ /

EXPOSE 8080 9990

ENTRYPOINT ["/entrypoint.sh"]
CMD ["harpoon", "start", "--foreground", "wildfly"]
