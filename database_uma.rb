require 'active_record'
require 'logger'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql2',
  :database => 'uma',
  :host     => '****host', # 自分のを埋めてください
  :username => '****name', # 自分のを埋めてください
  :password => '****password' # 自分のを埋めてください
)

ActiveRecord::Base.logger = Logger.new(STDERR)

Time.zone_default = Time.find_zone! 'Tokyo'
ActiveRecord::Base.default_timezone = :local
