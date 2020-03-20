package = "kong-plugin-reject-access"
version = "1.0-0"

source = {
  url = "git://github.com/nextpertise/kong-plugin-reject-access",
  tag = "v1.0"
}

description = {
  summary = "Reject access to specified group of consumers with Basic-Auth enabled",
  license = "MIT"
}

dependencies = {
  "lua ~> 5.1"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.reject-access.handler"] = "src/handler.lua",
    ["kong.plugins.reject-access.groups"] = "src/groups.lua",
    ["kong.plugins.reject-access.schema"] = "src/schema.lua"
  }
}
