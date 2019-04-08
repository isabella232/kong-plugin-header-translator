local BasePlugin = require "kong.plugins.base_plugin"

local HeaderTranslatorHandler = BasePlugin:extend()

HeaderTranslatorHandler.PRIORITY = 2000

function HeaderTranslatorHandler:new()
    HeaderTranslatorHandler.super.new(self, "header-translator")
end

function HeaderTranslatorHandler:access(conf)
    HeaderTranslatorHandler.super.access(self)

end

return HeaderTranslatorHandler
