class Api::V1::TeeTimesController < Api::ApiController
  before_action :authorize_request

  def index
    @tee_times = current_user.tee_times
    success_response("All tee times", @tee_times, :ok)
  end

  def alerts
    today = Date.today
    tee_times_today = current_user.tee_times.where(course_date: today.strftime('%m/%d/%Y'))

    if tee_times_today.any?
      grouped_by_course = tee_times_today.group_by(&:course_name)

      response_data = grouped_by_course.map do |course_name, tee_times|
        grouped_tee_times = {
          morning_tee_times:   group_tee_times(tee_times, 7..10),
          afternoon_tee_times: group_tee_times(tee_times, 11..14),
          evening_tee_times:   group_tee_times(tee_times, 15..19)
        }

        first_booking_url = tee_times.first.booking_url
        common_url = extract_common_url(first_booking_url)

        {
          course_name: course_name,
          course_date: tee_times.first.course_date,
          common_url: common_url,
          tee_times: grouped_tee_times
        }
      end

      success_response("Tee times for today", response_data, :ok)
    else
      success_response("No tee times for today", [], :ok)
    end
  end

  private

  def group_tee_times(tee_times, hour_range)
    tee_times.select do |tee_time|
      tee_time_time = Time.strptime(tee_time.start_time, '%I:%M %p').hour
      hour_range.include?(tee_time_time)
    end.map do |tee_time|
      {
        start_time:  tee_time.start_time,
        course_date: format_date(tee_time.course_date),
        min_price:   tee_time.min_price,
        max_price:   tee_time.max_price,
        max_players: tee_time.max_players,
        address:     tee_time.address,
        booking_url: tee_time.booking_url
      }
    end
  end

  def format_date(date_str)
    Date.strptime(date_str, '%m/%d/%Y').strftime('%-m-%d-%y')
  end

  def extract_common_url(booking_url)
    booking_url.match(/(https:\/\/www\.golfnow\.com\/\/tee-times\/facility\/\d+\/tee-time)/)[0]
  end

  def tee_time_params
    params.require(:tee_time).permit(:course_name, :start_time, :min_price, :max_price, :address, :course_date, :max_players)
  end
end
