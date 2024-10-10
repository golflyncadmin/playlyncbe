namespace :notifications do
  desc "Send scheduled push notifications"
  task send: :environment do
    puts "Starting notifications task..."
    current_hour = Time.now.hour
    current_day = Date.today
    type = 'alerts'

    if current_hour < 11
      subject = "Good Morning"
      body = "You have morning Tee Times, Check now!"
    elsif current_hour < 15
      subject = "Good Afternoon"
      body = "Check out afternoon Tee Times!"
    else
      subject = "Good Evening"
      body = "Check your evening Tee Times!"
    end

    User.includes(:tee_times).find_each do |user|
      tee_times_in_range = user.tee_times.any? do |tee_time|
        course_date_parsed = Date.strptime(tee_time.course_date, "%m/%d/%Y")
        tee_time_parsed = Time.parse(tee_time.start_time)
        tee_time_date = course_date_parsed
        tee_time_hour = tee_time_parsed.hour

        tee_time_date == current_day && tee_time_hour == current_hour
      end

      next unless tee_times_in_range

      begin
        notification = NotificationService.new(user, subject, body, type).create_notification
        if notification
          otp_service = OtpService.new(user)
          otp_service.send_tee_times_mail
          otp_service.send_tee_times_sms
          puts "Notification created and sent for user #{user.id} at #{current_hour}:00"
        else
          puts "Failed to create notification for user #{user.id}"
        end
      rescue => e
        puts "Error processing notification for user #{user.id}: #{e.message}"
      end
    end
  end
end
