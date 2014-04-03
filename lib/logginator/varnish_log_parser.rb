class Logginator::VarnishLogParser

  MATCHER = /#{[
    '(\d* ReqEnd\s*[a-z]\s)',
    '(?<xid>\d*)\s',
    '(?<start_time>\d*\.?\d*)\s',
    '(?<end_time>\d*\.?\d*)\s',
    '(?<queue_time>\d*\.?\d*)\s',
    '(?<back_end_time>\d*\.?\d*)\s',
    '(?<delivery_time>\d*\.?\d*)'
  ].join('')}/

  attr_accessor :request_count, :total_request_time, :min, :max,
    :total_upstream_time, :upstream_min, :upstream_max,
    :total_queue_time, :queue_max, :queue_min


  def initialize(scheme = nil)
    @scheme = scheme || "#{Socket.gethostname}"
    reset
  end


  def reset
    @request_count = 0
    @total_request_time = 0.0
    @total_upstream_time = 0.0
    @total_queue_time = 0.0

    @min = nil
    @max = nil
    @upstream_min = nil
    @upstream_max = nil
    @queue_min = nil
    @queue_max = nil
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
      self.request_count += 1

      req_time = data[:back_end_time].to_f + data[:delivery_time].to_f
      self.total_request_time += req_time
      self.min = get_min(min, req_time)
      self.max = get_max(max, req_time)

      upstream_req_time = data[:back_end_time].to_f
      self.total_upstream_time += upstream_req_time
      self.upstream_min = get_min(upstream_min, upstream_req_time)
      self.upstream_max = get_max(upstream_max, upstream_req_time)

      queue_time = data[:queue_time].to_f
      self.total_queue_time += queue_time
      self.queue_min = get_min(queue_min, queue_time)
      self.queue_max = get_max(queue_max, queue_time)
    end


    def get_min(min, new_val)
      (min && min < new_val) ? min : new_val
    end


    def get_max(max, new_val)
      (max && max > new_val) ? max : new_val
    end


    def stats_data
      {
        'count' => request_count,

        'average' => calculate_average(total_request_time),
        'min' => min || 0,
        'max' => max || 0,

        'upstream_average' => calculate_average(total_upstream_time),
        'upstream_min' => '%.9f' % upstream_min || 0,
        'upstream_max' => '%.9f' % upstream_max || 0,

        'queue_average' => calculate_average(total_queue_time),
        'queue_min' => '%.9f' % queue_min || 0,
        'queue_max' => '%.9f' % queue_max || 0
      }
    end


    def calculate_average(total_time)
      if (request_count == 0)
        0
      else
        '%.9f' % total_time.fdiv(request_count).round(5)
      end
    end

end
