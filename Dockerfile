ARG TAG

FROM "openhab/openhab:${TAG}"

# installation of BlueZ and git
RUN apt-get update && \
    apt-get install -y bluez git

# installation of Raspberry Pi userspace firmware tools
RUN git clone -b master --single-branch --depth 1 https://github.com/raspberrypi/firmware /tmp/firmware && \
    mv /tmp/firmware/hardfp/opt/vc /opt && \
    echo "/opt/vc/lib" > /etc/ld.so.conf.d/00-vmcs.conf && \
    ldconfig

# cleaning up setup dependencies and unused files
RUN rm -rf /tmp/* && \
    rm -rf /opt/vc/src && \
    apt-get purge --auto-remove -y git && \
    rm -rf /var/lib/apt/lists/*

# downloading tinyb and setting appropriate file permissions (https://github.com/openhab/openhab-addons/issues/5680)
RUN cd "${JAVA_HOME}/jre/lib/aarch32/" && \
    curl -kL https://github.com/openhab/openhab-addons/raw/2.5.x/bundles/org.openhab.binding.bluetooth.bluez/src/main/resources/lib/armv6hf/libjavatinyb.so \
      -o libjavatinyb.so && \
    curl -kL https://github.com/openhab/openhab-addons/raw/2.5.x/bundles/org.openhab.binding.bluetooth.bluez/src/main/resources/lib/armv6hf/libtinyb.so \
      -o libtinyb.so && \
    PERM_REF_FILE=$(ls | head -n 1) && \
    chmod --reference $PERM_REF_FILE . && \
    chown --reference $PERM_REF_FILE .

# scripts in /etc/cont-init.d/ are run before the OpenHAB
COPY 90-openhab-pi-bluez /etc/cont-init.d/

