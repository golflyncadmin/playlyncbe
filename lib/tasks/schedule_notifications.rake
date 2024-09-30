namespace :notifications do
  desc "Send scheduled notifications"
  task send: :environment do
    puts "Starting notifications task..."
    current_time = Time.now.hour
    current_time = 15
    puts "Current time: #{current_time}"

    User.find_each do |user|
      begin
        subject, body = case current_time
                        when 7
                          ["Good Morning", "Start your day with this update!"]
                        when 12
                          ["Good Afternoon", "Check out this afternoon update!"]
                        when 15
                          ["Good Evening", "Check your evening updates!"]
                        else
                          next
                        end

        if Notification.send_and_create_notification(user, subject, body)
          puts "Notification created and sent for user #{user.id}"
        else
          puts "Failed to send notification for user #{user.id}"
        end
      rescue => e
        puts "Error processing notification for user #{user.id}: #{e.message}"
        next
      end
    end
  end
end
