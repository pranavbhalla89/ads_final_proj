
ds <- postsXMLDF[postsXMLDF$PostTypeId == '1',c("Id", "AcceptedAnswerId", "Tags")]
QuestionsPost <- subset(postsXMLDF,select=c(PostTypeId=='1'))
View(QuestionsPost)
View(ds)
nrow(ds)
