require "net/http"
require "uri"


class TelegramController < ApplicationController
  protect_from_forgery with: :null_session
  
  def index
    message = telegram_params[:message]
    if message.present?
      successful = send_message message[:chat][:id], parse_command(message[:text])
      # successful = message
      # successful = { :id => message[:chat][:id], :text => parse_command(message[:text]) }
    else successful = false end
      
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
  
  def parse_command (text)
    params = text[/^\/[\w]+ (.+)$/, 1]
    case text[/^\/([\w]+)/, 1]
    when "echo"
      return params
    end
  end
  
  
  def telegram_params
    params.require(:telegram)
      .permit(
        :update_id,
        message: [
          :text,
          :chat => [:id]
        ]
      )
  end
end
