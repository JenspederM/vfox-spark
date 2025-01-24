package = "vfox-spark"
version = "dev-1"
source = {
   url = "git+https://github.com/JenspederM/vfox-spark.git"
}
description = {
   detailed = "This is a [vfox plugin](https://vfox.lhan.me/plugins/create/howto.html) template with CI that package and publish the plugin.",
   homepage = "https://github.com/JenspederM/vfox-spark",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      repository = "lib/repository.lua",
      utils = "lib/utils.lua"
   }
}
