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

    context("Admin API", function()
        local service

        before_each(function()
            service = kong_sdk.services:create({
                name = "test-service",
                url = "http://mockbin:8080/request"
            })
        end)

        context("Plugin configuration", function()
            it("should respond proper error message when required config values not provided", function()
                local _, response = pcall(function()
                    kong_sdk.plugins:create({
                        service_id = service.id,
                        name = "header-translator",
                        config = {}
                    })
                end)

                assert.are.equal("input_header_name is required", response.body["config.input_header_name"])
                assert.are.equal("output_header_name is required", response.body["config.output_header_name"])
            end)
        end)

        context("manipulating the dictionary", function()
            before_each(function()
                kong_sdk.plugins:create({
                    service_id = service.id,
                    name = "header-translator",
                    config = {
                        input_header_name = "X-Emarsys-Customer-Id",
                        output_header_name = "X-Emarsys-Environment-Name"
                    }
                })
            end)

            it("should save dictionary entries", function()
                local creation_response = send_admin_request({
                    method = "POST",
                    path = "/header-dictionary/x-emarsys-customer-id/translations/112233",
                    body = {
                        output_header_name = "x-emarsys-environment-name",
                        output_header_value = "suitex.emar.sys"
                    }
                })

                assert.are.equal(201, creation_response.status)
                assert.are.same({
                    input_header_name = "x-emarsys-customer-id",
                    input_header_value = "112233",
                    output_header_name = "x-emarsys-environment-name",
                    output_header_value = "suitex.emar.sys"
                }, creation_response.body)

                local retrieval_response = send_admin_request({
                    method = "GET",
                    path = "/header-dictionary/x-emarsys-customer-id/translations/112233"
                })

                assert.are.equal(200, retrieval_response.status)
                assert.are.same({
                    input_header_name = "x-emarsys-customer-id",
                    input_header_value = "112233",
                    output_header_name = "x-emarsys-environment-name",
                    output_header_value = "suitex.emar.sys"
                }, retrieval_response.body)
            end)

            it("should save header names in lower case", function()
                local creation_response = send_admin_request({
                    method = "POST",
                    path = "/header-dictionary/X-EmarSys-Customer-ID/translations/112233",
                    body = {
                        output_header_name = "X-Emarsys-Environment-Name",
                        output_header_value = "suitex.emar.sys"
                    }
                })

                assert.are.equal(201, creation_response.status)
                assert.are.same({
                    input_header_name = "x-emarsys-customer-id",
                    input_header_value = "112233",
                    output_header_name = "x-emarsys-environment-name",
                    output_header_value = "suitex.emar.sys"
                }, creation_response.body)

                local retrieval_response = send_admin_request({
                    method = "GET",
                    path = "/header-dictionary/x-emarsys-customer-id/translations/112233"
                })

                assert.are.equal(200, retrieval_response.status)
                assert.are.same({
                    input_header_name = "x-emarsys-customer-id",
                    input_header_value = "112233",
                    output_header_name = "x-emarsys-environment-name",
                    output_header_value = "suitex.emar.sys"
                }, retrieval_response.body)
            end)
        end)
    end)

end)
