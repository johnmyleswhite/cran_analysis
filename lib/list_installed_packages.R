package.info <- installed.packages()[,c(1,3)]
write.csv(package.info,
          file = 'my_installed_packages.csv',
          row.names = FALSE)
