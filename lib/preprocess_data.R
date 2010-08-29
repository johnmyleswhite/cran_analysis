# Drop version info, which doesn't help us.
depends$LinkedPackage <- sub('\\s*\\(.*', '', as.character(depends$LinkedPackage))

suggests$LinkedPackage <- sub('\\s*\\(.*', '', as.character(suggests$LinkedPackage))

imports$LinkedPackage <- sub('\\s*\\(.*', '', as.character(imports$LinkedPackage))
