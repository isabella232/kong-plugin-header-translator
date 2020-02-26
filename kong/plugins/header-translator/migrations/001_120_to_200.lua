return {
    postgres = {
        up = [[
            DO $$
            BEGIN
            ALTER TABLE IF EXISTS ONLY "header_translator_dictionary" ADD "cache_key" TEXT UNIQUE;
            EXCEPTION WHEN DUPLICATE_COLUMN THEN
            -- Do nothing, accept existing state
            END;
            $$;
        ]]
    },
    cassandra = {
        up = [[
            ALTER TABLE header_translator_dictionary ADD cache_key text;
            CREATE INDEX IF NOT EXISTS ON header_translator_dictionary (cache_key);
        ]]
    }
}