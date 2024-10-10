class Admins::DashboardController < Admins::BaseController
  def index
    @total_users = User.all
    @sort_direction = params[:sort] == "asc" ? "asc" : "desc"

    @users = User.all

    if params[:search].present?
      @users = @users.search_by_full_name_and_email_and_phone_number(params[:search])
    end

    if params[:start].present? && params[:end].present?
      start_date = Date.strptime(params[:start], '%m/%d/%Y')
      end_date = Date.strptime(params[:end], '%m/%d/%Y')
      @users = @users.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end

    @users = @users.paginate(page: params[:page], per_page: 10).order(created_at: @sort_direction)
  end

  def delete_users    
    if params[:user_ids].present?
      User.where(id: params[:user_ids]).destroy_all
      flash[:notice] = "Selected users have been deleted."
    else
      flash[:alert] = "No users selected."
    end
    redirect_to admins_dashboard_index_path, status: :ok
  end  

  def send_notifications
    user_ids = params[:user_ids]
    message = params[:message]
    subject = "App Notification"
    type = "issue"
    if user_ids.present? && message.present?
      users = User.where(id: user_ids)
  
      users.each do |user|
        notification_service = NotificationService.new(user, subject, message, type)
        notification_service.create_notification
      end
      flash[:notice] = 'Notifications sent successfully.'
    else
      flash[:alert] = 'No users selected or message is empty.'
    end
    redirect_to admins_dashboard_index_path, status: :ok
  end  
end
