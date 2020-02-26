return {
    postgres = {
        up = [[
              CREATE TABLE IF NOT EXISTS header_translator_dictionary(
                input_header_name text,
                input_header_value text,
                output_header_name text,
                output_header_value text,
                PRIMARY KEY (input_header_name, input_header_value, output_header_name)
              );
            ]],
    },
    cassandra = {
        up = [[
              CREATE TABLE IF NOT EXISTS header_translator_dictionary(
                input_header_name text,
                input_header_value text,
                output_header_name text,
                output_header_value text,
                PRIMARY KEY (input_header_name, input_header_value, output_header_name)
              );
            ]],
    },
}