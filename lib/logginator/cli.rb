require 'mixlib/cli'

class Logginator::CLI
  include Mixlib::CLI

  option(
    :tail_command,
    :long => '--tail-command TAIL',
    :desciption => 'sets the tail command',
    :default => 'tail -F %s'
  )


  option(
    :file,
    :long => '--file FILE',
    :desciption => 'log file to be followed',
    :required => true,
  )


  option(
    :flush_interval,
    :long => '--flush FLUSH',
    :desciption => 'how often the metrics are flushed',
    :default => 10,
    :proc => Proc.new { |x| x.to_i }
  )


  option(
    :sender,
    :long => '--sender SENDER',
    :description => 'sender to use in dumping data'
  )


  option(
    :port,
    :long => '--port PORT',
    :desciption => 'port to use for the sender'
  )


  option(
    :address,
    :long => '--address ADDRESS',
    :desciption => 'address to send data to'
  )

  def initialize(args=ARGV)
    super()
    parse_options(args)
  end


  def run!
    parser = Logginator::LogParser::Nginx.new
    context = Logginator::Context.new(parser, build_sender, tail_command)

    opts = { :flush_interval => config[:flush_interval] }
    supervisor = Logginator::Supervisor.new(context, opts)
    supervisor.run
  end

  protected

    def tail_command
      sprintf(config[:tail_command], config[:file])
    end


    def build_sender
      if (sender = config[:sender])
        port = config[:port]
        address = config[:address]
        find_sender(sender).new(address, port)
      else
        $stdout
      end
    end

    def find_sender(sender)
      klazz = Logginator::Senders.constants.detect { |s|
        s.to_s.downcase == sender.downcase
      }
      raise StandardError, "sender #{sender} not found" unless klazz
      Logginator::Senders.const_get(klazz)
    end

end
