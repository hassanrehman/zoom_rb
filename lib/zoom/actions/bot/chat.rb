# frozen_string_literal: true

module Zoom
  module Actions
    module Bot
      module Chat
        # Send bot messages: https://marketplace.zoom.us/docs/api-reference/zoom-api/chatbot-messages/sendchatbot
        def bot_chat_sent(*args)
          options = Utils.extract_options!(args)
          Zoom::Params.new(options).require(:robot_jid, :to_jid, :account_id, :content)
          Utils.parse_response self.class.post('/im/chat/messages', body: options.to_json, headers: request_headers)
        end
      end
    end
  end
end
