class Admins::DashboardController < Admins::BaseController
  def index
    @total_users = User.all
    if params[:search].present?
      @users = User.search_by_full_name_and_email_and_phone_number(params[:search])
    else
      @users = User.order(created_at: :desc)
    end

    if params[:start].present? && params[:end].present?
      start_date = Date.strptime(params[:start], '%m/%d/%Y')
      end_date = Date.strptime(params[:end], '%m/%d/%Y')

      @users = @users.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
  end

  def delete_users    
    if params[:user_ids].present?
      User.where(id: params[:user_ids]).destroy_all
      render json: { message: "Selected users have been deleted." }, status: :ok
    else
      render json: { error: "No users selected." }, status: :unprocessable_entity
    end
  end

  def send_notifications
    user_ids = params[:user_ids]
    message = params[:message]
    subject = "New Notification"
    
    if user_ids.present? && message.present?
      users = User.where(id: user_ids)
      
      users.each do |user|
        notification_service = NotificationService.new(user, subject, message)
        notification_service.create_notification
      end
  
      render json: { success: true, message:pz "Notifications sent successfully." }, status: :ok
    else
      render json: { success: false, message: "No users selected or message is empty." }, status: :unprocessable_entity
    end
  end
end
