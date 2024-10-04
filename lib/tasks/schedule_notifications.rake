namespace :notifications do
  desc "Send scheduled notifications"
  task send: :environment do
    puts "Starting notifications task..."
    current_time = Time.now.hour


    time_slots = {
      7 => { start: 7, end: 11, subject: "Good Morning", body: "Start your day with this update!" },
      11 => { start: 11, end: 15, subject: "Good Afternoon", body: "Check out this afternoon update!" },
      15 => { start: 15, end: 19, subject: "Good Evening", body: "Check your evening updates!" }
    }

    time_slots.each do |slot_hour, time_range|
      if current_time == slot_hour
        User.includes(:tee_times).find_each do |user|
          tee_times_in_range = user.tee_times.select do |tee_time|
            tee_time_start = Time.strptime(tee_time.start_time, "%I:%M %p").hour
            tee_time_start.between?(time_range[:start], time_range[:end] - 1)
          end

          if tee_times_in_range.empty?
            puts "No tee time available for user #{user.id}"
            next
          end

          begin
            puts "Current time_slot: #{current_time}, #{time_range[:subject]}"
            notification = NotificationService.new(user, time_range[:subject], time_range[:body]).create_notification
            if notification
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
  end
end
