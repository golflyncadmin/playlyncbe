module Response

	def success_response(success, status_code, message, object, status = :ok)
    render json: { success: success, status_code: status_code, message: message, data: object }, status: status
  end
  
  def error_response(message, status)
    render json: { message: message}, status: status
  end
end
