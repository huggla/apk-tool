FROM huggla/alpine-official:20180927-edge as alpine

ARG APKS="libressl2.7-libcrypto libressl2.7-libssl apk-tools"

RUN apk --no-cache --quiet manifest $APKS | awk -F "  " '{print $2;}' > /apk-tool.filelist \
 && find / -path "/etc/apk/*" -type f >> /apk-tool.filelist \
 && tar -cvp -f /apk-tool.tar -T /apk-tool.filelist -C /

FROM scratch as final-image

COPY --from=alpine /apk-tool.tar /

#----------ONBUILD----------
ONBUILD ARG ADDREPOS
ONBUILD ARG BUILDDEPS
ONBUILD ARG BUILDDEPS_UNTRUSTED
ONBUILD ARG RUNDEPS
ONBUILD ARG RUNDEPS_UNTRUSTED
ONBUILD ARG BUILDCMDS

ONBUILD COPY --from=baseimage / /
ONBUILD COPY --from=baseimage / /imagefs/
ONBUILD COPY ./* /tmp/

ONBUILD RUN mkdir /buildfs \
         && tar -xvp -f /apk-tool.tar -C / \
         && tar -xvp -f /apk-tool.tar -C /buildfs/ \
         && rm -rf /apk-tool.tar \
         && echo $ADDREPOS >> /buildfs/etc/apk/repositories \
         && apk --no-cache --root /buildfs add --initdb \
         && apk --no-cache --root /buildfs --virtual .rundeps add $RUNDEPS \
         && apk --no-cache --root /buildfs --allow-untrusted --virtual .rundeps_untrusted add $RUNDEPS_UNTRUSTED \
         && cp -a /buildfs/* /imagefs/ \
         && [ -d "/tmp/buildfs" ] && cp -a /tmp/buildfs / || /bin/true \
         && apk --no-cache --root /buildfs --virtual .builddeps add $BUILDDEPS \
         && apk --no-cache --root /buildfs --allow-untrusted --virtual .builddeps_untrusted add $BUILDDEPS_UNTRUSTED \
         && eval "$RUNCMDS" \
         && [ -d "/tmp/imagefs" ] && cp -a /tmp/imagefs / || /bin/true \
         && rm -rf /tmp/* /imagefs/lib/apk /imagefs/etc/apk
#----------ONBUILD----------
