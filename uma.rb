require './database_uma.rb'
require 'open-uri'
require 'nokogiri'
require 'date'
class Uma < ActiveRecord::Base
end

def get_uma_list(url)
  puts url
  # アクセスするところ
  html = open(url){|f|
    f.read
  }

  # Nokogiriでパースする
  doc = Nokogiri::HTML.parse(html, nil, 'euc-jp')
  umas = doc.css('.db_data_list')

  # Databaseに入れる
  umas.css('tr').each{|uma|
    # 実際にパースするところ
    name = uma.css('a').text
    uri = uma.css('a').first[:href]
    # uriにUmaのIDが含まれているので、正規表現で引っこ抜く
    id_str = uri.match(/\/horse\/(.+)\//)
    uma_id = id_str[1]
    rate = uma.css('strong').text.to_f

    # UmaのIDと名前と詳細URLとレートを突っ込んでみた。
    line = {
      :uma_id => uma_id,
      :name => name,
      :uri => uri,
      :rate => rate,
    }
    # 被ったUma_idがなければデータ生成
    if Uma.find_by(uma_id: uma_id) == nil
      Uma.create(line)
    end
  }
  # 再アクセス待ち
  sleep 1
end

# ランキングサイトからuma_idとURLを取得するループ
range = 1..100
range.each{|page|
  # URLの生成
  url = "とても詳しいUmaのページのUmaランキング" + page.to_s
  get_uma_list(url=url)
}
