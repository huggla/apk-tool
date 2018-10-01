FROM huggla/alpine-official:20180927-edge

ARG APKS="libressl2.7-libcrypto libressl2.7-libssl apk-tools"

RUN apk --no-cache --quiet manifest $APKS | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && mkdir -p /rootfs/lib/apk /rootfs/etc/apk \
 && apk --no-cache --root /rootfs add --initdb
