FROM huggla/busybox:20181017-edge as init
FROM huggla/alpine-official:20181017-edge as build

COPY --from=init / /imagefs
COPY --from=init /onbuild-exclude.filelist /onbuild-exclude.filelist

ARG APKS="libressl2.7-libcrypto libressl2.7-libssl apk-tools"

RUN apk --no-cache --quiet manifest $APKS | awk -F "  " '{print "/"$2;}' > /imagefs/apk-tool.filelist \
 && find / -path "/etc/apk/*" -type f >> /imagefs/apk-tool.filelist \
 && while read file; \
    do \
       mkdir -p "/imagefs$(dirname $file)"; \
       cp -a "$file" "/imagefs$file"; \
    done < /imagefs/apk-tool.filelist \
 && cd /imagefs \
 && find * ! -type d ! -type c -exec ls -la {} + | awk -F " " '{print $5" "$9}' >> /onbuild-exclude.filelist \
 && sort /onbuild-exclude.filelist > /imagefs/onbuild-exclude.filelist

FROM scratch as image

COPY --from=build /imagefs /
