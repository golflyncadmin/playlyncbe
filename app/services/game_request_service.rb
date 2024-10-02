class GameRequestService
  def initialize
    @records = []
    @errors = []
    @log = nil
  end

  def call(request, params)
    start_date = parse_date(params[:start_date])
    end_date = parse_date(params[:end_date])
    
    return result if dates_invalid?(start_date, end_date)

    course_id = params[:course_id]
    puts "course id: #{course_id}"
    time_range = get_time_range(Array(request.time))

    (start_date..end_date).each do |current_date|
      @departure_date = format_date(current_date)
      response = get_course_tee_times(request, course_id, time_range)
      puts "request done for #{current_date}"
      
      if response_error?(response)
        log_error(current_date)
        next
      end

      parse_response(response)
    end

    result
  end

  def geolookup_request(search)
    uri = URI.parse("https://www.golfnow.com/api/autocomplete/geolookup")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json; charset=UTF-8"
    set_headers(request)
    request.body = JSON.dump({
      "searchkey" => search,
      "take" => 20,
      "skip" => 0,
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  def get_course_tee_times(data, course_id, time_range)
    uri = URI.parse("https://www.golfnow.com/api/tee-times/tee-time-results")
    random_port = rand(10000..10004)
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json; charset=UTF-8"
    request.body = build_request_body(data, course_id, time_range)
    set_headers(request)

    req_options = { use_ssl: uri.scheme == "https" }

    response = Net::HTTP.start(uri.hostname, uri.port, ENV['PROXYRACK_HOST'], random_port, ENV['PROXYRACK_USERNAME'], ENV['PROXYRACK_PASSWORD'], req_options) do |http|
      http.request(request)
    end
    JSON.parse(response.body)
  end

  def parse_response(json)
    json["ttResults"]["teeTimes"].each do |tee_time|
      begin
        result_hash = build_result_hash(tee_time)
        @records << result_hash unless @records.include?(result_hash)
      rescue Exception => e
        @log = "Exception while parsing response: #{e.message}"
      end
    end
  end

  def build_result_hash(tee_time)
    {
      course_name:   tee_time["facility"]["name"],
      start_time:    format_json_time(tee_time["time"]),
      course_date:   format_json_date(tee_time["time"]),
      address:       format_address(tee_time["facility"]),
      booking_url:   "https://www.golfnow.com/#{tee_time["detailUrl"]}/checkout/players",
      min_price:     tee_time["minTeeTimeRate"],
      max_price:     tee_time["maxTeeTimeRate"],
      max_players:   get_max_players(tee_time["playerRule"])
    }
  end

  def build_request_body(request, course_id, time_range)
    JSON.dump({
    "Radius" => 25,
    "PageSize" => 60,
    "PageNumber" => 0,
    "SearchType" => 1,
    "SortBy" => "Date",
    "SortDirection" => 0,
    "FacilityId"=> course_id,
    "Date" => @departure_date,
    "BestDealsOnly" => false,
    "PriceMin" => 0,
    "PriceMax" => 10000,
    "Players" => request.players,
    "TimePeriod" => 3,
    "Holes" => 3,
    "RateType" => "all",
    "TimeMin" => time_range[:min],
    "TimeMax" => time_range[:max],
    "SortByRollup" => "Date.MinDate",
    "View" => "Grouping",
    "ExcludeFeaturedFacilities" => true,
    "TeeTimeCount" => 20,
  })
  end

  def set_headers(request)
    headers.each { |key, value| request[key] = value }
  end

  def headers
    @headers ||= {
      "Accept" => "application/json, text/javascript, */*; q=0.01",
      "Accept-Language" => "en-US,en;q=0.9,nl;q=0.8,it;q=0.7,gl;q=0.6",
      "Origin" => "https://www.golfnow.com",
      "Sec-Fetch-Site" => "same-origin",
      "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
      "X-Requested-With" => "XMLHttpRequest"
    }
  end

  def format_address(facility)
    address = facility["address"]
    [address["line1"], address["city"], address["stateProvinceCode"], address["postalCode"]].compact.join(', ')
  end

  def format_json_date(datetime_str)
    Date.parse(datetime_str).strftime("%m/%d/%Y")
  end

  def format_json_time(datetime_str)
    datetime = DateTime.parse(datetime_str)
    datetime.strftime("%I:%M %p")
  end

  def get_time_range(time_periods)
    time_periods = Array(time_periods).map(&:downcase)
    
    min_max_ranges = {
      'morning' => { min: 14, max: 22 },
      'afternoon' => { min: 22, max: 30 },
      'evening' => { min: 30, max: 38 }
    }
    
    min = nil
    max = nil

    time_periods.each do |period|
      range = min_max_ranges[period]
      if range
        min = min.nil? ? range[:min] : [min, range[:min]].min
        max = max.nil? ? range[:max] : [max, range[:max]].max
      end
    end
    
    { min: min, max: max }
  end

  def get_max_players(player_rule)
    case player_rule
    when 1
      1
    when 3
      2
    when 7
      3
    when 15
      4
    else
      1
    end
  end

  def parse_date(date_str)
    Date.parse(date_str)
  rescue ArgumentError
    @log = "Invalid date format: #{date_str}"
    nil
  end

  def format_date(date)
    date.strftime("%b %d %Y")
  end

  def response_error?(response)
    error_message = response.dig("ttException", "errorMessage")
    if error_message.present?
      @log = error_message
      true
    else
      false
    end
  end

  def dates_invalid?(start_date, end_date)
    if end_date && start_date && end_date < start_date
      @log = "End date cannot be earlier than start date."
      true
    else
      false
    end
  end

  def log_error(date)
    @errors << { date: date, error: @log }
  end

  def result
    {
      success: !@records.empty?,
      records: @records,
      log: @log,
      errors: @errors
    }
  end
end
