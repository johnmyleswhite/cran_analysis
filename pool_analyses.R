library('ProjectTemplate')
load.project()

source('count_analysis.R')
source('page_rank.R')

summary.statistics <- merge(depends.counts,
                            merge(suggests.counts, imports.counts,
                                  by.x = 'Package', by.y = 'Package'),
                            by.x = 'Package', by.y = 'Package')

summary.statistics <- merge(summary.statistics, ranks, by.x = 'Package', by.y = 'Package')

write.csv(summary.statistics,
          file = file.path('data', 'summary_statistics.csv'),
          row.names = FALSE)

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

png('graphs/depends_vs_depends_pagerank.png')
ggplot(summary.statistics, aes(x = Depended, y = DependsPageRank)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE)
dev.off()

png('graphs/suggests_vs_suggests_pagerank.png')
ggplot(summary.statistics, aes(x = Suggested, y = SuggestsPageRank)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE)
dev.off()

png('graphs/imports_vs_imports_pagerank.png')
ggplot(summary.statistics, aes(x = Imported, y = ImportsPageRank)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE)
dev.off()
