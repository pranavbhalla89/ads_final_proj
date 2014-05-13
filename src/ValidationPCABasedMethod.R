getwd()
setwd("C:\\Users\\Hum\\Documents\\GitHub\\sustainability.stackexchange.com.7z Folder\\")
require(XML)
require(plyr)
require(stringr)
library(sqldf)
library(RB2)

datapostsNEW <- xmlParse("Posts.xml", getDTD = F)
postsXMLDFNEW = ldply(llply(xmlToList(datapostsNEW), function(x) rbind.fill(data.frame(t(x)))))
postsXMLDFNEW = postsXMLDFNEW[,-1]
dim(postsXMLDFNEW)


##############################################################
# Test Data Preparation
##############################################################
#
# Training and Test Data Splitting.  There are 1369 observations in training set
# New Dataset has cumulative 1649 entries. By subsetting new entries out of it, we
# have our test set (280)
begin <- 1369
test <- tail(postsXMLDFNEW,280)

#Questions
qtest <- subset(test[test$PostTypeId == 1, ], select=c("Id", "Body", "AcceptedAnswerId","Title", "Tags", "AnswerCount"))
qtest <- qtest[!(qtest$AnswerCount == "0"),]
dim(qtest) #63
View(qtest)

#Answers
atest <- na.omit(subset(test[test$PostTypeId == 2, ], select=c("ParentId", "CreationDate", "Score", "OwnerUserId")))
dim(atest) #165
atest$ParentId <- as.numeric(as.character(atest$ParentId))
atest$OwnerUserId <- as.numeric(as.character(atest$OwnerUserId))

allUsers <- sqldf(' select  p1.id question_id, p1.Tags,
                            p2.OwnerUserId
                     from  qtest p1, atest p2
                    where p1.Id = p2.ParentId
                  ')
View(allUsers) 
#this has questions with associated tags and answerees
collapsedUsers = aggregate( OwnerUserId ~ question_id + Tags, allUsers, paste, collapse = ",")
View(collapsedUsers)


##############################################################
#Validation
##############################################################

#Load the model
setwd("./Sustain_PDA/")
load("cTagHash.Rda")
load("cUserHash.Rda")
load("model.Rda")

#Validation
testacceptedUsers <- collapsedUsers
testResultsDF = data.frame(matrix(ncol = 3))
class(testacceptedUsers)
testIndex = 1
for (k in 1:nrow(testacceptedUsers))
{
  allAnswerees = testacceptedUsers$OwnerUserId[k]
  newQuesTag = testacceptedUsers$Tags[k]
  newQuesTagsList = str_extract_all(newQuesTag, "(<)(.*?)(>)")
  
  scoreDF = data.frame(matrix(ncol = 2))
  names(scoreDF) = c("ownerUserId", "score")
  
  for (j in 1:length(unlist(newQuesTagsList)))
  {
    tag = newQuesTagsList[[1]][j]
    tag <- substr(tag, 2, nchar(tag)-1)
    for (i in 1:length(cTagHash)){
      allTagsInCluster = paste(cTagHash[[i]], collapse=" ")
      if(grepl(tag, allTagsInCluster, fixed=TRUE)){
        # found the tag in cluster i
        comNum = cTagHash[[i]][1]
        comNum <- as.numeric(comNum)
        usersInCluster = model[[comNum]]$OwnerUserId
        
        for (p in 1:length(usersInCluster)){
          rankScore = model[[comNum]]$Rank[p]
           if(rankScore > 0){
            ownerUserId = usersInCluster[p]
            # initialize the score
            if(is.na(scoreDF[ownerUserId, 1]))
              scoreDF[ownerUserId, ] = c(ownerUserId, 0)
            # increment the score
            scoreDF[ownerUserId, ] = c(ownerUserId, rankScore + scoreDF[ownerUserId,]$score)
          } 
        }
        # already found the tag, no need to loop anymore
        break
      }
    }
    
  }# end of looping throught the tags of a question
  
    # ordering based on score
    scoreDF = na.omit(scoreDF[ order(-scoreDF$score), ])
    
    rankedByScore = do.call(paste, as.list(scoreDF[scoreDF$score != 0,]$ownerUserId))
    #New Tags
    if(length(rankedByScore) == 0)
    {
      print("tags are new, no history found")
    }
    else{
    answereeList = str_split(allAnswerees, ",")
    
    for(i in 1:length(answereeList)){
      foundRanked = str_detect(rankedByScore, answereeList[[1]][i])
      print(foundRanked)
      if(foundRanked)
        break
    }
    testResultsDF[testIndex,] = c(allAnswerees, rankedByScore, foundRanked)
    testIndex = testIndex + 1
  }
  
}

#Final Output
names(testResultsDF) = c("ActualAnswerees", "SuggestedRankedAnswerees", "FOUND")
View(testResultsDF)

#Accuracy
accuracy <- as.data.frame(table(testResultsDF$FOUND))[2,2]/nrow(testResultsDF)

accuracy
