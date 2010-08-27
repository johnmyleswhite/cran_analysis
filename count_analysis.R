library('ProjectTemplate')
load.project()

for (type in c('depends', 'suggests', 'imports'))
{
  assign(paste(type, '.counts', sep = ''), ddply(get(type), c('LinkedPackage'), nrow))
  png(file.path('graphs', paste(type, '_histogram.png', sep = '')))
  qplot(get(paste(type, '.counts', sep = ''))$V1, binwidth = 1)
  dev.off()
}

names(depends.counts) <- c('Package', 'Depended')
names(imports.counts) <- c('Package', 'Imported')
names(suggests.counts) <- c('Package', 'Suggested')

summary.statistics <- merge(depends.counts,
                            merge(suggests.counts, imports.counts,
                                  by.x = 'Package', by.y = 'Package'),
                            by.x = 'Package', by.y = 'Package')

png('graphs/depends_vs_imports.png')
ggplot(summary.statistics, aes(x = Depended, y = Imported)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE)
dev.off()

png('graphs/depends_vs_suggests.png')
ggplot(summary.statistics, aes(x = Depended, y = Suggested)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE)
dev.off()

png('graphs/imports_vs_suggests.png')
ggplot(summary.statistics, aes(x = Imported, y = Suggested)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE)
dev.off()
