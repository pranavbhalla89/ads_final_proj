# Handles multiple tags in input
# To Do : Add more features of users. Sort by Reputation, Get Frequency. 

GetTopAnswerers <- function(x) {
  Mapping <- data.frame(User_name=character(), 
                        Frequency =numeric(), 
                        Reputation = numeric(),
                        stringsAsFactors=FALSE)
  users <- list()
  for(i in 1:nrow(TagAndUsers))
    if ( TagAndUsers[i,1] %in% x)
    {
      users[[length(users) + 1L]] <- as.character(TagAndUsers[i,2])
      
    }
  
  #cbind( Name = as.character(users, Freq=table(users))
  users
}

GetTopAnswerers(c("husbandry","food"))
