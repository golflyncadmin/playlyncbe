class Api::V1::RequestsController < Api::ApiController
  before_action :authorize_request
  before_action :set_request, only: [:show, :destroy]


  def create
    @request = current_user.requests.new(request_params)
    @request.geocode

    unless @request.valid_location?
      return error_response('Location not found!', :unprocessable_entity)
    end
    
    response = GameRequestService.new.call(@request, params)
    if response[:records].present? && response[:success]
      if @request.save
        response[:records].each do |record|
          tee_time = current_user.tee_times.new(tee_time_params(record))
          unless tee_time.save
            Rails.logger.error "Failed to save tee time: #{tee_time.errors.full_messages.join(', ')}"
          end
        end
        success_response('Request created successfully with tee times', { request: RequestSerializer.new(@request), errors: response[:errors]}, :created)
      else
        error_response(@request.errors.full_messages.join(', '), :unprocessable_entity)
      end
    else
      error_response("#{response[:log]}. Please adjust your request parameters.", :unprocessable_entity)
    end
  end

  def index
    @requests = current_user.requests
    success_response('All requests', @requests, :ok)
  end

  def destroy
    if @request
      @request.destroy
      success_response('Request deleted successfully', [] , :ok)
    else
      error_response("No request found", :unprocessable_entity)
    end
  end

  private

  def set_request
    @request = current_user.requests.find_by(id: params[:id])
  end

  def request_params
    params.require(:request).permit(:start_date, :end_date, :location, {:time => []}, :players)
  end

  def tee_time_params(record)
    {
      course_name:   record[:course_name],
      start_time:    record[:start_time],
      course_date:   record[:course_date],
      booking_url:   "#{record[:booking_url]}/#{params[:players]}",
      min_price:     record[:min_price],
      max_price:     record[:max_price],
      max_players:   record[:max_players],
      address:       record[:address]
    }
  end
end
