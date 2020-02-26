local typedefs = require "kong.db.schema.typedefs"

return {
    name = "header_translator",
    fields = {
        {
            consumer = typedefs.no_consumer
        },
        {
            config = {
                type = "record",
                fields = {
                    {
                        input_header_name = { 
                            type = "string", 
                            required = true 
                        },
                    },
                    {            
                        output_header_name = { 
                            type = "string", 
                            required = true 
                        },
                    }
                }
            }
        }
    }
}
