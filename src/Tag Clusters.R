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
t2 <- head(t2,.1*length(t1))

#Entire graph
pairs <- data.frame()
for (i in 1:length(t)){ 
  pairs <- c(pairs, t3 <- if(length(t[[i]])>=2) combn(t[[i]],2,simplify=FALSE))}
matrix <- do.call(rbind,pairs)
graph <- graph.data.frame(matrix,directed=FALSE, vertices=t1)
E(graph)
V(graph)
E(graph)$width <- count.multiple(graph)
igraph.options(vertex.label=t1, vertex.shape="circle",vertex.size=1)
plot.igraph(graph, layout=layout.circle, edge.curved=FALSE)
wc <-  edge.betweenness.community(graph)
modularity(wc)
membership(wc)
plot(wc, graph)
plot(graph, vertex.color=membership(wc))

#100 random tags
test <- matrix[sample(nrow(matrix), 100),]
v <- matrix(rbind(test[,1],test[,2]),ncol=1)
graph <- graph.data.frame(test,directed=FALSE, vertices=unique(v))
E(graph)$width <- count.multiple(graph)
igraph.options(vertex.label=NA,vertex.label.cex=0.9, vertex.shape="circle",vertex.size=1)
plot.igraph(graph, layout=layout.circle, edge.curved=FALSE)
wc <-  edge.betweenness.community(graph)
modularity(wc)
membership(wc)
plot(wc, graph)

#Top 20% tags
require(scales)
topTags <- subset(matrix, matrix[,1] %in% t2[,1] & matrix[,2] %in% t2[,1])
u <- matrix(rbind(topTags[,1],topTags[,2]),ncol=1)
graph <- graph.data.frame(topTags,directed=FALSE, vertices=unique(u))
E(graph)
V(graph)
E(graph)$width <- count.multiple(graph)
igraph.options(vertex.label=V(graph)$name,vertex.label.cex=0, vertex.shape="circle",
             vertex.size=10)
#---Label positioning
radian.rescale <- function(x, start=0, direction=1) {
  c.rotate <- function(x) (x + start) %% (2 * pi) * direction
  c.rotate(scales::rescale(x, c(0, 2 * pi), range(x)))
}
position <- radian.rescale(x=1:nrow(t2), direction=-1, start=0)
plot.igraph(graph, layout=layout.circle,vertex.label.dist=1,vertex.label.degree=position, edge.curved=FALSE)
wc <-  edge.betweenness.community(graph)
modularity(wc)
membership(wc)
plot(wc, graph)
plot(graph, vertex.color=membership(wc))

