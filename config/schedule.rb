set :output, "log/cron_log.log"

(7..18).each do |hour|
  every :day, at: "#{hour}:00" do
    rake "notifications:send"
  end
end
