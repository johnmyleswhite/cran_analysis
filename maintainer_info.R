library('ProjectTemplate')
load.project()

dates <- c('02082009', '11192009', '08282010')

for (date in dates)
{
  setwd(paste('/Users/johnmyleswhite/Statistics/Datasets/CRAN_', date, sep = ''))
  
  package.tarballs <- dir('.')
  
  package.maintainers <- data.frame()
  
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
    maintainers <- parse.description('Maintainer')
    if (length(maintainers) > 0)
    {
      for (maintainer in maintainers)
      {
        assign('package.maintainers',
               rbind(package.maintainers,
                     data.frame(Package = package.name,
                                Maintainer = maintainer,
                                Date = date)))
      }
    }
    setwd('..')
    system(paste('rm -rf', package.name))
    write.csv(package.maintainers,
              file = file.path('/Users/johnmyleswhite/Statistics/cran_analyses/data', paste('maintainers', date, '.csv', sep = '')),
              row.names = FALSE)
  }
}
