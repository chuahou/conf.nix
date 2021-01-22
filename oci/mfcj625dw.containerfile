# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

FROM ubuntu:focal

ARG PORT=631
ENV PORT=${PORT}
ARG VERSION=2.2.2-1
ENV VERSION=${VERSION}
ARG SHA256=52de70e1f0bfa7aa3af444c7e78a2794d3bfada99f70c0d09e62ec85a549b025
ENV SHA256=${SHA256}

# Install tools
RUN apt update && apt install -y curl wget whois

# Install CUPS
RUN apt install -y cups

# Install MFC-J625DW drivers
RUN curl https://download.brother.com/welcome/dlf006893/linux-brprinter-installer-${VERSION}.gz | \
	gunzip --uncompress > installer
RUN echo "${SHA256} installer" | sha256sum --check
COPY installer.response .
RUN chmod +x installer
RUN cat installer.response | ./installer

# Create cups configuration allowing outside access
RUN printf "Listen *:${PORT}\n\
<Location />\n\
	Order allow,deny\n\
	Allow all\n\
</Location>" > /etc/cups/cupsd.conf

# Add 'print' user for authentication with password 'print'
RUN useradd --groups=sudo,lp,lpadmin --password=$(mkpasswd print) print

# Run CUPS (in foreground as main process)
CMD [ "/usr/sbin/cupsd", "-f" ]
