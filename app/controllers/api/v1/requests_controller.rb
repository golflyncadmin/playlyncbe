class Api::V1::RequestsController < Api::ApiController
  before_action :authorize_request
  before_action :set_request, only: [:show, :destroy]

  # Create user request
  def create
    if current_user.requests.exists?(start_date: request_params[:start_date], end_date: request_params[:end_date],
                                     time: request_params[:time], location: request_params[:location],
                                     players: request_params[:players])

      return error_response('Request already exists with these parameters', :unprocessable_entity)
    end

    @request = current_user.requests.new(request_params)
    course = @request.location.split(',').map(&:strip)

    # create request course
    Course.find_or_create_by!(id: params[:course_id], course_name: course[0], course_location: course[1..-1].join(', '), user_id: @request.user.id, status: "approved")
    response = GameRequestService.new.call(@request, params)
    if response[:records].present? && response[:success]
      if @request.save
        response[:records].each do |record|
          tee_time = @request.tee_times.new(tee_time_params(record))
          tee_time.user_id = current_user.id
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

  # get all requests
  def index
    @requests = current_user.requests
    success_response('All requests', @requests, :ok)
  end

  # Delete single request
  def destroy
    if @request
      @request.destroy
      success_response('Request deleted successfully', [] , :ok)
    else
      error_response("No request found", :unprocessable_entity)
    end
  end

  # search suggestions
  def search
    response = get_suggestions(params[:search])
    if response
      json = parse_json(response.body)
      locations = get_locations(json)
      courses = get_courses(json)

      success_response("search results", course_suggestions: courses, location_suggestions: locations)
    else
      error_response("No result found", :unprocessable_entity)
    end
  end

  # get course location
  def location_courses
    response = get_suggestions(params[:location])
    if response
      json = parse_json(response.body)
      courses = get_courses(json)

      success_response("search results", course_suggestions: courses)
    else
      error_response("No result found", :unprocessable_entity)
    end
  end

  private

  def set_request
    @request = current_user.requests.find_by(id: params[:id])
  end

  def request_params
    params.require(:request).permit(:start_date, :end_date, :location, {:time => []}, :players, :course_id)
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

  def get_suggestions(query)
    response = GameRequestService.new.geolookup_request(query)
    response.code == "200" ? response : nil
  end

  def parse_json(response_body)
    JSON.parse(response_body)
  end

  def get_locations(json)
    json["hits"]
      .select { |hit| ["city", "postal"].include?(hit["type"]) }
      .map { |hit| hit["displayName"] }.uniq
  end

  def get_courses(json)
    json["hits"]
      .select { |hit| hit["type"] == "course" }
      .map { |hit| { course_name: hit["displayName"], course_id: hit["contextInformation"]["courseId"] } }.uniq
  end
end
