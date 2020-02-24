FROM centos:7

# Prepare centos 
RUN yum -y update
RUN yum -y groupinstall "Development Tools"
RUN yum -y install centos-release-scl epel-release
RUN yum -y install devtoolset-7-gcc-c++ cmake3 qrencode-devel zlib-devel \ 
qt5-qtbase-devel qt5-qtbase-gui qt5-qttools qt5-qtsvg-devel qt5-qtx11extras-devel qt5-linguist \
libargon2-devel libsodium-devel libsodium-static quazip-devel && yum clean all

# enable more recent gcc from scl
SHELL [ "/usr/bin/scl", "enable", "devtoolset-7"]

# keepassxc requires more up to date libgpg-error and libgcrypt
# build them first (static) 
ADD https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.37.tar.bz2 /
RUN tar xjf libgpg-error-1.37.tar.bz2
WORKDIR libgpg-error-1.37
RUN ./configure --enable-static=yes --enable-shared=no --with-pic=yes
RUN make -j4 && make install

WORKDIR /
ADD https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.5.tar.bz2 /
RUN tar xjf libgcrypt-1.8.5.tar.bz2
WORKDIR libgcrypt-1.8.5
RUN ./configure --enable-static=yes --enable-shared=no --with-pic=yes
RUN make -j4 && make install


# keepassxc version to build
ARG VERSION=2.5.3

# where to install keepassxc
ARG DESTDIR=/opt/keepassxc


# build keepassxc
WORKDIR /
ADD https://github.com/keepassxreboot/keepassxc/releases/download/${VERSION}/keepassxc-${VERSION}-src.tar.xz /
RUN tar xJf keepassxc-${VERSION}-src.tar.xz && rm keepassxc-${VERSION}-src.tar.xz
WORKDIR keepassxc-${VERSION}

# libgpg-error and libgcrypt are static. Need to force link order with the line below.
# A patch against src/CMakeLists.txt would be a better way, but this also works.
RUN echo "target_link_libraries(\${PROGNAME} \${GCRYPT_LIBRARIES} \${GPGERROR_LIBRARIES})" >> src/CMakeLists.txt

WORKDIR build
RUN cmake3 -DCMAKE_INSTALL_PREFIX=${DESTDIR} -DWITH_XC_BROWSER=ON -DWITH_XC_NETWORKING=ON -DWITH_XC_SSHAGENT=ON -DWITH_XC_FDOSECRETS=ON -DCMAKE_BUILD_TYPE=Release -Dsodium_USE_STATIC_LIBS=ON -DWITH_TESTS=OFF -DWITH_XC_KEESHARE=ON -DWITH_XC_KEESHARE_SECURE=ON ..
RUN make VERBOSE=1 -j4

# make install is done in rpmbuild
ADD keepassxc.spec .
RUN rpmbuild -bb --define "_version ${VERSION}" --define "_destdir ${DESTDIR}" keepassxc.spec


