library('ProjectTemplate')
load.project()

setwd('/Users/johnmyleswhite/Statistics/Datasets/CRAN_08282010')

package.tarballs <- dir('.')

packages <- c()

for (package.tarball in package.tarballs)
{
  package.name <- str_extract(package.tarball, '[^_]+')
  packages <- c(packages, package.name)
}

write.csv(data.frame(Package = packages),
          file = '/Users/johnmyleswhite/Statistics/cran_analyses/data/packages.csv',
          row.names = FALSE)
