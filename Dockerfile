FROM huggla/alpine-official:20180927-edge as build

ARG APKS="libressl2.7-libcrypto libressl2.7-libssl apk-tools"

RUN apk --no-cache --quiet manifest $APKS | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && apk --no-cache --root /rootfs add --initdb \
 && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && find / --maxdepth 0 ! -name rootfs --execdir rm -rf {} +

FROM scratch as save

COPY --from=build /rootfs /
