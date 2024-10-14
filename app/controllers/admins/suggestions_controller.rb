class Admins::SuggestionsController < Admins::BaseController
  def index
    @new_courses = Course.pending
    @approved_courses = Course.admin_approved
    @declined_courses = Course.declined
    @new_issues = Issue.new_issues
    @archived_issues = Issue.archived_issues
  end

  def send_message
    issue = Issue.find(params[:id])
    email = params[:email]
    message_content = params[:message]

    otp_service = OtpService.new(issue)

    if otp_service.send_custom_email(email, message_content)
      issue.update(status: :archived)
      flash[:notice] = 'Message sent successfully.'
    else
      flash[:alert] = 'Failed to send message.'
    end

    redirect_to admins_suggestions_path
  end
end