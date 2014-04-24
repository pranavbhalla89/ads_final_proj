library(sqldf)
#------------------------------------------------------------------- 
sqldf('select count(*)  from postsXMLDF') # 1369
sqldf('select distinct(PostTypeId) from postsXMLDF')  # 1 2 4 5
sqldf('select count(*)  from postsXMLDF where PostTypeId=1')  # 440 questions
sqldf('select count(*)  from postsXMLDF where PostTypeId=1 and AnswerCount=0')  # 3 questions are unanswered
sqldf('select count(*)  from postsXMLDF where PostTypeId=2')  # 851 answers
sqldf('select count(*)  from postsXMLDF where PostTypeId=4')  # 39
sqldf('select count(*)  from postsXMLDF where PostTypeId=5')  # 39
sqldf('select count(*) from postsXMLDF where PostTypeId is null') # 0

# ----  only accepted answers---------------------------------------
acceptedUsers <- sqldf (' select p1.id question_id,
                          p1.Tags Tags,
                          p2.OwnerUserId,
                          u.DisplayName,
                          u.Reputation
                 from   postsXMLDF p1, postsXMLDF p2 , usersXMLDF u
                 where  p1.AcceptedAnswerId = p2.id and
                        p2.OwnerUserId = u.Id
               ')
View(acceptedUsers) # 205 records # 71 distinct users 

# ----  all answers--------------------------------------------------

allUsers <- sqldf(' select  p1.id question_id,
                            p1.Tags Tags,
                            p2.OwnerUserId,
                            u.DisplayName,
                            u.Reputation
                    from    postsXMLDF p1, postsXMLDF p2 , usersXMLDF u
                    where   p1.Id = p2.ParentId and
                            p2.OwnerUserId = u.Id
                       ')

View(allUsers) # 843 records  # 208 distinct users

# ------------------------------------------------------

allUsersSorted <- sqldf('select * from allUsers order by OwnerUserId')
View(allUsersSorted)

x <- data.frame()


oneUser <- sqldf('select tags,DisplayName from allUsers where OwnerUserId=10')
View(oneUser)

for (i in 1:nrow(oneUser))
{
  tags <- na.omit(oneUser[i,])
  t    <- str_extract_all(oneUserTags[i,]$Tags, "(<)(.*?)(>)")
  x   <- rbind(x,as.data.frame(unlist(t)),as.data.frame(oneUser[i,]$DisplayName))
}

View(one)


newFrame   <- data.frame(matrix(ncol = 2))
colnames(newFrame) <- c("tags","users")
resFrame   <- data.frame(matrix(ncol = 2))
colnames(resFrame) <- c("tags","users")

tags  <- na.omit(oneUser[1,])
t     <- str_extract_all(oneUserTags[1,]$Tags, "(<)(.*?)(>)")
newFrame   <- c(as.data.frame(unlist(t)),as.data.frame(oneUser[1,]$DisplayName))

newFrame <- rbind.data.frame(newFrame,c(as.data.frame(unlist(t)),as.data.frame(oneUser[1,]$DisplayName)) )

View(newFrame)


tags  <- na.omit(oneUser[2,])
t     <- str_extract_all(oneUserTags[2,]$Tags, "(<)(.*?)(>)")
one   <- c(as.data.frame(unlist(t)),as.data.frame(oneUser[2,]$DisplayName))
one   <- c(as.data.frame(unlist(t)),as.data.frame(oneUser[2,]$DisplayName))


