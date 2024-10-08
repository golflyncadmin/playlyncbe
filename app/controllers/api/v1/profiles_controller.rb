class Api::V1::ProfilesController < Api::ApiController
  before_action :authorize_request
  before_action :set_user

  # Profile show
  def show
    success_response('Profile fetched successfully', UserSerializer.new(@user), :ok)
  end

  def update
    if @user.update(profile_params)
      success_response('Profile updated successfully', UserSerializer.new(@user), :ok)
    else
      error_response(@user.errors.full_messages.join(', '), :unprocessable_entity)
    end
  end

  # Delete profile
  def destroy
    @user.destroy
    success_response('Profile deleted successfully', [], :ok)
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:profile).permit(:first_name, :last_name)
  end
end
