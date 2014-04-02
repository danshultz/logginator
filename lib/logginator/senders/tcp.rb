require 'socket'

class Logginator::Senders::TCP

  def initialize(address, port)
    @address = address
    @port = port.to_i
    @socket = TCPSocket.new(address, port)
  end


  def <<(data)
    @socket.send(data, 0)
  end

end
