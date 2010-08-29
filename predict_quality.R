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
packages <- transform(packages, Error = abs(QualityMetric - InstallProbability))

# Make some plots to see how the predictors work on their own.
pdf('graphs/dependency.pdf')
ggplot(packages, aes(x = DependencyCount, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/suggestion.pdf')
ggplot(packages, aes(x = SuggestionCount, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/importing.pdf')
ggplot(packages, aes(x = ImportCount, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/inclusion.pdf')
ggplot(packages, aes(x = ViewsIncluding, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/quality.pdf')
ggplot(packages, aes(x = QualityMetric, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

epsilon <- 0.3
pdf('graphs/errors.pdf')
ggplot(subset(packages, Error > epsilon),
       aes(x = QualityMetric + runif(nrow(subset(packages, Error > epsilon)), 0, 0.4),
           y = InstallProbability + runif(nrow(subset(packages, Error > epsilon)), -0.2, 0.2))) +
  geom_text(aes(label = Package)) +
  xlim(c(0, 2)) +
  ylim(c(0, 1)) +
  opts(title = 'Where Our Metric Fails') +
  xlab('Quality Metric') +
  ylab('P(Package is Installed)')
dev.off()
