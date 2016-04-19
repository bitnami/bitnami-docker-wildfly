FROM gcr.io/stacksmith-images/ubuntu:14.04-r05
MAINTAINER Bitnami <containers@bitnami.com>

ENV BITNAMI_APP_NAME=wildfly \
    BITNAMI_APP_VERSION=9.0.2-1 \
    BITNAMI_APP_CHECKSUM=82535dfdcdb22dbb194bd729cd0ea82d7a7c93674e00190457adfd428b7316e8 \
    BITNAMI_APP_USER=wildfly

# Install supporting modules
RUN bitnami-pkg install java-1.8.0_71-0 --checksum f61dd50fc207e619cec30d696890694d453f4ee861e25e05c101222514f52df6
ENV PATH=/opt/bitnami/java/bin:$PATH

# Install application
RUN bitnami-pkg unpack $BITNAMI_APP_NAME-$BITNAMI_APP_VERSION --checksum $BITNAMI_APP_CHECKSUM
ENV PATH=/opt/bitnami/$BITNAMI_APP_NAME/bin:$PATH

# Setting entry point
COPY rootfs/ /
ENTRYPOINT ["/app-entrypoint.sh"]
CMD ["harpoon", "start", "--foreground", "wildfly"]

# Exposing ports
EXPOSE 8080 9990

VOLUME ["/bitnami/$BITNAMI_APP_NAME"]
