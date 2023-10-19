/删除远端的本地缓存
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
clone 单一分支
```bash
git clone -b <branchname> --single-branch <remote-repo-url>
# 这与方案一的操作相同，除了 `--single-branch` 选项，它是在 Git 版本 1.7.10 及更高版本中引入的。这个选项允许你仅从指定的分支中获取文件而不获取其他分支。
```
更新远端分支列表
```bash
git remote update origin --prune

```
git添加其他仓库的分支
```bash
#新建一个空白分支
git checkout --orphan branch_name
#不要忽略 '.'
git rm -rf .
#添加remote
git remote add remote_name remote_url
git fetch remote_name remote_barnch_name
git pull remote_name remote_branch_name
#此处要往origin推送本地分支，可根据需要修改名字
git push origin local_branch_name:remote_banch_name
```
切换tag
```bash
git checkout tagname
git checkout -b branchname tagname
git push -u remote local_branch_name:remote_local_branch_name
# 报错error: src refspec REL_14_6 matches more than one
# 表示tag和branch重名
```
新增某个tag
```bash
git remote add remote_name
git fetch remote_name
git checkout tagname
git checkout -b branchname tagname
git push -u remote local_branch_name:remote_local_branch_name
# 报错error: src refspec REL_14_6 matches more than one
# 表示tag和branch重名
```
 关联远端分支
```sql
git branch --set-upstream-to=origin/8.0.30-oraclelike-sysdate
```