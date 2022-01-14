FROM scratch AS root
ADD archlinux-root.tar /
ENV LANG=en_US.UTF-8
RUN provision-container
ENV ENV=/etc/profile
