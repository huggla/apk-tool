FROM huggla/busybox:20181017-edge as init
FROM huggla/alpine-official:20181017-edge as build

COPY --from=init / /imagefs

ARG APKS="libressl2.7-libcrypto libressl2.7-libssl apk-tools"

RUN mkdir -p /imagefs/apk-tool \
 && apk --no-cache --quiet manifest $APKS | awk -F "  " '{print "/"$2;}' > /imagefs/apk-tool/apk-tool.filelist \
 && find / -path "/etc/apk/*" -type f >> /imagefs/apk-tool/apk-tool.filelist \
 && while read file; \
    do \
       mkdir -p "/imagefs/apk-tool$(dirname $file)"; \
       cp -a "$file" "/imagefs/apk-tool$file"; \
    done < /imagefs/apk-tool/apk-tool.filelist \
 && cd /imagefs/apk-tool \
 && find * ! -type d ! -type c -exec ls -la {} + | awk -F " " '{print $5" "$9}' | sort -u - > /imagefs/onbuild-exclude.filelist \
 && gzip -f /imagefs/onbuild-exclude.filelist

FROM scratch as image

COPY --from=build /imagefs /
