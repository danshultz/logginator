require 'test_helper'

class SupervisorTest < MiniTest::Unit::TestCase

  def test_each_log_line_is_parsed
    context = mock
    io = MockIO.new(["line one", "line two"])
    context.expects(:read_log).once.returns(io)
    supervisor = Logginator::Supervisor.new(context)

    context.expects(:parse_line).with("line one")
    context.expects(:parse_line).with("line two")

    t = Thread.new { supervisor.run }
    sleep(0.1)
    supervisor.abort!
    t.join
  end


  def test_parser_is_flushed
    context = mock
    context.stubs(:read_log).once.returns(MockIO.new)
    context.expects(:flush).at_least_once
    supervisor = Logginator::Supervisor.new(context, :flush_interval => 0.1)


    t = Thread.new { supervisor.run }
    sleep(0.2)
    supervisor.abort!
    t.join
  end

end
