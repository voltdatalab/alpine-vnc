# alpine-vnc - A basic, graphical alpine workstation
# includes xfce, vnc, ssh
# last update: May/29/2022

FROM alpine:3.23.4

# init ash file (for non-login shells)
ENV ENV='$HOME/.ashrc'

# default screen size
ENV XRES=1280x800x24

# default tzdata settings
ENV TZ=Etc/UTC

# set the shell to ash
SHELL [ "/bin/ash", "-c" ]

# update and install system software
RUN apk update && apk upgrade

RUN apk add --no-cache sudo=1.9.17_p2-r0 supervisor=4.3.0-r0 openssh-server=10.2_p1-r0 openssh=10.2_p1-r0 nano=8.7-r0 tzdata=2026b-r0
RUN apk add --no-cache xvfb=21.1.22-r0 x11vnc=0.9.17-r0 xrdb=1.2.2-r0
RUN apk add --no-cache xfce4=4.20-r0 xfce4-terminal=1.1.3-r0 xfce4-xkb-plugin=0.9.0-r1 mousepad=0.6.3-r1 adwaita-icon-theme=49.0-r0
RUN apk add --no-cache firefox=145.0-r0 git=2.52.0-r0 build-base=0.5-r3 python3-tkinter=3.12.13-r0 gnome-screenshot=41.0-r1 xauth=1.1.4-r0

# add main user
RUN adduser -D alpine

# change passwords and permissions
RUN  set -o pipefail \
  && echo "root:alpine" | /usr/sbin/chpasswd \
  && echo "alpine:alpine" | /usr/sbin/chpasswd \
  && echo "alpine ALL=(ALL) ALL" >> /etc/sudoers

# setup sshd
VOLUME [ "/etc/ssh" ]
RUN  mkdir /run/sshd \
  && ssh-keygen -A

# add my sys config files
COPY etc /etc

# customizations
RUN  echo "alias ll='ls -l'" > /home/alpine/.ashrc \
  && echo "alias lla='ls -al'" >> /home/alpine/.ashrc \
  && echo "alias llh='ls -hl'" >> /home/alpine/.ashrc \
  && echo "alias hh=history" >> /home/alpine/.ashrc \
  #
  # ash personal config file for login shell mode
  && cp /home/alpine/.ashrc /home/alpine/.profile

# personal xfce4 config
COPY config/xfce4/terminal/terminalrc /home/alpine/.config/xfce4/terminal/terminalrc

# set custom wallpaper
COPY config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml  \
  /home/alpine/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

# RUN chown -R alpine:alpine /home/alpine/.config /home/alpine/.xscreensaver
RUN chown -R alpine:alpine /home/alpine/

# exposed ports
EXPOSE 22 5900

# create volume for firefox config
VOLUME [ "/home/alpine/.mozilla/firefox" ]

# default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
