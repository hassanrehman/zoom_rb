# frozen_string_literal: true

$:.unshift File.dirname(__FILE__)

require 'zoom/version'
require 'zoom/constants'
require 'zoom/params'
require 'zoom/utils'
require 'zoom/token_storage'
require 'zoom/actions/account'
require 'zoom/actions/group'
require 'zoom/actions/m323_device'
require 'zoom/actions/meeting'
require 'zoom/actions/metrics'
require 'zoom/actions/recording'
require 'zoom/actions/report'
require 'zoom/actions/user'
require 'zoom/actions/webinar'
require 'zoom/actions/im/chat'
require 'zoom/actions/im/group'
require 'zoom/actions/bot/chat'
require 'zoom/client'
require 'zoom/error'

module Zoom
  class << self
    attr_accessor :configuration

    def new
      oauth2  #the new default
    end

    def jwt
      @configuration ||= Configuration.new
      Zoom::Client::JWT.new(
        api_key: @configuration.api_key,
        api_secret: @configuration.api_secret,
        timeout: @configuration.timeout
      )
    end

    def oauth2
      @configuration ||= Configuration.new
      Zoom::Client::OAuth2.new(
        api_key: @configuration.api_key,
        api_secret: @configuration.api_secret,
        timeout: @configuration.timeout,
        storage: @configuration.storage,
      )
    end

    def configure
      @configuration ||= Configuration.new
      yield(@configuration)
    end
  end

  class Configuration
    attr_accessor :api_key, :api_secret, :timeout, :access_token, :refresh_token, :storage

    def initialize
      @api_key = @api_secret = 'xxx'
      @access_token = nil
      @refresh_token = nil
      @storage = nil
      @timeout = 15
    end
  end
end
