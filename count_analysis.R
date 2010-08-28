library('ProjectTemplate')
load.project()

for (type in c('depends', 'suggests', 'imports', 'views'))
{
  assign(paste(type, '.counts', sep = ''), ddply(get(type), c('LinkedPackage'), nrow))
  png(file.path('graphs', paste(type, '_histogram.png', sep = '')))
  qplot(get(paste(type, '.counts', sep = ''))$V1, binwidth = 1)
  dev.off()
}

names(depends.counts) <- c('Package', 'Depended')
names(imports.counts) <- c('Package', 'Imported')
names(suggests.counts) <- c('Package', 'Suggested')
names(views.counts) <- c('Package', 'ViewsIncluding')
