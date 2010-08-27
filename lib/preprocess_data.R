versionless.depends <- depends
versionless.depends$LinkedPackage <- sub('\\s*\\(.*', '', as.character(versionless.depends$LinkedPackage))

versionless.suggests <- suggests
versionless.suggests$LinkedPackage <- sub('\\s*\\(.*', '', as.character(versionless.suggests$LinkedPackage))

versionless.imports <- imports
versionless.imports$LinkedPackage <- sub('\\s*\\(.*', '', as.character(versionless.imports$LinkedPackage))
