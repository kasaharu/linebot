require 'line/bot'
require 'net/http'
require 'uri'

class LinebotController < ApplicationController
  def callback
    message = {
      type: 'text',
      text: 'Hello, This is LINE bot'
    }

    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    puts events = client.parse_events_from(request.body.read)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          case event['message']['text']
          when '天気'
            message['text'] = fetch_weather
          when 'アニメ一覧'
            target_season = Annict.detect_target_season
            message['text'] = fetch_anime(target_season)
          when 'こんにちは'
            userId =  event['source']['userId']
            resProfile = client.get_profile(userId)
            case resProfile
            when Net::HTTPSuccess then
              contact = JSON.parse(resProfile.body)
              p contact['displayName']
              p contact['pictureUrl']
              p contact['statusMessage']
              message['text'] = "#{contact['displayName']}さん こんにちは♪"
            else
              p "#{resProfile.code} #{resProfile.body}"
            end
          else
            return
          end
          response = client.reply_message(event['replyToken'], message)
          p response.body
        end
      end
    end
  end

  def greet

  end

  def fetch_weather
    response = Weather.fetch
    if response.code == '200'
      return Weather.parse_msg(response.body)
    else
      return Weather.error_msg(response)
    end
  end

  def fetch_anime(target_season)
    response = Annict.fetch(target_season)
    if response.code == '200'
      return Annict.parse_msg(response.body)
    else
      return Annict.error_msg(response)
    end
  end
end
