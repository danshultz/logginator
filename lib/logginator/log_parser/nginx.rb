class Logginator::LogParser::Nginx
  MATCHERS = Logginator::LogParser::Matchers

  MATCHER = /#{[
    "^(?<host>#{MATCHERS::HOSTNAME}) -- ",
    "(?<remote_address>#{MATCHERS::IPORHOST}) - ",
    "(?<remote_user>#{MATCHERS::USERNAME})? ",
    "\\[(?<time_local>#{MATCHERS::HTTPDATE})\\] ",
    '(?<request>".*") ',
    "(?<status_code>#{MATCHERS::INT}) ",
    '.*?',
    "(?<request_time>#{MATCHERS::NUMBER}) ",
    "(?<upstream_time>#{MATCHERS::NUMBER}) .$"
  ].join('')}/

  attr_accessor :request_count, :total_request_time, :min, :max,
    :total_upstream_time, :upstream_min, :upstream_max, :response_codes


  def initialize(scheme = nil)
    @scheme = scheme || "#{Socket.gethostname}"
    reset
  end


  def reset
    @request_count = 0
    @total_request_time = 0.0
    @total_upstream_time = 0.0
    @min = nil
    @max = nil
    @upstream_min = nil
    @upstream_max = nil
    @response_codes = {}
  end


  def parse_line(line)
    MATCHER.match(line, &method(:gather_stats))
  end


  def get_stats
    timestamp = Time.now.to_i
    stats_data.reduce('') { |o, kv|
      o << "#{@scheme}.nginx.requests.#{kv[0]}\t#{kv[1]}\t#{timestamp}\n"
    }
  end

  protected

    def gather_stats(data)
      self.request_count += 1

      if status_code = data[:status_code]
        response_codes[status_code] ||= 0
        response_codes[status_code] += 1
      end

      req_time = data[:request_time].to_f
      self.total_request_time += req_time
      self.min = get_min(min, req_time)
      self.max = get_max(max, req_time)

      upstream_req_time = data[:upstream_time].to_f
      self.total_upstream_time += upstream_req_time
      self.upstream_min = get_min(upstream_min, upstream_req_time)
      self.upstream_max = get_max(upstream_max, upstream_req_time)
    end


    def get_min(min, new_val)
      (min && min < new_val) ? min : new_val
    end


    def get_max(max, new_val)
      (max && max > new_val) ? max : new_val
    end


    def stats_data
      response_code_data = response_codes.reduce({}) { |accum, (k,v)|
        accum.tap { accum["status_codes.#{k}"] = v }
      }

      {
        'count' => request_count,
        'average' => calculate_average(total_request_time),
        'min' => min || 0,
        'max' => max || 0,
        'upstream_average' => calculate_average(total_upstream_time),
        'upstream_min' => upstream_min || 0,
        'upstream_max' => upstream_max || 0
      }.merge(response_code_data)
    end


    def calculate_average(total_time)
      if (request_count == 0)
        0
      else
        total_time.fdiv(request_count).round(5)
      end
    end

end
