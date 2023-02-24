#author
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