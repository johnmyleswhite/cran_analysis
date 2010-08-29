library('ProjectTemplate')
load.project()

dates <- c('02082009', '11192009', '08282010')

for (date in dates)
{
  setwd(paste('/Users/johnmyleswhite/Statistics/Datasets/CRAN_', date, sep = ''))
  
  package.tarballs <- dir('.')
  
  package.authors <- data.frame()
  
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
    authors <- parse.description('Author')
    if (length(authors) > 0)
    {
      for (author in authors)
      {
        assign('package.authors',
               rbind(package.authors,
                     data.frame(Package = package.name,
                                Author = author,
                                Date = date)))
      }
    }
    setwd('..')
    system(paste('rm -rf', package.name))
    write.csv(package.authors,
              file = file.path('/Users/johnmyleswhite/Statistics/cran_analyses/data', paste('authors', date, '.csv', sep = '')),
              row.names = FALSE)
  }
}
