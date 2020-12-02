FROM registry.itops.local/centos:7

LABEL maintainer="lindiyer@gmail.com"

ARG VERSION=8.4p1
#ARG URL=https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable
ARG URL=https://ftp.riken.jp/pub/OpenBSD/OpenSSH/portable

RUN mkdir -p /home/rpmbuilder/rpmbuild/{SOURCES,SPECS}
RUN yum install wget -y

RUN wget ${URL}/openssh-${VERSION}.tar.gz && \
    cp openssh-${VERSION}.tar.gz    /home/rpmbuilder/rpmbuild/SOURCES/

RUN tar xf openssh-${VERSION}.tar.gz
RUN cp openssh-${VERSION}/contrib/redhat/openssh.spec /home/rpmbuilder/rpmbuild/SPECS/

RUN wget https://src.fedoraproject.org/lookaside/pkgs/openssh/x11-ssh-askpass-1.2.4.1.tar.gz/8f2e41f3f7eaa8543a2440454637f3c3/x11-ssh-askpass-1.2.4.1.tar.gz && \
    cp x11-ssh-askpass-1.2.4.1.tar.gz         /home/rpmbuilder/rpmbuild/SOURCES/

RUN useradd rpmbuilder && chown -R rpmbuilder:rpmbuilder /home/rpmbuilder/
RUN su - rpmbuilder && cd /home/rpmbuilder/rpmbuild/SPECS/ 

RUN sed -i "s/%global no_gnome_askpass 0/%global no_gnome_askpass 1/g"    openssh.spec && \
    sed -i "s/%global no_x11_askpass 0/%global no_x11_askpass 1/g"    openssh.spec && \
    sed -i "s/BuildRequires: openssl-devel >= 1.0.1/#BuildRequires: openssl-devel >= 1.0.1/g" openssh.spec && \
    sed -i "s/BuildRequires: openssl-devel < 1.1/#BuildRequires: openssl-devel < 1.1/g" openssh.spec && \
    sed -i 's/^%__check_fil/#&/'     /usr/lib/rpm/macros 

RUN yum -y install epel-release  && yum makecache fast
RUN yum -y install rpm-build gcc make openssl-devel krb5-devel pam-devel libX11-devel xmkmf libXt-devel gtk2-devel

RUN rpmbuild  -bb  openssh.spec
RUN sed  -i   's/^#%__check_files/%__check_files/g'     /usr/lib/rpm/macros#RUN cp /home/rpmbuilder/rpmbuild/RPMS/x86_64/*.rpm /tmp/
