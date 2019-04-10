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

            context("POST /header-dictionary/:input_header_name/translations/:input_header_value", function()
                it("should save dictionary entries", function()
                    local creation_response = send_admin_request({
                        method = "POST",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name",
                        body = {
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
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name",
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
                        path = "/header-dictionary/X-EmarSys-Customer-ID/112233/translations/X-Emarsys-Environment-Name",
                        body = {
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
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name",
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

            context("PUT /header-dictionary/:input_header_name/:input_header_value/translations/:output_header_name", function()
                it("should create a new entry if it didn't exist before", function()
                    local creation_response = send_admin_request({
                        method = "PUT",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name",
                        body = {
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
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name"
                    })

                    assert.are.equal(200, retrieval_response.status)
                    assert.are.same({
                        input_header_name = "x-emarsys-customer-id",
                        input_header_value = "112233",
                        output_header_name = "x-emarsys-environment-name",
                        output_header_value = "suitex.emar.sys"
                    }, retrieval_response.body)
                end)

                it("should override the entry if it was there before", function()
                    local creation_response = send_admin_request({
                        method = "POST",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name",
                        body = {
                            output_header_value = "suitex.emar.sys"
                        }
                    })

                    assert.are.equal(201, creation_response.status)

                    local override_response = send_admin_request({
                        method = "PUT",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name",
                        body = {
                            output_header_value = "suitey.emar.sys"
                        }
                    })

                    assert.are.equal(200, override_response.status)
                    assert.are.same({
                        input_header_name = "x-emarsys-customer-id",
                        input_header_value = "112233",
                        output_header_name = "x-emarsys-environment-name",
                        output_header_value = "suitey.emar.sys"
                    }, override_response.body)

                    local retrieval_response = send_admin_request({
                        method = "GET",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name"
                    })

                    assert.are.equal(200, retrieval_response.status)
                    assert.are.same({
                        input_header_name = "x-emarsys-customer-id",
                        input_header_value = "112233",
                        output_header_name = "x-emarsys-environment-name",
                        output_header_value = "suitey.emar.sys"
                    }, retrieval_response.body)
                end)

                it("should create new entry when output header name is different", function()
                    local creation_response = send_admin_request({
                        method = "POST",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name",
                        body = {
                            output_header_value = "suitex.emar.sys"
                        }
                    })

                    assert.are.equal(201, creation_response.status)

                    local new_entry_response = send_admin_request({
                        method = "PUT",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-external-identifier",
                        body = {
                            output_header_value = "malacpersely"
                        }
                    })

                    assert.are.equal(201, new_entry_response.status)
                    assert.are.same({
                        input_header_name = "x-emarsys-customer-id",
                        input_header_value = "112233",
                        output_header_name = "x-emarsys-external-identifier",
                        output_header_value = "malacpersely"
                    }, new_entry_response.body)

                    local retrieval_response = send_admin_request({
                        method = "GET",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name"
                    })

                    assert.are.equal(200, retrieval_response.status)
                    assert.are.same({
                        input_header_name = "x-emarsys-customer-id",
                        input_header_value = "112233",
                        output_header_name = "x-emarsys-environment-name",
                        output_header_value = "suitex.emar.sys"
                    }, retrieval_response.body)

                    local other_retrieval_response = send_admin_request({
                        method = "GET",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-external-identifier"
                    })

                    assert.are.equal(200, other_retrieval_response.status)
                    assert.are.same({
                        input_header_name = "x-emarsys-customer-id",
                        input_header_value = "112233",
                        output_header_name = "x-emarsys-external-identifier",
                        output_header_value = "malacpersely"
                    }, other_retrieval_response.body)
                end)

                it("should not create or update entry when no change detected", function()
                    local creation_response = send_admin_request({
                        method = "POST",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name",
                        body = {
                            output_header_value = "suitex.emar.sys"
                        }
                    })

                    assert.are.equal(201, creation_response.status)

                    local same_content_response = send_admin_request({
                        method = "PUT",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name",
                        body = {
                            output_header_value = "suitex.emar.sys"
                        }
                    })

                    assert.are.equal(200, same_content_response.status)
                    assert.are.same({
                        input_header_name = "x-emarsys-customer-id",
                        input_header_value = "112233",
                        output_header_name = "x-emarsys-environment-name",
                        output_header_value = "suitex.emar.sys"
                    }, same_content_response.body)

                    local retrieval_response = send_admin_request({
                        method = "GET",
                        path = "/header-dictionary/x-emarsys-customer-id/112233/translations/x-emarsys-environment-name"
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

end)
