centos7 perl
```shell
	 wget https://www.cpan.org/src/5.0/perl-5.34.0.tar.gz
     tar -xzf perl-5.34.0.tar.gz
     cd perl-5.34.0
     ./Configure -des -Dprefix=$HOME/localperl
     make -sj
     make test -sj
     make install -sj
```