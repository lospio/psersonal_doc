## Fix Failed to download metadata for repo

[CentOS Linux 8 had reached the End Of Life (EOL)](https://www.centos.org/centos-linux-eol/) on December 31st, 2021. It means that CentOS 8 will no longer receive development resources from the official CentOS project. After Dec 31st, 2021, if you need to update your CentOS, you need to change the mirrors to [vault.centos.org](https://vault.centos.org/) where they will be archived permanently. Alternatively, you may want to [upgrade to CentOS Stream](https://techglimpse.com/convert-centos8-linux-centosstream/).

**Step 1:** Go to the `/etc/yum.repos.d/` directory.

```bash
cd /etc/yum.repos.d/
```

**Step 2:** Run the below commands

```bash
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
```

```bash
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
```

**Step 3:** Now run the yum update

```bash
yum update -y
```

That’s it!