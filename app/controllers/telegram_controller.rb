require "net/http"
require "uri"
include ActionView::Helpers::TextHelper


class TelegramController < ApplicationController
  protect_from_forgery with: :null_session
  
  def index
    message = telegram_params[:message]
    if message.present?
      # Prepare response
      response_msg = parse_command(message[:text], message[:from][:id])
      # Determine id of reply
      reply_id = response_msg[:reply] ? message[:message_id] : nil
      # Send message
      successful = send_message message[:chat][:id], response_msg[:text], true, reply_id
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
  
  def parse_command (text, sender)
    to_return = {:response => false}
    
    params = text[/^\/[\w]+ (.+)$/, 1]
    params_arr = text.scan(/ ([^ ]+)/)
    case text[/^\/([\w]+)/, 1]
    when "echo"
      to_return[:text] = params
    when "articles"
      case params_arr[0].first
      when "count"
        amount = pluralize Article.count, 'artikkeli', 'artikkelia'
        to_return[:text] = "Sivustolla on yhteensä #{amount}."
      when "list"
        toReturn = "Käytä /article read [luku] lukeaksesi artikkelin.\n\n"
        Article.all.each do |article|
          toReturn <<= "#{article.id}: #{article.title}\n"
        end
        to_return[:text] = toReturn
      when "read"
        id = params_arr[1].first.to_i
        to_return[:text] = Article.exists?(id) ?
          "Voit lukea artikkelin osoitteessa #{article_url(id)}."
          : "Kyseinen artikkeli ei ole olemassa!"
        to_return[:response] = true
      end
    when "users"
      case params_arr[0].first
      when "count"
        amount = pluralize User.count, 'käyttäjä', 'käyttäjää'
        to_return[:text] = "Sivustolla on yhteensä #{amount}."
      end
    end
    
    to_return
  end
  
  
  def telegram_params
    params.require(:telegram)
      .permit(
        :update_id,
        message: [
          :message_id,
          :text,
          :chat => [:id],
          :from => [:id]
        ]
      )
  end
end
