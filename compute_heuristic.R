source('count_analysis.R')

for (a in 1:5)
{
  for (b in 1:5)
  {
    ranks.and.views <- merge(ranks, views.counts, by.x = 'Package', by.y = 'Package')

    ranks.and.views <- transform(ranks.and.views,
                                 Quality = a * scale(DependsPageRank) + b * scale(ViewsIncluding))

    write.table(as.character(tail(ranks.and.views[order(ranks.and.views$Quality),], n = 25)$Package),
               file = file.path('reports', paste('package_quality_', a, '-', b, '.txt', sep = '')),
               row.names = FALSE,
               col.names = FALSE,
               quote = FALSE)
  }
}
