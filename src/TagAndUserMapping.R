# Run sql.r Before running this script
# To do: Retrieve more information of user

oneUser <- sqldf('select tags,DisplayName,OwnerUserId from allUsers')
View(oneUser)

# Create a new Data Frame: Keep only one tag and related User's info in one row

newFrame <- data.frame(tags=character(), 
                       User=character(), 
                       stringsAsFactors=FALSE) 

for (i in 1:nrow(oneUser))
{
  t <- str_extract_all(oneUser[i,]$Tags, "(<)(.*?)(>)")
  z <- strsplit(t[[1]], " ")
  # This is to remove the paratheses around the tags
  z <- substr(z, 2, nchar(z)-1)
  z1 <- as.data.frame(unlist(z))  
  names(z1)[1]<-paste("tags")
  z1$users <- rep(oneUser[i,]$DisplayName,length(z))  
  newFrame <- rbind(newFrame,z1)
  
}

TagAndUsers <- newFrame
View(TagAndUsers)
