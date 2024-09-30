set :output, "log/cron_log.log"

every :day, at: '7:00 am' do
  rake "notifications:send"
end

every :day, at: '12:00 pm' do
  rake "notifications:send"
end

every :day, at: '3:00 pm' do
  rake "notifications:send"
end

# every 1.minutes do
#   rake "notifications:send"
# end