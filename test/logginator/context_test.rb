require 'test_helper'

class ContextTest < MiniTest::Unit::TestCase

  def setup
    @parser = mock
    @sender = mock
  end

  def test_flush_gets_stats_and_sends
    stats = Object.new

    parser.expects(:get_stats).returns(stats)
    parser.expects(:reset).once
    sender.expects(:<<).with(stats)

    context.flush
  end


  def test_read_log_opens_command
    @tail_command = 'echo hello'
    data = context.read_log.to_a
    assert_equal(["hello\n"], data)
  end


  def test_parse_line_calls_parser
    line = ''
    parser.expects(:parse_line).with(line)

    context.parse_line(line)
  end

  protected

    attr_reader :parser, :sender, :tail_command

    def context
      @context ||= Logginator::Context.new(parser, sender, tail_command)
    end

end
