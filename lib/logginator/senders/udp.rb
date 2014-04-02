require 'socket'

class Logginator::Senders::UDP

  def initialize(address, port)
    @address = address
    @port = port.to_i
    @socket = UDPSocket.new
  end


  def <<(data)
    @socket.send(data, 0, @address, @port)
  end

end
