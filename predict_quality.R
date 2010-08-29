library('ProjectTemplate')
load.project()

# Pull our accumulated metadata into the packages data.frame.
dependencies <- ddply(subset(depends, Date == '2010-08-28'), 'LinkedPackage', nrow)
names(dependencies) <- c('Package', 'DependencyCount')
suggestions <- ddply(subset(suggests, Date == '2010-08-28'), 'LinkedPackage', nrow)
names(suggestions) <- c('Package', 'SuggestionCount')
importings <- ddply(subset(imports, Date == '2010-08-28'), 'LinkedPackage', nrow)
names(importings) <- c('Package', 'ImportCount')
inclusions <- ddply(subset(views, Date == '2010-08-28'), 'LinkedPackage', nrow)
names(inclusions) <- c('Package', 'ViewsIncluding')

packages <- merge(packages,
                  dependencies,
                  by = 'Package',
                  all.x = TRUE)
packages$DependencyCount <- scale(ifelse(is.na(packages$DependencyCount), 0, packages$DependencyCount))
packages <- merge(packages,
                  suggestions,
                  by = 'Package',
                  all.x = TRUE)
packages$SuggestionCount <- scale(ifelse(is.na(packages$SuggestionCount), 0, packages$SuggestionCount))
packages <- merge(packages,
                  importings,
                  by = 'Package',
                  all.x = TRUE)
packages$ImportCount <- scale(ifelse(is.na(packages$ImportCount), 0, packages$ImportCount))
packages <- merge(packages,
                  inclusions,
                  by = 'Package',
                  all.x = TRUE)
packages$ViewsIncluding <- scale(ifelse(is.na(packages$ViewsIncluding), 0, packages$ViewsIncluding))

# Grab our installation data for training our prediction algorithm.
user.count <- with(installations, length(unique(User)))

packages <- transform(packages,
                      InstallProbability = sapply(packages$Package,
                                                  function (p)
                                                  {
                                                    nrow(subset(installations,
                                                                Package == as.character(p))) / user.count
                                                  }))

# Fit a linear model only to packages that were installed by "choice"
lm.fit <- lm(InstallProbability ~ DependencyCount + SuggestionCount + ImportCount + ViewsIncluding,
             data = subset(packages, !(Package %in% recommended$Package) & !(Package %in% recommended$Package)))
summary(lm.fit)
packages <- transform(packages, QualityMetric = predict(lm.fit, newdata = packages))
tail(packages[order(packages$QualityMetric),c('Package', 'QualityMetric')], n = 50)

# Make some plots to see how the predictors work on their own.
ggplot(packages, aes(x = DependencyCount, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
ggplot(packages, aes(x = SuggestionCount, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
ggplot(packages, aes(x = ImportCount, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
ggplot(packages, aes(x = ViewsIncluding, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
