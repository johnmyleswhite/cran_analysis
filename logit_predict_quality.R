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
packages$DependencyCount <- ifelse(is.na(packages$DependencyCount), 0, packages$DependencyCount)

packages <- merge(packages,
                  suggestions,
                  by = 'Package',
                  all.x = TRUE)
packages$SuggestionCount <- ifelse(is.na(packages$SuggestionCount), 0, packages$SuggestionCount)

packages <- merge(packages,
                  importings,
                  by = 'Package',
                  all.x = TRUE)
packages$ImportCount <- ifelse(is.na(packages$ImportCount), 0, packages$ImportCount)

packages <- merge(packages,
                  inclusions,
                  by = 'Package',
                  all.x = TRUE)
packages$ViewsIncluding <- ifelse(is.na(packages$ViewsIncluding), 0, packages$ViewsIncluding)

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

installations <- transform(installations, Installed = rep(1, nrow(installations)))

design.matrix <- expand.grid(packages$Package, as.character(unique(installations$User)))
names(design.matrix) <- c('Package', 'User')

design.matrix <- merge(design.matrix,
                       packages,
                       by = 'Package',
                       all = TRUE)

design.matrix <- merge(design.matrix,
                       installations,
                       by = c('User', 'Package'),
                       all = TRUE)
design.matrix$Installed <- ifelse(is.na(design.matrix$Installed), 0, 1)

packages <- transform(packages, LogDependencyCount = log(1 + DependencyCount))
packages <- transform(packages, LogSuggestionCount = log(1 + SuggestionCount))
packages <- transform(packages, LogImportCount = log(1 + ImportCount))
packages <- transform(packages, LogViewsIncluding = log(1 + ViewsIncluding))

design.matrix <- transform(design.matrix, LogDependencyCount = log(1 + DependencyCount))
design.matrix <- transform(design.matrix, LogSuggestionCount = log(1 + SuggestionCount))
design.matrix <- transform(design.matrix, LogImportCount = log(1 + ImportCount))
design.matrix <- transform(design.matrix, LogViewsIncluding = log(1 + ViewsIncluding))

logit.fit <- glm(Installed ~ LogDependencyCount + LogSuggestionCount + LogImportCount + LogViewsIncluding + CorePackage + RecommendedPackage,
                 data = design.matrix,
                 family = binomial(link = 'logit'))
summary(logit.fit)

invlogit <- function(z) {1 / (1 + exp(-z))}
packages <- transform(packages, LogisticQualityMetric = invlogit(predict(logit.fit, newdata = packages)))
tail(packages[order(packages$LogisticQualityMetric),c('Package', 'LogisticQualityMetric')], n = 50)
packages <- transform(packages, AbsoluteError = abs(LogisticQualityMetric - InstallProbability))
tail(packages[order(packages$AbsoluteError),c('Package', 'AbsoluteError')], n = 50)

write.csv(packages[order(packages$LogisticQualityMetric),c('Package', 'LogisticQualityMetric')],
          file = file.path('reports', 'logit_predictions.csv'),
          row.names = FALSE)

# Make some plots to see how the predictors work on their own.
pdf('graphs/logit_dependency.pdf')
ggplot(design.matrix, aes(x = log(1 + DependencyCount), y = Installed)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/logit_suggestion.pdf')
ggplot(design.matrix, aes(x = log(1 + SuggestionCount), y = Installed)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/logit_importing.pdf')
ggplot(design.matrix, aes(x = log(1 + ImportCount), y = Installed)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/logit_inclusion.pdf')
ggplot(design.matrix, aes(x = log(1 + ViewsIncluding), y = Installed)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/logit_quality.pdf')
ggplot(packages, aes(x = LogisticQualityMetric, y = InstallProbability)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

epsilon <- 0.33
pdf('graphs/logit_errors.pdf')
ggplot(subset(packages, AbsoluteError > epsilon & RecommendedPackage == 0),
       aes(x = LogisticQualityMetric,
           y = InstallProbability)) +
  geom_text(aes(label = Package, color = AbsoluteError, size = AbsoluteError)) +
  xlim(c(0, 1)) +
  ylim(c(0, 1)) +
  opts(title = 'Where Our Package Metric Fails') +
  xlab('Predicted Probability') +
  ylab('Empirical Probability')
dev.off()

cat(paste('Mean Absolute Error:', with(packages, mean(AbsoluteError)), '\n'))
cat(paste('Max Absolute Error:', with(packages, max(AbsoluteError)), '\n'))
cat(paste('Min Absolute Error:', with(packages, min(AbsoluteError)), '\n'))
