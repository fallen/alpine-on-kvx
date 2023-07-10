FROM alpine
RUN apk add alpine-sdk
RUN apk add abuild-rootbld
RUN adduser -G abuild --disabled-password yann
USER yann
RUN cd ~; git clone https://github.com/fallen/aports
USER root
RUN apk add doas
# binutils dependencies
RUN apk add mpfr-dev gmp-dev
RUN echo "permit nopass yann as root" >> /etc/doas.d/doas.conf
RUN echo "permit nopass root as yann" >> /etc/doas.d/doas.conf
USER yann
RUN abuild-keygen -a -i -n
# build abuild with kvx support
USER root
RUN cd ~yann/aports/main/abuild; doas -u yann abuild -r
USER yann
# remove abuild to rebuild it locally with kvx support
RUN doas apk del alpine-sdk abuild-rootbld
# install newly built abuild
RUN doas apk add ~/packages/main/x86_64/*.apk
# Reinstall alpine-sdk ...
RUN doas apk add alpine-sdk
ARG CACHEBUST=0
RUN cd ~/aports ; git pull
