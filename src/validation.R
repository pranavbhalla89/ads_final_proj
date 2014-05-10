# mechanism to test, suppose this to be new question
#newQuesTag = testacceptedUsers$Tags[1]
#actualAnswereeId = testacceptedUsers$OwnerUserId[1]
#newQuesTagsList = str_extract_all(newQuesTag, "(<)(.*?)(>)")

#actualAnswereeList = vector('list', nrow(testacceptedUsers))
#allTagsList = vector('list', nrow(testacceptedUsers))
#atleastOneTagList = vector('list', nrow(testacceptedUsers))

# the data frame that holds the the accepted answer owner, 
# the list of users who have answered questions on all tags for the new question
# the list of users who have answered questions on atleast one tag of the new question

# ============================================================================
# TESTING: requires the following objects to exist
# testacceptedUsers - sql
# function: expandTags - validation
# hashByTag - validation
# hashByClusterNumber - validation
# collapsedUsers - sql
# ownerTagCountHash - sql
# truncatingLength - weight_model
# repWt - weight_model
# tagScoreWt - weight_model
# ============================================================================
testResultsDF = data.frame(matrix(ncol = 9))

for (k in 1:nrow(testacceptedUsers))
{
  actualAnswereeId = testacceptedUsers$OwnerUserId[k]
  #actualAnswereeList[[k]] = as.character(actualAnswereeId)
  
  newQuesTag = testacceptedUsers$Tags[k]
  newQuesTagsList = str_extract_all(newQuesTag, "(<)(.*?)(>)")
  
  # make sure you have registered the function below, and created the required hashes
  expandedClusterTags = expandTags(newQuesTagsList, hashByTag, hashByClusterNumber)
  expandedClusterTagsList = str_extract_all(expandedClusterTags, "(<)(.*?)(>)")
  
  # all users are valid at the start, we make em false when they don't match a tag
  validUser.AllTags = as.character(rep(TRUE, nrow(collapsedUsers)))
  # all users are invalid at the start, we make em true if they match even if match one tag
  validUser.AtleastOneTag = as.character(rep(FALSE, nrow(collapsedUsers)))
  # all users are invalid at the start, we make em true if they match even if match one tag
  # from the expanded list
  validUser.AtleastOneTagExpanded = as.character(rep(FALSE, nrow(collapsedUsers)))
  
  # the data frame that holds the scores for users for this question
  # ownerID, score
  # will add score from original tags and expanded tags
  scoreDF = data.frame(matrix(ncol = 2))
  names(scoreDF) = c("ownerUserId", "score")
  # we only store non-zero score users
  scoreIndex = 1
                           
  for (i in 1:nrow(collapsedUsers))
  {
    score = 0
    for (j in 1:length(unlist(newQuesTagsList)))
    {
      # mathcing the new questions tags
      tag = newQuesTagsList[[1]][j]
      if(validUser.AllTags[i] == TRUE)
        validUser.AllTags[i] = grepl(tag, collapsedUsers$Tags[i], fixed=TRUE)
        # changed to handle special chars in string <c++>
        #validUser.AllTags[i] = str_detect(collapsedUsers$Tags[i], tag)
      #if(validUser.AtleastOneTag[i] == FALSE)
       # validUser.AtleastOneTag[i] = grepl(tag, collapsedUsers$Tags[i], fixed=TRUE)
      if(grepl(tag, collapsedUsers$Tags[i], fixed=TRUE)){
        validUser.AtleastOneTag[i] = TRUE
        key = paste(collapsedUsers$OwnerUserId[i], tag, sep="")
        score = score + ownerTagCountHash[[key]]
      }
        # changed to handle special chars in string <c++>
        #validUser.AtleastOneTag[i] = str_detect(collapsedUsers$Tags[i], tag)
    }
    # matching the expanded tags
    if(length(unlist(expandedClusterTagsList)) != 0){
      for (j in 1:length(unlist(expandedClusterTagsList)))
      {
        tag = expandedClusterTagsList[[1]][j]
        #if(validUser.AtleastOneTagExpanded[i] == FALSE)
        #  validUser.AtleastOneTagExpanded[i] = grepl(tag, collapsedUsers$Tags[i], fixed=TRUE)
        if(grepl(tag, collapsedUsers$Tags[i], fixed=TRUE)){
          validUser.AtleastOneTagExpanded[i] = TRUE
          key = paste(collapsedUsers$OwnerUserId[i], tag, sep="")
          score = score + ownerTagCountHash[[key]]
        }
          # changed to handle special chars in string <c++>
          #validUser.AtleastOneTagExpanded[i] = str_detect(collapsedUsers$Tags[i], tag)
      }
    }
    # score computed for this user, save only non-zero score users
    if(score != 0){
      # weighted score based on rep and tag score
      rep = as.numeric(as.character(collapsedUsers$Reputation[i]))
      ownerUserId = as.numeric(as.character(collapsedUsers$OwnerUserId[i]))
      score  = (repWt*rep) + (tagScoreWt*score)
      scoreDF[scoreIndex,] = c(ownerUserId, score)
      scoreIndex = scoreIndex + 1
      
      #ownerUserId = as.numeric(as.character(collapsedUsers$OwnerUserId[i]))
      #scoreDF[scoreIndex,] = c(ownerUserId, score)
      #scoreIndex = scoreIndex + 1
    }
  }
  
  # user has answered questions on each tag
  # convert back to logical
  validUserIndex = which(as.logical(validUser.AllTags))
  matchedUser = collapsedUsers[validUserIndex, ]
  matchListAll = as.list(as.character(matchedUser$OwnerUserId))
  if(length(matchListAll) == 0)
    matchListAll = NA
  else
    matchListAll = do.call(paste, matchListAll)
  #allTagsList[[k]] = matchListAll
  #View(matchedUser)
  
  # user has answered question on atleast one tag
  # convert back to logical
  validUserIndex = which(as.logical(validUser.AtleastOneTag))
  matchedUser = collapsedUsers[validUserIndex, ]
  matchListAtleast = as.list(as.character(matchedUser$OwnerUserId))
  if(length(matchListAtleast) == 0)
    matchListAtleast = NA
  else
    matchListAtleast = do.call(paste, matchListAtleast)
  #atleastOneTagList[[k]] = matchListAtleast
  #View(matchedUser)
  
  # user has answered question on atleast one expanded tag
  # convert back to logical
  # include the users from the original question tag
  validUser.AtleastOneTag = as.logical(validUser.AtleastOneTagExpanded) | as.logical(validUser.AtleastOneTag)
  validUserIndex = which(as.logical(validUser.AtleastOneTag))
  matchedUser = collapsedUsers[validUserIndex, ]
  matchListAtleastExpanded = as.list(as.character(matchedUser$OwnerUserId))
  if(length(matchListAtleastExpanded) == 0)
    matchListAtleastExpanded = NA
  else
    matchListAtleastExpanded = do.call(paste, matchListAtleastExpanded)
  
  foundAll = str_detect(matchListAll, as.vector(actualAnswereeId))
  foundAtleast = str_detect(matchListAtleast, as.vector(actualAnswereeId))
  foundExpanded = str_detect(matchListAtleastExpanded, as.vector(actualAnswereeId))
  
  # ordering based on score
  scoreDF = scoreDF[ order(-scoreDF$score), ]
  # getting the user ids
  # top 10%
  #rankedByScore = do.call(paste, as.list(scoreDF[1:(nrow(collapsedUsers)*0.1),]$ownerUserId))
  # truncated based on optimum truncating length
  cutLength = truncatingLength
  if(truncatingLength > nrow(scoreDF)){
    cutLength = nrow(scoreDF)
  }
  rankedByScore = do.call(paste, as.list(scoreDF[1:cutLength,]$ownerUserId))
  
  foundRanked = str_detect(rankedByScore, as.vector(actualAnswereeId))
  
  testResultsDF[k,] = c(as.vector(actualAnswereeId), matchListAll, foundAll, 
                        matchListAtleast, foundAtleast, matchListAtleastExpanded,
                        foundExpanded, rankedByScore, foundRanked)
  print(k)
}
# loop ends here

