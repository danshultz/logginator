require 'json'

class Logginator::Senders::Sensu

  # Initializes a new sender which utilizes sensu to send data
  #
  # @param [String] address address which to send data
  # @param [Integer] port port which to send data to
  # @option opts [String] :sender optional sender internally
  # @option opts [String] :name name of the check to send to sensu
  # @option opts [Array] :handlers collection of handlers to use
  def initialize(address, port=3030, opts={})
    @sender = opts[:sender] || Logginator::Senders::UDP.new(address, port)
    @opts = opts
  end


  def <<(data)
    payload = {
      :handlers => @opts[:handlers] || ["metrics"],
      :name => @opts[:name] || 'general-metrics',
      :status => 0,
      :output => data.to_s,
      :type => 'metric'
    }.to_json

    @sender << payload
  end

end
