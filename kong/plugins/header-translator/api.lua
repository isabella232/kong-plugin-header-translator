local crud = require "kong.api.crud_helpers"
local utils = require "kong.tools.utils"

return {
    ["/header-dictionary/:input_header_name/translations/:input_header_value"] = {
        POST = function(self, dao_factory, helpers)
            crud.post(self.params, dao_factory.header_translations)
        end,

        GET = function(self, dao_factory, helpers)
            local translation, err = dao_factory.header_translations:find({
                input_header_name = self.params.input_header_name,
                input_header_value = self.params.input_header_value
            })

            if err then
                helpers.responses.send_HTTP_NOT_FOUND('Resource does not exist')
            end

            helpers.responses.send_HTTP_OK(translation)
        end,
    }
}
