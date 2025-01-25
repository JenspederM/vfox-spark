package = "vfox-spark"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/JenspederM/vfox-spark.git"
}
description = {
   detailed = "This is a [vfox plugin](https://vfox.lhan.me/plugins/create/howto.html) template with CI that package and publish the plugin.",
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      download = "lib/download.lua",
      util = "lib/util.lua"
   }
}
