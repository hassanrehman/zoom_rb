# frozen_string_literal: true

module Zoom
  class Client
    class OAuth2 < Zoom::Client

      TOKEN_ENDPOINT = "https://api.zoom.us/oauth/token"
      attr_reader :storage

      def initialize(config={})
        config = {
          access_token: nil,
          storage: nil,
        }.merge!(config)
        Zoom::Params.new(config).require(:api_key, :api_secret)
        config.each { |k, v| instance_variable_set("@#{k}", v) }
        @storage = Zoom::Client::TokenStorage.new(@storage)
        self.class.default_timeout(@timeout || 20)
      end

      def clear_tokens
        @access_token = nil
        @storage.clear
      end

      def access_token
        invalidate!
        @access_token
      end

      def invalidate!
        @access_token = @storage.access_token
        if @access_token.nil? or (@access_token && access_token_expired?)
          generate_access_token!
        end
        @access_token
      end

      def access_token_expired?
        return true if @storage.expires_in.zero?  #if never set .. it's expired
        @storage.generated_at + @storage.expires_in < Time.now
      end

      def generate_access_token!
        res = HTTParty.post(
          TOKEN_ENDPOINT,
          query: { grant_type: "client_credentials" },
          basic_auth: { username: @api_key, password: @api_secret }
        )
        auth = OpenStruct.new(JSON.parse(res.body))
        @access_token = auth.access_token
        @storage.set_all({
          expires_in: auth.expires_in, access_token: @access_token,
          generated_at: Time.now
        })
      end
    end
  end
end
