class Logginator::Supervisor

  attr_reader :flush_interval, :worker_check_interval, :context

  def initialize(context, opts = {})
    @run = true
    @flush_interval = opts.fetch(:flush_interval, 10)
    @worker_check_interval = opts.fetch(:check_worker, 5)
    @context = context
  end


  def abort!
    @run = false
  end


  def run
    raise StandardError, "already running" if @running

    @running = true
    worker = start_worker
    timer = start_timer

    # block the current thread and monitor the worker
    while(@run) do
      sleep(0.5)
      worker = start_worker unless worker.alive?
      timer = start_timer unless timer.alive?
    end
    worker.kill
    timer.kill
    @running = false
  end

  private

    def start_worker
      Thread.new(context) { |context|
        Thread.current.abort_on_exception = false
        context.read_log.each { |line| context.parse_line(line) }
      }
    end


    def start_timer
      Thread.new(context, flush_interval) { |context, flush_interval|
        Thread.current.abort_on_exception = false
        loop do
          sleep(flush_interval)
          context.flush
        end
      }
    end

end
