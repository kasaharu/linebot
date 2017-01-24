class Weather < ApplicationRecord
  def self.fetch
    uri = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=130010')
    http = Net::HTTP.new(uri.host, uri.port)
    return http.start {
      http.get(uri.request_uri)
    }
  end

  def self.parse_msg(body)
    result = JSON.parse(body)
    puts result['title']
    return result['title'] + "\n\n" + result['description']['text']
  end

  def self.error_msg(res)
    return "[#{response.code}] 天気の取得に失敗しました #{response.message}"
  end
end