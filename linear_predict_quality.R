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

core <- transform(core, CorePackage = rep(1, nrow(core)))
packages <- merge(packages,
                  core,
                  by = 'Package',
                  all.x = TRUE)
packages$CorePackage <- ifelse(is.na(packages$CorePackage), 0, 1)

recommended <- transform(recommended, RecommendedPackage = rep(1, nrow(recommended)))
packages <- merge(packages,
                  recommended,
                  by = 'Package',
                  all.x = TRUE)
packages$RecommendedPackage <- ifelse(is.na(packages$RecommendedPackage), 0, 1)

# Fit a linear model only to packages that were installed by "choice"
lm.fit <- lm(InstallProbability ~ DependencyCount + SuggestionCount + ImportCount + ViewsIncluding + CorePackage + RecommendedPackage,
             data = packages)
summary(lm.fit)
packages <- transform(packages, LinearQualityMetric = predict(lm.fit, newdata = packages))
tail(packages[order(packages$LinearQualityMetric),c('Package', 'LinearQualityMetric')], n = 50)
packages <- transform(packages, Error = abs(LinearQualityMetric - InstallProbability))

# Make some plots to see how the predictors work on their own.
pdf('graphs/linear_dependency.pdf')
ggplot(packages, aes(x = log(1 + DependencyCount), y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/linear_suggestion.pdf')
ggplot(packages, aes(x = log(1 + SuggestionCount), y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/linear_importing.pdf')
ggplot(packages, aes(x = log(1 + ImportCount), y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/linear_inclusion.pdf')
ggplot(packages, aes(x = log(1 + ViewsIncluding), y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/linear_quality.pdf')
ggplot(packages, aes(x = LinearQualityMetric, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

epsilon <- 0.3
pdf('graphs/linear_errors.pdf')
ggplot(subset(packages, Error > epsilon & RecommendedPackage == 0),
       aes(x = LinearQualityMetric + runif(nrow(subset(packages, Error > epsilon & RecommendedPackage == 0)), 0, 0.4),
           y = InstallProbability + runif(nrow(subset(packages, Error > epsilon & RecommendedPackage == 0)), -0.4, 0.4))) +
  geom_text(aes(label = Package)) +
  xlim(c(0, 1)) +
  ylim(c(0, 1)) +
  opts(title = 'Where Our Linear Metric Fails') +
  xlab('Linear Quality Metric') +
  ylab('P(Package is Installed)')
dev.off()

cat(paste('Mean Absolute Error:', with(packages, mean(Error)), '\n'))
