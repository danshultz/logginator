require 'socket'

class Logginator::NginxLogParser

  MATCHER = /#{[
    '^.*?',
    '(?<request_time>\d*\.?\d*) ',
    '(?<upstream_time>\d*\.?\d*) .$'
  ].join('')}/

  attr_accessor :request_count, :total_request_time, :min, :max


  def initialize(scheme = nil)
    @scheme = scheme || "#{Socket.gethostname}"
    reset
  end


  def reset
    @request_count = 0
    @total_request_time = 0.0
    @min = nil
    @max = nil
  end


  def parse_line(line)
    MATCHER.match(line, &method(:gather_stats))
  end


  def get_stats
    timestamp = Time.now.to_i
    stats_data.reduce('') { |o, kv|
      o << "#{@scheme}.requests.#{kv[0]}\t#{kv[1]}\t#{timestamp}\n"
    }
  end

  protected

    def gather_stats(data)
      req_time = data[:request_time].to_f
      self.request_count += 1
      self.total_request_time += req_time
      self.min = (min && min < req_time) ? min : req_time
      self.max = (max && max > req_time) ? max : req_time
    end

    def stats_data
      average = if (request_count == 0)
        0
      else
        total_request_time.fdiv(request_count).round(5)
      end

      {
        'count' => request_count,
        'average' => average,
        'min' => min || 0,
        'max' => max || 0
      }
    end

end
