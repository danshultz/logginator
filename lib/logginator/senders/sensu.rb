require 'json'

class Logginator::Senders::Sensu

  def initialize(address, port=3030, sender=nil)
    @sender ||= Logginator::Senders::UDP.new(address, port)
  end


  def <<(data)
    payload = {
      :handlers => ["metrics"],
      :name => 'unicorn-metrics',
      :status => 0,
      :output => data.to_s,
      :type => 'metric'
    }.to_json

    @sender << payload
  end

end
