```shell
#环境变量
if [[ "${BUILD_MODE}" == "RELEASE" ]]; then
        export CFLAGS="-O2 -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic"
    else
        export CFLAGS="-rdynamic -O0 -pipe -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic"
    fi
```
```shell
#configure
./configure \
        PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/usr/share/pkgconfig \
        --with-extra-version=" (Transwarp)" \
        --with-icu \
        --with-perl \
        --with-python PYTHON=/usr/bin/python3 \
        --with-tcl \
        --with-openssl \
        --with-pam \
        --with-gssapi \
        --with-uuid=e2fs \
        --with-libxml \
        --with-libxslt \
        --with-ldap \
        --with-selinux \
        --with-systemd \
        --with-system-tzdata=/usr/share/zoneinfo \
        --enable-nls \
        --disable-dtrace \
        --enable-debug \
        --enable-tap-tests \
        --disable-rpath \
	    --prefix=/usr/lib/spatial/postgresql-10
```


- arm
```bash
if [[ "${BUILD_MODE}" == "RELEASE" ]]; then

	export CFLAGS="-O2 -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -mabi=lp64 -mtune=generic"

else

	export CFLAGS="-rdynamic -O0 -pipe -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -mabi=lp64 -mtune=generic"

fi
```
	
	
	
```bash
	./configure         PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/usr/share/pkgconfig         --with-extra-version=" (Transwarp)"         --prefix=/usr/lib/spatial/postgresql-10         --with-icu         --with-perl         --with-python PYTHON=/usr/bin/python3         --with-tcl         --with-openssl         --with-pam         --with-gssapi         --with-uuid=e2fs         --with-libxml         --with-libxslt         --with-ldap         --with-selinux         --with-systemd         --with-system-tzdata=/usr/share/zoneinfo         --enable-nls         --disable-dtrace         --enable-debug                  --disable-rpath
```

