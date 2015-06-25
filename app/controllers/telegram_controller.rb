require "net/http"
require "uri"


class TelegramController < ApplicationController
  def index
    successful = send_message 50886815, params
    render :json => {:ok => successful}
  end
  
  private
  def send_message (chat_id, text = "", web_preview = true, reply_id = nil, reply_markup = nil)
    if chat_id.present?
      uri = URI.parse("https://api.telegram.org/bot#{ENV["TELEGRAM_BOT_API_KEY"]}/sendMessage")
      response = Net::HTTP.post_form(uri,
        {
          :chat_id => chat_id,
          :text => text,
          :disable_web_page_preview => (not web_preview),
          :reply_to_message_id => reply_id,
          :reply_markup => reply_markup
        })
      
      return JSON.parse(response.body)["ok"]
    else
      return false
    end
  end
end
