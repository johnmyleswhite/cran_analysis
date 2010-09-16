library('ProjectTemplate')
load.project()

persons <- ddply(subset(maintainers, Date == '8282010'), 'Maintainer', nrow)
names(persons) <- c('Person', 'PackagesMaintaining')
write.table(persons,
            file = file.path('data', 'persons.csv'),
            row.names = FALSE,
            sep = ',')
