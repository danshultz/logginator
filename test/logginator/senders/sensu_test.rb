require 'test_helper'
require 'socket'

class SendersSensuTest < MiniTest::Unit::TestCase

  def setup
    bind_socket
  end


  def test_it_sends_data_to_udp_port
    sender = Logginator::Senders::Sensu.new('127.0.0.1', port)
    sender << 'some data'

    expected = {
      :handlers => ['metrics'],
      :name => 'general-metrics',
      :status => 0,
      :output => 'some data',
      :type => 'metric'
    }.to_json

    result = socket.recvfrom(100).shift
    assert_equal(expected, result)
  end


  def test_it_takes_options
    opts = { :name => 'check-name', :handlers => ['some-handler'] }
    sender = Logginator::Senders::Sensu.new('127.0.0.1', port, opts)
    sender << 'some data'

    expected = {
      :handlers => ['some-handler'],
      :name => 'check-name',
      :status => 0,
      :output => 'some data',
      :type => 'metric'
    }.to_json

    result = socket.recvfrom(100).shift
    assert_equal(expected, result)
  end

  protected

    attr_reader :socket

    def bind_socket
      @socket ||= UDPSocket.new.tap { |sock| sock.bind('127.0.0.1', 0) }
    end

    def port
      @port ||= socket.addr[1]
    end

end
