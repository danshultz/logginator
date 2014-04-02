require 'test_helper'
require 'socket'

class SendersTcpTest < MiniTest::Unit::TestCase

  def setup
    bind_socket
  end


  def test_it_sends_data_to_udp_port
    sender = Logginator::Senders::TCP.new('127.0.0.1', port)
    sender << 'some data'

    result = socket.accept.recvfrom(10).shift
    assert_equal('some data', result)
  end

  protected

    attr_reader :socket

    def bind_socket
      @socket ||= TCPServer.new('127.0.0.1', 0)
    end

    def port
      @port ||= socket.addr[1]
    end

end
