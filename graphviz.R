library('ProjectTemplate')
load.project()

for (type in c('depends', 'suggests', 'imports'))
{
  filename <- file.path('reports', paste(type, '.dot', sep = ''))
  
  cat(paste('digraph', type, '{\n'), file = filename)
  
  for (i in 1:nrow(get(type)))
  {
    cat(paste('\t"', get(type)[i, 'Package'],
              '" -> "', get(type)[i, 'LinkedPackage'],
              '" [style = invis];\n', sep = ''),
        file = filename,
        append = TRUE)
  }
  
  cat('}\n', file = filename, append = TRUE)
}
