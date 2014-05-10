setwd("/Users/divikhanna/Desktop/sustainability.stackexchange.com.7z Folder/")
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

