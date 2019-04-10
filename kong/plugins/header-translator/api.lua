local crud = require "kong.api.crud_helpers"
local utils = require "kong.tools.utils"

return {
    ["/header-dictionary/:input_header_name/translations/:input_header_value"] = {
        before = function(self)
            self.params.input_header_name = string.lower(self.params.input_header_name)
        end,

        POST = function(self, dao_factory, helpers)
            self.params.output_header_name = string.lower(self.params.output_header_name)
            crud.post(self.params, dao_factory.header_translations)
        end,

        PUT = function(self, dao_factory, helpers)
            local translation, err = dao_factory.header_translations:find({
                input_header_name = self.params.input_header_name,
                input_header_value = self.params.input_header_value
            })

            if err or not translation then
                self.params.output_header_name = string.lower(self.params.output_header_name)
                crud.post(self.params, dao_factory.header_translations)
            else
                self.params.output_header_name = string.lower(self.params.output_header_name)
                crud.put(self.params, dao_factory.header_translations)
            end
        end,

        GET = function(self, dao_factory, helpers)
            local translation, err = dao_factory.header_translations:find({
                input_header_name = self.params.input_header_name,
                input_header_value = self.params.input_header_value
            })

            if err or not translation then
                helpers.responses.send_HTTP_NOT_FOUND('Resource does not exist')
            end

            helpers.responses.send_HTTP_OK(translation)
        end,
    }
}
