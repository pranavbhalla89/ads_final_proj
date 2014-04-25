# mechanism to test, suppose this to be new question
newQuesTag = testacceptedUsers$Tags[1]
actualAnswereeId = testacceptedUsers$OwnerUserId[1]
newQuesTagsList = str_extract_all(newQuestag, "(<)(.*?)(>)")

actualAnswereeList = vector('list', nrow(testacceptedUsers))
allTagsList = vector('list', nrow(testacceptedUsers))
atleastOneTagList = vector('list', nrow(testacceptedUsers))
df = data.frame(matrix(ncol = 3))

for (k in 1:nrow(testacceptedUsers))
{
  actualAnswereeId = testacceptedUsers$OwnerUserId[k]
  #actualAnswereeList[[k]] = as.character(actualAnswereeId)
  
  newQuesTag = testacceptedUsers$Tags[k]
  newQuesTagsList = str_extract_all(newQuesTag, "(<)(.*?)(>)")
  
  # all users are valid at the start, we make em false when they don't match a tag
  validUser.AllTags = as.character(rep(TRUE, nrow(collapsedUsers)))
  # all users are invalid at the start, we make em true if they match even if match one tag
  validUser.AtleastOneTag = as.character(rep(FALSE, nrow(collapsedUsers)))
  
  for (i in 1:nrow(collapsedUsers))
  {
    for (j in 1:length(unlist(newQuesTagsList)))
    {
      tag = newQuesTagsList[[1]][j]
      if(validUser.AllTags[i] == TRUE)
        validUser.AllTags[i] = str_detect(collapsedUsers$Tags[i], tag)
      if(validUser.AtleastOneTag[i] == FALSE)
        validUser.AtleastOneTag[i] = str_detect(collapsedUsers$Tags[i], tag)
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
  
  df[k,] = c(as.vector(actualAnswereeId), matchListAll, matchListAtleast) 
}

names(df) = c("actualAnsweree", "AllTagsMatchUser", "AtleastOneTagMatchUser")

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
