local normalizer = require "kong.plugins.header-translator.normalizer"

describe("Normalizer", function()
    it("should lowercase the given input", function()
        assert.are.equal("x_suite_customer_id", normalizer("X_Suite_Customer_Id"))
    end)

    it("should change dash to underscore in the given input", function()
        assert.are.equal("x_suite_customer_id", normalizer("X-Suite-Customer-Id"))
    end)
end)
