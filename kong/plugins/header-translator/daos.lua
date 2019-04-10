local singletons = require "kong.singletons"
local utils = require "kong.tools.utils"

local SCHEMA = {
    primary_key = { "input_header_name", "input_header_value" },
    table = "header_translator_dictionary",
    cache_key = { "input_header_name", "input_header_value" },
    fields = {
        input_header_name = { type = "string", required = true },
        input_header_value = { type = "string", required = true },
        output_header_name = { type = "string", required = true },
        output_header_value = { type = "string", required = true }
    }
}

return {
    header_translations = SCHEMA
}
