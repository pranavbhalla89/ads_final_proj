# ==============================================================================
# building a model for assigning weights to reputation and tag score

# Data frame like
# <Reputation> <Tag Score> <Output 1/0>
# per question we will have nrow(users) rows, all expect one(actual answeree) output will be false
modelDF = data.frame(matrix(ncol = 3))
names(modelDF) = c("reputation", "score", "output")
scoreIndex = 1

# for each questions in the training set
for (k in 1:nrow(trainacceptedUsers))
{
  actualAnswereeId = trainacceptedUsers$OwnerUserId[k]
  #actualAnswereeList[[k]] = as.character(actualAnswereeId)
  
  newQuesTag = trainacceptedUsers$Tags[k]
  newQuesTagsList = str_extract_all(newQuesTag, "(<)(.*?)(>)")
  
  # make sure you have registered the function below, and created the required hashes
  expandedClusterTags = expandTags(newQuesTagsList, hashByTag, hashByClusterNumber)
  expandedClusterTagsList = str_extract_all(expandedClusterTags, "(<)(.*?)(>)")
  
  # loop through all the users
  for (i in 1:nrow(collapsedUsers))
  {
    score = 0
    for (j in 1:length(unlist(newQuesTagsList)))
    {
      # mathcing the new questions tags
      tag = newQuesTagsList[[1]][j]
      if(grepl(tag, collapsedUsers$Tags[i], fixed=TRUE)){
        key = paste(collapsedUsers$OwnerUserId[i], tag, sep="")
        score = score + ownerTagCountHash[[key]]
      }
    }
    # matching the expanded tags
    if(length(unlist(expandedClusterTagsList)) != 0){
      for (j in 1:length(unlist(expandedClusterTagsList)))
      {
        tag = expandedClusterTagsList[[1]][j]
        
        if(grepl(tag, collapsedUsers$Tags[i], fixed=TRUE)){
          key = paste(collapsedUsers$OwnerUserId[i], tag, sep="")
          score = score + ownerTagCountHash[[key]]
        }
      }
    }
    # save the reputation, score and output class (only in case the user has a score)
    if(score != 0){
      modelDF[scoreIndex,] = c(collapsedUsers$Reputation[i], score, collapsedUsers$OwnerUserId[i] == actualAnswereeId)
      scoreIndex = scoreIndex + 1
    }    
  }# for loop i, done with all the users
  print(k)
}# for loop k, done with all the training questions

dim(modelDF)

weight_reg <- lm(output ~ reputation + score, data=modelDF)
# coeff for reputation
repWt = as.numeric(weight_reg$coefficients[2])
# coeff for tag score
tagScoreWt = as.numeric(weight_reg$coefficients[3])




# ==============================================================================
# finding out a good truncating length
# ==============================================================================
truncatingDF = data.frame(matrix(ncol = 3))

for (k in 1:nrow(trainacceptedUsers))
{
  actualAnswereeId = trainacceptedUsers$OwnerUserId[k]
  #actualAnswereeList[[k]] = as.character(actualAnswereeId)
  
  newQuesTag = trainacceptedUsers$Tags[k]
  newQuesTagsList = str_extract_all(newQuesTag, "(<)(.*?)(>)")
  
  # make sure you have registered the function below, and created the required hashes
  expandedClusterTags = expandTags(newQuesTagsList, hashByTag, hashByClusterNumber)
  expandedClusterTagsList = str_extract_all(expandedClusterTags, "(<)(.*?)(>)")
  
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
      tag = newQuesTagsList[[1]][j]
      if(grepl(tag, collapsedUsers$Tags[i], fixed=TRUE)){
        validUser.AtleastOneTag[i] = TRUE
        key = paste(collapsedUsers$OwnerUserId[i], tag, sep="")
        score = score + ownerTagCountHash[[key]]
      }
    }
    # matching the expanded tags
    if(length(unlist(expandedClusterTagsList)) != 0){
      for (j in 1:length(unlist(expandedClusterTagsList)))
      {
        tag = expandedClusterTagsList[[1]][j]
        
        if(grepl(tag, collapsedUsers$Tags[i], fixed=TRUE)){
          validUser.AtleastOneTagExpanded[i] = TRUE
          key = paste(collapsedUsers$OwnerUserId[i], tag, sep="")
          score = score + ownerTagCountHash[[key]]
        }
      }
    }
    # score computed for this user, save only non-zero score users
    if(score != 0){
      rep = as.numeric(as.character(collapsedUsers$Reputation[i]))
      ownerUserId = as.numeric(as.character(collapsedUsers$OwnerUserId[i]))
      score  = (repWt*rep) + (tagScoreWt*score)
      scoreDF[scoreIndex,] = c(ownerUserId, score)
      scoreIndex = scoreIndex + 1
    }
  }
  
  # user has answered question on atleast one tag
  # convert back to logical
  validUserIndex = which(as.logical(validUser.AtleastOneTag))
  matchedUser = collapsedUsers[validUserIndex, ]
  matchListAtleast = as.list(as.character(matchedUser$OwnerUserId))
  if(length(matchListAtleast) == 0)
    matchListAtleast = NA
  else
    matchListAtleast = do.call(paste, matchListAtleast)
  
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
  
  foundAtleast = str_detect(matchListAtleast, as.vector(actualAnswereeId))
  foundExpanded = str_detect(matchListAtleastExpanded, as.vector(actualAnswereeId))
  
  # ordering based on score
  scoreDF = scoreDF[ order(-scoreDF$score), ]
  # getting the user ids
  rankedByScore = do.call(paste, as.list(scoreDF$ownerUserId))
  # need to detect position to find the optimum truncating length
  location = str_locate(rankedByScore, as.vector(actualAnswereeId))
  foundAt = NA
  if(!is.na(location[2])){
    minString = substr(rankedByScore, 1, location[2])
    foundAt = length(unlist(str_extract_all(minString, "[0-9]+")))
  }
  
  truncatingDF[k,] = c(as.vector(actualAnswereeId), rankedByScore, as.numeric(foundAt))
  print(k)
}
# loop ends here

names(truncatingDF) = c("actualAnsweree", "ordered.by.score", "found.at")

View(truncatingDF)
# truncating length
truncatingLength = mean(as.numeric(na.omit(truncatingDF$found.at)))
truncatingLength = ceiling(truncatingLength)
