local groups = require "kong.plugins.reject-access.groups"
local cjson = require "cjson"
local re_gmatch = ngx.re.gmatch
local request = kong.request
local response = kong.response

local BasePlugin = require "kong.plugins.base_plugin"
local RejectAccess = BasePlugin:extend()

-- Execute after authentication plugins
RejectAccess.PRIORITY = 980

function RejectAccess:new()
  RejectAccess.super.new(self, "reject-access")
end

local function tableHasValue (table, val)
    for index, value in ipairs(table) do
        if value == val then
            return true
        end
    end

    return false
end

local function check_ba(header_name, conf)
  local authorization_header = kong.request.get_header(header_name)

  if authorization_header then
    local iterator, iter_err = re_gmatch(authorization_header, "\\s*[Bb]asic\\s*(.+)")
    if not iterator then
      kong.log.err(iter_err)
      return
    end

    local m, err = iterator()
    if err then
      kong.log.err(err)
      return
    end

    if m and m[1] then
      return true
    end
  end
end

-- Executed for every request upon it's reception from a client and before it is being proxied to the upstream service.
function RejectAccess:access(conf)
  RejectAccess.super.access(self)

  if check_ba('authorization', conf) then
    local consumer = kong.client.get_consumer()
    if consumer then
      -- Block user for configured group if authenticated with Basic-Auth
      if tableHasValue(groups.get_consumer_groups(consumer.id), conf.group) then
        response.exit(401, '{"message":"Invalid authentication credentials"}')
      end
    end
  end

end

return RejectAccess
