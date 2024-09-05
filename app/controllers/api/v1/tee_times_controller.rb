class Api::V1::TeeTimesController < Api::ApiController
  before_action :authorize_request

  def index
    @tee_times = current_user.tee_times
    success_response("All tee times", @tee_times, :ok)
  end

  def alerts
    today = Date.today
    @alerts = current_user.tee_times.select do |tee_time|
      tee_time.course_date.present? && Date.strptime(tee_time.course_date, '%m/%d/%Y') == today
    end

    if @alerts.any?
      success_response("Tee times for today", @alerts, :ok)
    else
      success_response("No tee times for today", [], :not_found)
    end
  end

  private

  def tee_time_params
    params.require(:tee_time).permit(:course_name, :start_time, :min_price, :max_price, :address, :course_date, :max_players)
  end
end
