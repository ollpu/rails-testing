require "net/http"
require "uri"
require "securerandom"
include ActionView::Helpers::TextHelper


class TelegramController < ApplicationController
  protect_from_forgery with: :null_session
  
  def setup
    unless current_user
      not_privileged
    end
  end
  
  def connect
    if current_user
      @key = SecureRandom.urlsafe_base64(32)
      Rails.cache.write("telegram_link:#{@key}", current_user.email, expires_in: 1.hours)
    else
      not_privileged
    end
  end
  
  def disconnect
    if current_user
      current_user.telegram_user = nil
      current_user.save
      redirect_to telegram_setup_path, :notice => "Yhteys purettiin onnistuneesti."
    else
      not_privileged
    end
  end
  
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
    when "start"
      key = Rails.cache.read("telegram_link:#{params_arr[0].first}")
      Rails.cache.delete("telegram_link:#{params_arr[0].first}")
      if key
        user = User.find_by email: key
        if user and not user.telegram_user.present?
          user.telegram_user = sender
          user.save
          to_return[:text] = "Tämä Telegram-tili on nyt yhdistetty tiliin #{user.email}!"
        end
      end
    when "echo"
      to_return[:text] = params
    when "articles"
      if telegram_rel_user(sender).present?
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
      else
        to_return[:text] = "Ei oikeutta. // Not authorized."
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
  
  def telegram_rel_user(sender)
    User.find_by telegram_user: sender
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
  
  def not_privileged
    redirect_to root_url, :notice => "Sinulla ei ole oikeutta tehdä tätä."
  end
end
