
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