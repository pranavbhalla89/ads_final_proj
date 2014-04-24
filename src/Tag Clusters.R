#==============================================================================
#Plotting Tag Relationships
require(stringr)
require(igraph)
tags <- postsXMLDF$Tags
tags <- na.omit(tags)
tags <- as.character(tags)
t <- str_extract_all(tags, "(<)(.*?)(>)")
t1 <- unique(unlist(t))
t2 <- as.data.frame(table(unlist(t)))
t2 <- t2[with(t2, order(-Freq)),]
t2 <- head(t2,20)

#Entire graph
pairs <- data.frame()
for (i in 1:length(t)){ 
  pairs <- c(pairs, t3 <- if(length(t[[i]])>=2) combn(t[[i]],2,simplify=FALSE))}
matrix <- do.call(rbind,pairs)
graph <- graph.data.frame(matrix,directed=FALSE, vertices=t1)
igraph.options(vertex.label=NA, vertex.shape="circle",vertex.size=1)
plot.igraph(graph, layout=layout.circle, edge.curved=FALSE)
wc <-  leading.eigenvector.community(graph)
modularity(wc)
membership(wc)
plot(wc, graph)

#100 random tags
test <- matrix[sample(nrow(matrix), 50),]
v=matrix(rbind(test[,1],test[,2]),ncol=1)
graph <- graph.data.frame(test,directed=FALSE, vertices=unique(v))
igraph.options(vertex.label=NA, vertex.shape="circle",vertex.size=1)
plot.igraph(graph, layout=layout.circle, edge.curved=TRUE)
wc <-  walktrap.community(graph)
modularity(wc)
membership(wc)
plot(wc, graph)


#Top 20 tags .....error!
#pairs <- data.frame()
#for (i in 1:length(t)){
#for (j in 1:20){
#for (k in 1:length(t[[i]])){
#if(t2[j,1]==t[[i]][k]){
#pairs <- c(pairs, t3 <- if(length(t[[i]])>=2) combn(t[[i]],2,simplify=FALSE))}}}}
#matrix <- do.call(rbind,pairs)
#graph <- graph.data.frame(matrix,directed=FALSE, vertices=t2[,1])
#igraph.options(vertex.label=NA, vertex.shape="circle",vertex.size=1)
#plot.igraph(graph, layout=layout.sphere, edge.curved=FALSE)
