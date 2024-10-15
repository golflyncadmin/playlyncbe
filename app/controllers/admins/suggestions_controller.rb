class Admins::SuggestionsController < Admins::BaseController
  def new_request
    @new_courses = Course.pending
  end

  def approved
    @approved_courses = Course.admin_approved
  end

  def declined
    @declined_courses = Course.declined
  end

  def send_message
    issue = Issue.find(params[:id])
    email = params[:email]
    message_content = params[:message]

    if message_content.blank?
      flash[:alert] = 'Message content cannot be empty.'
      return redirect_to new_issues_admins_problems_path
    end
  
    otp_service = OtpService.new(issue)

    if otp_service.send_custom_email(email, message_content)
      issue.update(status: :archived)
      flash[:notice] = 'Message sent successfully.'
    else
      flash[:alert] = 'Failed to send message.'
    end

    redirect_to new_issues_admins_problems_path
  end
end