删除远端的本地缓存
```bash
git fetch -p origin
```
删除分支
```bash
git branch -b branch_name
git push remote_name --delete branch_name
```
报错`Could not open a connection to your authentication agent.
```bash
eval $(ssh-agent)
git add
```
多个账户配置
```ruby
# Personal account
Host github.com
   HostName github.com
   User git
   IdentityFile ~/.ssh/id_rsa
   
# Work account
Host workgithub.com  
   HostName github.com
   User git
   IdentityFile ~/.ssh/id_rsa_work
```
```shll
ssh -T git@Host
```