namespace :notifications do
  desc "Send scheduled notifications"
  task send: :environment do
    puts "Starting notifications task..."
    current_time = Time.now.hour
    type = 'alerts'

    time_slots = {
      7 => { start: 7, end: 11, subject: "Good Morning", body: "Start your day with this update!" },
      11 => { start: 11, end: 15, subject: "Good Afternoon", body: "Check out this afternoon update!" },
      15 => { start: 15, end: 19, subject: "Good Evening", body: "Check your evening updates!" }
    }

    if (time_slot = time_slots[current_time])
      puts "Processing time slot: #{current_time}, #{time_slot[:subject]}"

      User.includes(:tee_times).find_each do |user|
        tee_times_in_range = user.tee_times.any? do |tee_time|
          tee_time_start = tee_time.start_time.to_time.hour
          tee_time_start.between?(time_slot[:start], time_slot[:end] - 1)
        end

        next unless tee_times_in_range

        begin
          notification = NotificationService.new(user, time_slot[:subject], time_slot[:body], type).create_notification
          if notification
            otp_service = OtpService.new(user)
            otp_service.send_tee_times_mail
            otp_service.send_tee_times_sms
            puts "Notification created and sent for user #{user.id}"
          else
            puts "Failed to create notification for user #{user.id}"
          end
        rescue => e
          puts "Error processing notification for user #{user.id}: #{e.message}"
        end
      end
    else
      puts "No notifications to send at this hour."
    end
  end
end