names(testResultsDF) = c("actualAnsweree", "AllTagsMatchUser", "FOUND.All",  
                         "AtleastOneTagMatchUser", "FOUND.Atleast",
                         "AtleastOneTagMatchUserExpanded", "FOUND.Expanded",
                         "ExpandedRanked", "FOUND.Ranked")

View(testResultsDF)
# accuracy, not sure if this a good measure
table(testResultsDF$FOUND.All)["TRUE"] / nrow(testResultsDF)
table(testResultsDF$FOUND.Atleast)["TRUE"] / nrow(testResultsDF)
table(testResultsDF$FOUND.Expanded)["TRUE"] / nrow(testResultsDF)
table(testResultsDF$FOUND.Ranked)["TRUE"] / nrow(testResultsDF)

# ============================================================================
# using the clustered tags to expand the tags for the question
# ============================================================================
# assume the graph object has been setup
# cluster the tags
require(hash)
require(igraph)
wc <-  leading.eigenvector.community(graph)
wc <- edge.betweenness.community(graph)
wc <- walktrap.community(graph)
wc = infomap.community(graph)
clusteredTags = membership(wc)

# creating hashes for both ways
# <tag> : <cluster-it-belongs-to>
hashByTag = hash()
# <cluster-number> : <tag1><tag2><tag3><tag4>...
hashByClusterNumber = hash()
for (i in 1:length(clusteredTags))
{
  tagname = names(clusteredTags[i])
  clusterNumber = as.character(clusteredTags[i])
  hashByTag[[tagname]] = clusterNumber
  if(is.null(hashByClusterNumber[[clusterNumber]])){
    hashByClusterNumber[[clusterNumber]] = tagname
  }
  else{
    hashByClusterNumber[[clusterNumber]] = paste(hashByClusterNumber[[clusterNumber]], tagname, sep="")
  } 
}


