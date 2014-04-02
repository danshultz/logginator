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


  def initialize(args=ARGV)
    super()
    parse_options(args)
  end


  def run!
    parser = Logginator::NginxLogParser.new
    context = Logginator::Context.new(parser, $stdout, tail_command)

    opts = { :flush_interval => config[:flush_interval] }
    supervisor = Logginator::Supervisor.new(context, opts)
    supervisor.run
  end

  protected

    def tail_command
      sprintf(config[:tail_command], config[:file])
    end

end
