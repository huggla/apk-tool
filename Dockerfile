FROM huggla/alpine-official:20181017-edge as alpine

ARG APKS="libressl2.7-libcrypto libressl2.7-libssl apk-tools"

RUN apk --no-cache --quiet manifest $APKS | awk -F "  " '{print "/"$2;}' > /apk-tool.filelist \
 && find / -path "/etc/apk/*" -type f >> /apk-tool.filelist \
 && while read file; \
    do \
       mkdir -p "/buildfs$(dirname $file)"; \
       ln -sf "$file" "/buildfs$file"; \
    done < /apk-tool.filelist \
 && cd /buildfs \
 && find * ! -type d ! -type c -exec ls -la {} + | awk -F " " '{print $5" "$9}' > /onbuild-exclude.filelist \
 && tar -cvp -f /apk-tool.tar -T /apk-tool.filelist -C /

FROM scratch as image

COPY --from=alpine /apk-tool.tar /apk-tool.filelist /onbuild-exclude.filelist /
