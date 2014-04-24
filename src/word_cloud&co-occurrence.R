#setwd("/Users/divikhanna/Desktop/sustainability.stackexchange.com.7z Folder/")
setwd("/Users/Apple/Columbia/Github/ads_final_proj/data/sustainability.stackexchange.com/")
require(XML)
require(plyr)

datapostLinks <- xmlParse("PostLinks.xml", getDTD = F)
postLinksXMLDF = ldply(xmlToList(datapostLinks))
postLinksXMLDF = postLinksXMLDF[,-1]
View(postLinksXMLDF)

databadges <- xmlParse("Badges.xml", getDTD = F)
badgesXMLDF = ldply(xmlToList(databadges))
badgesXMLDF = badgesXMLDF[,-1]
View(badgesXMLDF)

datavotes <- xmlParse("Votes.xml", getDTD = F)
votesXMLDF = ldply(llply(xmlToList(datavotes), function(x) rbind.fill(data.frame(t(x)))))
votesXMLDF = votesXMLDF[,-1]
View(votesXMLDF)

dataposts <- xmlParse("Posts.xml", getDTD = F)
postsXMLDF = ldply(llply(xmlToList(dataposts), function(x) rbind.fill(data.frame(t(x)))))
postsXMLDF = postsXMLDF[,-1]
View(postsXMLDF)

datacomments <- xmlParse("Comments.xml", getDTD = F)
commentsXMLDF = ldply(llply(xmlToList(datacomments), function(x) rbind.fill(data.frame(t(x)))))
commentsXMLDF = commentsXMLDF[,-1]
View(commentsXMLDF)

datapostHistory <- xmlParse("PostHistory.xml", getDTD = F)
postHistoryXMLDF = ldply(llply(xmlToList(datapostHistory), function(x) rbind.fill(data.frame(t(x)))))
postHistoryXMLDF = postHistoryXMLDF[,-1]
View(postHistoryXMLDF)

datausers <- xmlParse("Users.xml", getDTD = F)
usersXMLDF = ldply(llply(xmlToList(datausers), function(x) rbind.fill(data.frame(t(x)))))
usersXMLDF = usersXMLDF[,-1]
View(usersXMLDF)


#================================================================================
names(postsXMLDF)
postsXMLDF$AnswerCount = as.numeric(postsXMLDF$AnswerCount)
summary(postsXMLDF$AnswerCount)
# questions in the data set
questions = postsXMLDF[postsXMLDF$PostTypeId == 1, ]
NROW(questions)

# FALSE = number of questions in data, TRUE = no accepted answer yet
count(is.na(questions$AcceptedAnswerId))
# no of question for which answer count is 0 or NA
count(questions$AnswerCount == 0 | is.na(questions$AnswerCount) )

# 206 questions have been answered out of 440
count(is.na(postsXMLDF$AcceptedAnswerId))

#================================================================================
# tag cloud
#================================================================================

require(wordcloud)
library(stringr)

tags = postsXMLDF[!is.na(postsXMLDF$Tags),]$Tags
tags = as.data.frame(tags)
tagsString = apply(tags, 2, paste, collapse="")

angleBracketsRegEx <- "[<>]+"
tagsString = str_replace_all(tagsString, angleBracketsRegEx, " ")

wordcloud(tagsString, scale=c(5,0.5), max.words=100, random.order=FALSE, rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, "Dark2"))


#================================================================================
# clustering tags
# need to make a co-occurence matrix
#     tag1  tag2 tag3
#tag1 [ 0    5   2   ]
#tag2 [ 5    0   10  ]
#tag3 [ 2    10  0   ]
#================================================================================
library(qdap)
library(igraph)
library(cluster)
library(NbClust)

tagsList = strsplit(tagsString, "[ ]+")
uniqueTags = unique(unlist(tagsList))

class(tags)
coMatrix = laply(tags, str_replace_all, angleBracketsRegEx, " ")
coMatrix = as.data.frame(coMatrix)
coMatrix = data.frame(row = 1:nrow(tags), tagsList = coMatrix$coMatrix)
names(coMatrix)

# word freq matrix
wfmTags = t(with(coMatrix, wfm(tagsList, row)))
dim(wfmTags)
# matrix multiplication
co_occurrence <- t(wfmTags) %*% wfmTags
# set diagonal to 0
diag(co_occurrence) <- 0
head(co_occurrence)

# heirarchical clustering
hc <- hclust(dist(co_occurrence))
View(as.matrix(dist(co_occurrence)))
plot(hc, cex=0.5)
rect.hclust(hc, k=2)

# gap statistic to calculate # of clusters, cannot use hclust with this
clusGap(co_occurrence, kmeans, 10, B = 100, verbose = interactive())
?clusGap

# NbClust
nb <- NbClust(d, diss="NULL", distance = "euclidean", 
              min.nc=2, max.nc=15, method = "kmeans", 
              index = "alllong", alphaBeale = 0.1)
hist(nb$Best.nc[1,], breaks = max(na.omit(nb$Best.nc[1,])))


graph <- graph.adjacency(co_occurrence,
                         weighted=TRUE,
                         mode="undirected",
                         diag=FALSE)
graph <- simplify(graph)
# set labels and degrees of vertices
V(graph)$label <- V(graph)$name
V(graph)$degree <- degree(graph)
plot(graph)


# build a graph from the above matrix
g <- graph.adjacency(co_occurrence, weighted=T, mode = "undirected")
# remove loops
g <- simplify(g)
# set labels and degrees of vertices
V(g)$label <- V(g)$name
V(g)$degree <- degree(g)

# set seed to make the layout reproducible
set.seed(3952)
layout1 <- layout.fruchterman.reingold(g)
plot(g, layout=layout1)
# an interactive plot
tkplot(g, layout=layout.kamada.kawai)



# term frequencies
class(wfmTags)
colnames(wfmTags)
termFreq = termco(tagsString, , colnames(wfmTags))
termFreq = term_match(tagsString, colnames(wfmTags))

vertex.size=total_occurrences*18,
#vertex.label=colnames(wfmTags),
vertex.label=NA
add.vertex.names=FALSE
set.seed(3)
plot.igraph(graph,edge.width=E(graph)$weight*8, vertex.label=NA)

#================================================================================


#dat <- data.frame(year=1945:(1945+10), summary=DATA$state) 
# t(with(dat, wfm(summary, year)))
##    year                               summary
## 1  1945         Computer is fun. Not too fun.

n    <- 10
apps <- LETTERS[1:n]
data <- matrix(0,n,n)
rownames(data) <- apps
colnames(data) <- apps

# create artificial clusters
data[1:3,1:5] <- matrix(sample(3:5,15,replace=T),3,5)
data[6:9,4:8] <- matrix(sample(1:3,20,replace=T),4,5)

# clustering
hc <- hclust(dist(data))
plot(hc)
rect.hclust(hc, k=2)