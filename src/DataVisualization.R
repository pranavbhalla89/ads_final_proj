require(ggplot2)
require(stringr)
require(sqldf)

##########################################################################
# Quarter-wise Growth in Questions Posted and Questions left unanswered

Result: Stats Stack Exchange has seen Tremendous growth in the questions posted. 
Increased number of questions are accompanied by increased number of unanswered posts
##########################################################################
data <- load("postsXMLDF.Rda")
new <- postsXMLDF[(postsXMLDF$PostTypeId ==1),c("PostTypeId","CreationDate","AnswerCount")]

date <- seq(from = as.Date("2010/5/30"), by="week", length=10) ## Example data
cuts <- seq(from = as.Date("2010-01-01"), by="quarter",length=18) 
labs <- paste0("Q", 1:17)
cut(as.Date(new$CreationDate), breaks = cuts, labels=labs)
new$CreationQuarter <- cut(as.Date(new$CreationDate), breaks = cuts, labels=labs)
new$AnsweredOrNot  <- factor(ifelse(is.na(new$AnswerCount),"Not Answered","Answered"))

head(new)

qplot(factor(CreationQuarter), data=new, geom="bar", fill=factor(AnsweredOrNot)) + labs(title = "Distribution of Questions posted in Stats StackExchange\n\n", subtitle="Displays") +
  xlab("Quarterly Time Division from 2010-01-01 till 2014-03-01") +
  ylab("Number of Questions posted") + scale_fill_discrete(name = "")


#########################################################################
#How much time does it take on average for questions to be answered?
#x-axis: Time series (2009-today)
#y-axis: Creation date of answer - Creation date of Question

#Result: Among the questions which are answered Most of the Questions are answered within 10 mins. Very few of them are answered in next few hours
########################################################################

TimeToAns <- sqldf (' select p1.id question_id,
                          p1.creationDate Ques_createDate,
                          p2.id answer_id,
                    p2.creationDate Ans_createDate
                    from   postsXMLDF p1, postsXMLDF p2 , usersXMLDF u
                    where  p1.AcceptedAnswerId = p2.id and
                    p2.OwnerUserId = u.Id
                    ')

head(TimeToAns)
timeElapsed <- difftime(as.Date(TimeToAns$Ans_createDate), as.Date(TimeToAns$Ques_createDate), units="mins")
TimeToAns$timeElapsed <- as.factor(timeElapsed)
range(timeElapsed)

cuts <- c(-1,10,30,60,120,3600,7200,1736650)
labs <- c("< 10 mins", "11-30 mins", "31-50 mins","1-2 hrs","2-24 hrs","1-2 days",">2 days")
d <- cut(as.numeric(timeElapsed), breaks = cuts, labels=labs)
ggplot(na.omit(as.data.frame(d)), aes(x=d)) + geom_bar(fill="blue") + scale_x_discrete(drop=FALSE) + xlab("Time Range to Answer") + ylab("Number of questions answered") + labs(title = "Distribution of Time to Answer the Questions on Stats StackExchange\n\n")
                    
#######################################################################
# Accuracy as function of length
#######################################################################


