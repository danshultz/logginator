require 'mixlib/cli'

class Logginator::CLI
  include Mixlib::CLI

  option(
    :tail_command,
    :long => '--tail-command TAIL',
    :description => 'sets the tail command',
    :required => true
  )


  option(
    :flush_interval,
    :long => '--flush FLUSH',
    :description => 'how often the metrics are flushed',
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
    :description => 'port to use for the sender'
  )


  option(
    :address,
    :long => '--address ADDRESS',
    :description => 'address to send data to'
  )


  def initialize(args=ARGV)
    super()
    @parser = args.shift
    parse_options(args)
  end


  def run!
    parser = get_parser.new
    context = Logginator::Context.new(parser, build_sender, tail_command)

    opts = { :flush_interval => config[:flush_interval] }
    supervisor = Logginator::Supervisor.new(context, opts)
    %w(TERM INT).each { |s|
      Signal.trap(s) { supervisor.abort! }
    }
    supervisor.run
  end

  protected

    def tail_command
      config[:tail_command]
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


    def get_parser
      klazz = Logginator::LogParser.constants.detect { |s|
        s.to_s.downcase == @parser.downcase
      }
      raise StandardError, "parser #{@parser} not found" unless klazz
      Logginator::LogParser.const_get(klazz)
    end

end
