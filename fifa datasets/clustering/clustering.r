df <- read.csv("C:/Users/admin/OneDrive/Documentos antigo/Projetos_jl/fifa datasets/data/players_22.csv", encoding="UTF-8")

library(factoextra)
library(cluster)
library(fastcluster)


dados <- df[,c(38,39,40,41,42,43)]
rownames(dados) <- df[,1]

dados <- scale(dados)

idxNA <- which(is.na(dados))
dados <- dados[-idxNA,]

k <- 7

# Aglomerativo

agl <- hclust(dist(dados))

cluster_agl <- cutree(agl, k = k)
fviz_cluster(list(data = dados, cluster = cluster_agl)) +
  labs(subtitle="Aglomerativo", size=8)

sil_agl <- mean(silhouette(cluster_agl, daisy(dados))[,3])
clh_agl <- calinhara(dados, cluster_agl)

# k-means

km.res <- kmeans(dados, k)

fviz_cluster(km.res, data=dados) +
  labs(subtitle="K-means", size=8)

km.res$centers



sil_kmeans <- mean(silhouette(km.res$cluster, daisy(dados))[,3])
clh_kmeans <- calinhara(dados, km.res$cluster)



fviz_nbclust(dados, kmeans, method = "wss")
 
# Método silhouette
fviz_nbclust(dados, kmeans, method = "silhouette")



library(ramify)

clusterizado <- hcat(dados, km.res$cluster)

