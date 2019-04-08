local helpers = require "spec.helpers"
local kong_client = require "kong_client.spec.test_helpers"

describe("HeaderTranslator", function()

    local kong_sdk, send_request, send_admin_request

    setup(function()
        helpers.start_kong({ custom_plugins = "header-translator" })

        kong_sdk = kong_client.create_kong_client()
        send_request = kong_client.create_request_sender(helpers.proxy_client())
        send_admin_request = kong_client.create_request_sender(helpers.admin_client())
    end)

    teardown(function()
        helpers.stop_kong(nil)
    end)

    before_each(function()
        helpers.db:truncate()
    end)

    context("Config", function()
        local service

        before_each(function()
            service = kong_sdk.services:create({
                name = "test-service",
                url = "http://mockbin:8080/request"
            })
        end)

        it("should respond proper error message when required config values not provided", function()

            local _, response = pcall(function()
                kong_sdk.plugins:create({
                    service_id = service.id,
                    name = "header-translator",
                    config = {}
                })
            end)

            assert.are.equal("input_header is required", response.body["config.input_header"])
            assert.are.equal("output_header is required", response.body["config.output_header"])
        end)
    end)

end)
