class Logginator::Context

  def initialize(parser, sender, tail_command)
    @mutex = Mutex.new
    @parser = parser
    @sender = sender
    @tail_command = tail_command
  end

  def flush
    stats = nil
    @mutex.synchronize {
      stats = parser.get_stats
      parser.reset
    }
    sender << stats
  end

  def read_log
    IO.popen(tail_command)
  end


  def parse_line(line)
    @mutex.synchronize {
      parser.parse_line(line)
    }
  end

  private

    attr_accessor :parser, :sender, :tail_command

end
