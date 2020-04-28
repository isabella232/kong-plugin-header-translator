return {
    postgres = {
        up = [[
            DO $$
            BEGIN
            UPDATE header_translator_dictionary SET cache_key = CONCAT('header_translator_dictionary', ':', input_header_name, ':', input_header_value, ':', output_header_name, '::' ) WHERE cache_key is null;
            END;
            $$;
        ]]
    },
    cassandra = {
        up = [[
            UPDATE header_translator_dictionary SET cache_key = CONCAT('header_translator_dictionary', ':', input_header_name, ':', input_header_value, ':', output_header_name, '::' ) WHERE cache_key is null;
        ]]
    }
}