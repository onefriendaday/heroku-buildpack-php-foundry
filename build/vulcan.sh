#!/bin/bash
set -e

mkdir /app/local
mkdir /app/local/lib
mkdir /app/local/bin
mkdir /app/apache
mkdir /app/php
mkdir /app/php/ext

curl -L ftp://mcrypt.hellug.gr/pub/crypto/mcrypt/libmcrypt/libmcrypt-2.5.7.tar.gz -o /tmp/libmcrypt-2.5.7.tar.gz
curl -L ftp://ftp.andrew.cmu.edu/pub/cyrus-mail/cyrus-sasl-2.1.25.tar.gz -o /tmp/cyrus-sasl-2.1.25.tar.gz
curl -L https://launchpad.net/libmemcached/1.0/1.0.10/+download/libmemcached-1.0.10.tar.gz -o /tmp/libmemcached-1.0.10.tar.gz
curl -L http://www.apache.org/dist/httpd/httpd-2.2.22.tar.gz -o /tmp/httpd-2.2.22.tar.gz
curl -L http://us.php.net/get/php-5.3.16.tar.gz/from/us2.php.net/mirror -o /tmp/php-5.3.16.tar.gz
curl -L http://pecl.php.net/get/memcached-2.1.0.tgz -o /tmp/memcached-2.1.0.tgz

tar -C /tmp -xzvf /tmp/libmcrypt-2.5.7.tar.gz
tar -C /tmp -xzvf /tmp/cyrus-sasl-2.1.25.tar.gz
tar -C /tmp -xzvf /tmp/libmemcached-1.0.10.tar.gz
tar -C /tmp -xzvf /tmp/httpd-2.2.22.tar.gz
tar -C /tmp -xzvf /tmp/php-5.3.16.tar.gz
tar -C /tmp -xzvf /tmp/memcached-2.1.0.tgz

export CFLAGS='-g0 -O2 -s'
export CXXFLAGS="${CFLAGS}"

MAKE_CMD=`which make`

cd /tmp/libmcrypt-2.5.7
./configure --prefix=/app/local
${MAKE_CMD} && ${MAKE_CMD} install

# cd /tmp/cyrus-sasl-2.1.25
# ./configure --prefix=/app/local
# ${MAKE_CMD} && ${MAKE_CMD} install

cd /tmp/libmemcached-1.0.10
./configure --prefix=/app/local
${MAKE_CMD} && ${MAKE_CMD} install

cd /tmp/httpd-2.2.22
./configure --prefix=/app/apache --enable-rewrite --enable-so --enable-deflate --enable-expires --enable-headers
${MAKE_CMD} && ${MAKE_CMD} install

cd /tmp/php-5.3.16
./configure --prefix=/app/php --with-apxs2=/app/apache/bin/apxs --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv --with-gd --with-curl=/usr/lib --with-config-file-path=/app/php --enable-soap=shared --with-openssl --enable-mbstring --with-mhash --enable-mysqlnd --with-pear --with-mysqli=mysqlnd --disable-cgi --enable-static
${MAKE_CMD} && ${MAKE_CMD} install

/app/php/bin/pear config-set php_dir /app/php
echo " " | /app/php/bin/pecl install memcache
echo " " | /app/php/bin/pecl install apc

cd /tmp/memcached-2.1.0
/app/php/bin/phpize
#SASL supports still doesn't work
./configure --with-libmemcached-dir=/app/local/ --prefix=/app/php --with-php-config=/app/php/bin/php-config
${MAKE_CMD} && ${MAKE_CMD} install

echo '2.2.22' > /app/apache/VERSION
echo '5.3.16' > /app/php/VERSION
mkdir /tmp/build
mkdir /tmp/build/local
mkdir /tmp/build/local/lib
cp -a /app/apache /tmp/build/
cp -a /app/php /tmp/build/
cp -aL /usr/lib/libmysqlclient.so.16 /tmp/build/local/lib/
cp -aL /app/local/lib/libhashkit.so.2 /tmp/build/local/lib/
cp -aL /app/local/lib/libmcrypt.so.4 /tmp/build/local/lib/
cp -aL /app/local/lib/libmemcached.so.11 /tmp/build/local/lib/
cp -aL /app/local/lib/libmemcachedprotocol.so.0 /tmp/build/local/lib/
cp -aL /app/local/lib/libmemcachedutil.so.2 /tmp/build/local/lib/

rm -rf /tmp/build/apache/manual/

