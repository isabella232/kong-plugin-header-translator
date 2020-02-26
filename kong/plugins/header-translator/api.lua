local normalize_header = require "kong.plugins.header-translator.normalize_header"
local header_translator_dictionary_schema = kong.db.header_translator_dictionary.schema

local function should_be_updated(translation, params)
    return not (translation.input_header_name == params.input_header_name and
           translation.input_header_value == params.input_header_value and
           translation.output_header_name == params.output_header_name and
           translation.output_header_value == params.output_header_value)
end

local function insert(db, header_params)
    local row, err, err_t = db.header_translator_dictionary:insert(header_params)
    if err then
        return kong.response.exit(500, {
            message = "Failed to insert resource",
            details = err_t
        })
    end
    kong.response.exit(201, row) 
end

local function get_cache_key(header_params)
    return {
        input_header_name = header_params.input_header_name,
        input_header_value = header_params.input_header_value,
        output_header_name = header_params.output_header_name
    }
end

return {
    ["/header-dictionary/:input_header_name/:input_header_value/translations/:output_header_name"] = {
        schema = header_translator_dictionary_schema,
        methods = {
            before = function(self)
                self.params.input_header_name = normalize_header(self.params.input_header_name)
                self.params.output_header_name = normalize_header(self.params.output_header_name)
            end,

            POST = function(self, db)
                insert(db, self.params)
            end,

            PUT = function(self, db, helpers) 
                local cache_key = get_cache_key(self.params)
                local translation = db.header_translator_dictionary:select_by_cache_key(cache_key)

                if not translation then
                    insert(db, self.params)
                else
                    if should_be_updated(translation, self.params) then
                        local row, err, err_t = db.header_translator_dictionary:update(cache_key, self.params)
                        if err then
                            return kong.response.exit(500, {
                                message = "Failed to update resource",
                                details = err_t
                            })
                        end
                        kong.response.exit(200, row)
                    else
                        kong.response.exit(200, translation)
                    end
                end
            end,

            GET = function(self, db, helpers)
                local translation, err, err_t = db.header_translator_dictionary:select_by_cache_key(get_cache_key(self.params))

                if err or not translation then
                    return kong.response.exit(404, {
                        message = 'Resource does not exist'
                    })
                end

                kong.response.exit(200, translation)
            end,

            DELETE = function(self, db)
                db.header_translator_dictionary:delete(get_cache_key(self.params))
                kong.response.exit(204)
            end,
        }
    }
}
