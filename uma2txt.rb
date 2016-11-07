require './database_uma.rb'

class Comment < ActiveRecord::Base
end

file = File.open('./uma.txt', 'a')

coms = Comment.all
coms.each{|com|
  file.puts com.comment
}
file.close
