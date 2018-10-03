FROM huggla/alpine-official:20180927-edge as alpine

ARG APKS="libressl2.7-libcrypto libressl2.7-libssl apk-tools"

RUN apk --no-cache --quiet manifest $APKS | awk -F "  " '{print $2;}' > /apk-tool.filelist \
 && find / -path "/etc/apk/*" -type f >> /apk-tool.filelist \
 && tar -cvp -f /apk-tool.tar -T /apk-tool.filelist -C /

FROM scratch as final-image

COPY --from=alpine /apk-tool.tar /apk-tool.filelist /
