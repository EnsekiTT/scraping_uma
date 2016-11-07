require './database_uma.rb'
require 'open-uri'
require 'nokogiri'
require 'date'
require 'bundler/setup'
require 'capybara/poltergeist'
Bundler.require

class Comment < ActiveRecord::Base
end
class Uma < ActiveRecord::Base
end

def get_comment_uri(uma_id)
  # コメントページの基本的なURL（uma_idごとに掲示板があった）
  url = "とても詳しい馬のページの掲示板" + uma_id

  # Capybaraのセットアップ
  # JSでデータを受信して、クライアントサイドで掲示板を生成していたので
  # Open-uriではなくCapybaraで訪問することに
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000 })
  end
  session = Capybara::Session.new(:poltergeist)

  # このページではGET QUERYで掲示板のページ数を管理していたので、
  # コメントページを何ページ分まで取るか指定する。
  comment_range = 1..15
  comment_range.each{|page|
    # コメントページのURLを生成する
    comment_url = url + '&page=' + page.to_s
    puts comment_url

    # Capybaraのセッションでサイトに訪れる
    session.visit comment_url
    if session.status_code == 200
      # 各コメントごとにデータベースに突っ込む
      session.find('#Comment_List').all('li.border_bottom').each do |single_com|
        id_str = single_com.find('div:nth-child(1) > div:nth-child(1)').text
        id = id_str.match(/\[(.+)\]/)
        comment_id = uma_id.to_s + id[1].to_s
        comment = single_com.find('.comment').text
        # UmaのIDとコメントのIDとコメントを入れてみた。
        # 他のメタ情報もあってもいいけど、後はベクトル化しか無いので今回はこれで
        line = {
          :uma_id => uma_id,
          :comment_id => comment_id,
          :comment => comment,
        }

        # コメントIDでかぶってないことを確認したらデータを追加
        if Comment.find_by(comment_id: comment_id) == nil
          Comment.create(line)
        end
      end
    end
    # 再アクセス待ち
    sleep 1
  }
  # 再アクセス待ち（どちらかでいいと思うけどあるに越したことはない。）
  sleep 1
end

# さっきデータベースに突っ込んだUmaのuma_idを拾っては、コメントを取得するループ
uma_list = Uma.all
uma_list.each{|uma|
  get_comment_uri(uma_id=uma.uma_id)
}
