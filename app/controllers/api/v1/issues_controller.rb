class Api::V1::IssuesController < Api::ApiController

  # Report an issue
  def create
    issue = Issue.new(issue_params)

    if issue.save
      success_response('Issue reported successfully', { issue: IssueSerializer.new(issue) }, :created)
    else
      error_response(issue.errors.full_messages.join(', '), :unprocessable_entity)
    end
  end

  private

  def issue_params
    params.require(:issue).permit(:email, :subject, :body)
  end
end
