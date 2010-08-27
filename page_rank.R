library('ProjectTemplate')
load.project()

all.packages <- Reduce(union, c(as.character(versionless.depends$Package),
                                as.character(versionless.depends$LinkedPackage),
                                as.character(versionless.suggests$Package),
                                as.character(versionless.suggests$Package),
                                as.character(versionless.imports$LinkedPackage),
                                as.character(versionless.imports$Package)))

package.numbers <- list()

for (i in 1:length(all.packages))
{
  package.numbers[[all.packages[i]]] <- i - 1
}

for (type in c('depends', 'suggests', 'imports'))
{
  edges <- c()
    
  for (i in 1:nrow(get(paste('versionless.', type, sep = ''))))
  {
    edges <- c(edges,
               package.numbers[[as.character(get(paste('versionless.', type, sep = ''))[i, 'Package'])]],
               package.numbers[[as.character(get(paste('versionless.', type, sep = ''))[i, 'LinkedPackage'])]])
  }
  
  cran.graph <- graph(edges,
                      n = length(all.packages),
                      directed = TRUE)
  
  assign(paste(type, '.page.rank.values', sep = ''),
         page.rank(cran.graph,
                   vids = V(cran.graph),
                   directed = TRUE,
                   damping = 0.85,
                   weights = NULL,
                   options = igraph.arpack.default))
}

ranks <- data.frame(Package = all.packages,
                    DependsPageRank = depends.page.rank.values$vector,
                    SuggestsPageRank = suggests.page.rank.values$vector,
                    ImportsPageRank = imports.page.rank.values$vector)

write.csv(ranks,
          file = file.path('data', 'ranks.csv'),
          row.names = FALSE)