# param1: new question's tag list
# param2: hash by tags based on clustering
# param2: hash by "clustering number" based on clustering
expandTags <- function(newQuesTagsList, hashByTag, hashByClusterNumber)
{ 
  expandedClusterTags = list()
  # expanding the tags using clustering
  for (j in 1:length(unlist(newQuesTagsList)))
  {
    clusterForTag = hashByTag[[newQuesTagsList[[1]][j]]]
    allTagsInCluster = hashByClusterNumber[[clusterForTag]]
    expandedClusterTags = c(expandedClusterTags, allTagsInCluster)
  }
  # make sure the tags in the list are unique
  expandedClusterTags = unique(unlist(expandedClusterTags))
  expandedClusterTags = do.call(paste, as.list(expandedClusterTags))
  
  # make sure the original tags are not present in the expanded list
  for (j in 1:length(unlist(newQuesTagsList)))
  {
    # changed to handle special chars in string <c++>
    #expandedClusterTags = str_replace_all(expandedClusterTags, newQuesTagsList[[1]][j], "")
    expandedClusterTags = gsub(newQuesTagsList[[1]][j], "", expandedClusterTags, fixed=TRUE)
  }
  expandedClusterTags
}


#str_detect(unlist(str_extract_all(collapsedUsers$Tags[i], "(<)(.*?)(>)")), "pb")
# ============================================================================
# creating a hash of the tags, still TODO
data.frame(do.call('rbind', strsplit(as.character(df$FOO),'|',fixed=TRUE)))
tagHash = data.frame(do.call('rbind', str_extract_all(
  collapsedUsers$Tags, "(<)(.*?)(>)")
)
)
df.all <- reshape(collapsedUsers, direction = "long", idvar="name", varying=4:6, sep="")

?reshape
vector('list', 5)
