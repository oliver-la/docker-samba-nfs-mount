FROM phusion/baseimage:focal-1.0.0

ARG DEBIAN_FRONTEND=noninteractive
ENV PATH="/container/scripts:${PATH}"

WORKDIR /setup

# Update system
RUN apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get clean && rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*

# Install samba
RUN apt-get update && \
    apt-get install -y samba && \
    touch /var/lib/samba/registry.tdb /var/lib/samba/account_policy.tdb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
    apt-get install -y build-essential git libfuse2 libfuse-dev cmake libattr1-dev fuse && \
    git clone https://github.com/oliver-la/fuse_xattrs.git && \
    cd fuse_xattrs &&   \
    mkdir build && cd build && \
    cmake .. && \
    make && \
    make install && \
    apt-get remove -y build-essential git cmake && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY config/samba/smb.conf /etc/samba/smb.conf

RUN addgroup --system smb && \
    adduser --system --no-create-home --home /tmp --disabled-login --ingroup smb --gecos "" smbuser

RUN mkdir -p /etc/service/fuse
COPY service/fuse/run /etc/service/fuse/run
RUN chmod +x /etc/service/fuse/run

COPY scripts/samba.sh /usr/bin/entrypoint.sh

RUN mkdir -p /shares && \
    chown smbuser:smb /shares && \
    chmod 777 /shares

EXPOSE 445

HEALTHCHECK --interval=60s --timeout=15s \
            CMD smbclient -L \\localhost -U % -m SMB3

CMD ["/sbin/my_init", "--", "/usr/bin/entrypoint.sh"]

