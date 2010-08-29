library('ProjectTemplate')
load.project()

package.tarballs <- dir('.')
field.names <- list('depends' = 'Depends', 'suggests' = 'Suggests', 'imports' = 'Imports')
dates <- c('02082009', '11192009', '08282010')

for (date in dates)
{
  setwd(paste('/Users/johnmyleswhite/Statistics/Datasets/CRAN_', date, sep = ''))
  
  depends <- data.frame()
  suggests <- data.frame()
  imports <- data.frame()
  
  for (package.tarball in package.tarballs)
  {
    package.name <- str_extract(package.tarball, '[^_]+')
    print(paste('Processing', package.name))
    system(paste('tar xfz', package.tarball))
    setwd(package.name)
    if (! file.exists('DESCRIPTION'))
    {
      print(paste(package.name, 'has no DESCRIPTION file.'))
    }
    for (type in c('depends', 'suggests', 'imports'))
    {
      linked.packages <- parse.description(field.names[[type]])
      if (length(linked.packages) > 0)
      {
        for (linked.package in linked.packages)
        {
          assign(type, rbind(get(type), data.frame(Package = package.name, LinkedPackage = linked.package, Date = date)))
        }
      }
    }
    setwd('..')
    system(paste('rm -rf', package.name))
    for (type in c('depends', 'suggests', 'imports'))
    {
      write.csv(get(type),
                file = file.path('/Users/johnmyleswhite/Statistics/cran_analyses/data', paste(type, date, '.csv', sep = '')),
                row.names = FALSE)
    }
  }
}
