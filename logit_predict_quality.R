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

logit.fit <- glm(Installed ~ DependencyCount + SuggestionCount + ImportCount + ViewsIncluding + CorePackage + RecommendedPackage,
                 data = design.matrix,
                 family = binomial(link = 'logit'))
summary(logit.fit)

invlogit <- function(z) {1 / (1 + exp(-z))}
packages <- transform(packages, QualityMetric = invlogit(predict(logit.fit, newdata = packages)))
tail(packages[order(packages$QualityMetric),c('Package', 'QualityMetric')], n = 50)

write.csv(packages[order(packages$QualityMetric),c('Package', 'QualityMetric')],
          file = file.path('reports', 'logit_predictions.csv'),
          row.names = FALSE)

# Make some plots to see how the predictors work on their own.
pdf('graphs/logit_dependency.pdf')
ggplot(design.matrix, aes(x = DependencyCount, y = Installed)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/logit_suggestion.pdf')
ggplot(design.matrix, aes(x = SuggestionCount, y = Installed)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/logit_importing.pdf')
ggplot(design.matrix, aes(x = ImportCount, y = Installed)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

pdf('graphs/logit_inclusion.pdf')
ggplot(design.matrix, aes(x = ViewsIncluding, y = Installed)) +
  geom_jitter() +
  geom_smooth(method = 'lm') +
  ylim(c(0, 1))
dev.off()

