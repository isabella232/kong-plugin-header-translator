local BasePlugin = require "kong.plugins.base_plugin"
local singletons = require "kong.singletons"
local normalize_header = require "kong.plugins.header-translator.normalize_header"
local Logger = require "logger"

local HeaderTranslatorHandler = BasePlugin:extend()

HeaderTranslatorHandler.PRIORITY = 900

local function load_translation(input_header_name, input_header_value, output_header_name)
    return kong.dao.header_translator_dictionary:find({
        input_header_name = input_header_name,
        input_header_value = input_header_value,
        output_header_name = output_header_name
    })
end

local function get_translation(input_header_name, input_header_value, output_header_name)
    local cache_key = kong.dao.header_translator_dictionary:cache_key(input_header_name, input_header_value, output_header_name)

    return singletons.cache:get(cache_key, nil, load_translation, input_header_name, input_header_value, output_header_name)
end

function HeaderTranslatorHandler:new()
    HeaderTranslatorHandler.super.new(self, "header-translator")
end

function HeaderTranslatorHandler:access(conf)
    HeaderTranslatorHandler.super.access(self)

    local input_header_name = normalize_header(conf.input_header_name)
    local input_header_value = kong.request.get_header(input_header_name)

    if not input_header_value then return end

    local output_header_name = normalize_header(conf.output_header_name)
    local translation, err = get_translation(input_header_name, input_header_value, output_header_name)

    if err then
        Logger.getInstance(ngx):logError(err)
    end

    if translation then
        kong.service.request.set_header(conf.output_header_name, translation.output_header_value)
    end
end

return HeaderTranslatorHandler
