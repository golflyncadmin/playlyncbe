module Response

	def success_response(message, object, status = :ok)
    render json: { message: message, data: object }, status: status
  end
  
  def error_response(message, status)
    render json: { message: message}, status: status
  end
end
