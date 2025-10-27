# 周报 {{date:YYYY年MM月第W周}} 
> 日期范围：{{date:YYYY-MM-DD}} 至 {{date:YYYY-MM-DD+6d}} 
## 本周工作汇总 
```dataview
table file.mday as 更新时间
WHERE 
  file.name >= "{{date:YYYY-MM-DD}}"
  AND file.name <= "{{date:YYYY-MM-DD+6d}}"
SORT file.name ASC
```
（`TABLE 工作内容 AS "今日工作" FROM "daily" WHERE file.name >= "{{date:YYYY-MM-DD}}" AND file.name <= "{{date:YYYY-MM-DD+6d}}"`） ## 本周完成任务 （同样可使用Dataview语法，如`TASK FROM "tasks" WHERE status = "DONE" AND completion >= "{{date:YYYY-MM-DD}}" AND completion <= "{{date:YYYY-MM-DD+6d}}"`）


<%*
async function createIfNotExists(tp, filepath){
	if (!(await tp.file.exists(filepath))){
		app.fileManager.createAndOpenMarkdownFile(filepath)
	}
}

await createIfNotExists(tp, "Journal/Daily Journal/" + tp.date.now("YYYY/YYYY-MM-DD") + ".md")

await createIfNotExists(tp, "Journal/Weekly Journal/" + tp.date.now("YYYY/gggg-[W]ww") + ".md")

await createIfNotExists(tp, "Journal/Monthly Journal/" + tp.date.now("YYYY/YYYY-MM") + ".md")

await createIfNotExists(tp, "Journal/Yearly Journal/" + tp.date.now("YYYY") + ".md")
%>