require 'test_helper'

class VarnishLogParserTest < MiniTest::Unit::TestCase


  def test_parsing_lines_calculates_request_stats_request_count
    stats = parser(log_lines).get_stats
    assert_match(/requests.count\t12\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_max
    stats = parser(log_lines).get_stats
    assert_match(/requests.max\t0.179569244\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_min
    stats = parser(log_lines).get_stats
    assert_match(/requests.min\t0.0015020370000000001\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_min
    stats = parser(log_lines).get_stats
    assert_match(/requests.average\t0.078780000\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_upstream_max
    stats = parser(log_lines).get_stats
    assert_match(/requests.upstream_max\t0.165612936\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_upstream_min
    stats = parser(log_lines).get_stats
    assert_match(/requests.upstream_min\t0.000049353\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_upstream_average
    stats = parser(log_lines).get_stats
    assert_match(/requests.upstream_average\t0.075050000\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_queue_max
    stats = parser(log_lines).get_stats
    assert_match(/requests.queue_max\t0.000055790\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_queue_min
    stats = parser(log_lines).get_stats
    assert_match(/requests.queue_min\t0.000047207\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_queue_average
    stats = parser(log_lines).get_stats
    assert_match(/requests.queue_average\t0.000050000\t\d*/, stats)
  end

  protected

    attr_accessor :scheme

    def parser(log_lines=[])
      @parser ||= Logginator::LogParser::Varnish.new(scheme).tap { |parser|
        log_lines.each { |line|
          parser.parse_line(line)
        }
      }
    end
  def log_lines
    [
      '1 ReqEnd       c 426830160 1396492937.762217283 1396492937.778131962 0.000055075 0.013984680 0.001929998',
      '12 ReqEnd       c 426830158 1396492937.725018024 1396492937.807182074 0.000050783 0.082095385 0.000068665',
      '15 ReqEnd       c 426830159 1396492937.750898123 1396492937.811187744 0.000055790 0.060229301 0.000060320',
      '12 ReqEnd       c 426830161 1396492937.812254667 1396492937.868716717 0.000047207 0.054932594 0.001529455',
      '1 ReqEnd       c 426830163 1396492937.855980396 1396492937.917807579 0.000048161 0.055337906 0.006489277',
      '14 ReqEnd       c 426830165 1396492937.942003727 1396492938.001554251 0.000047207 0.057748079 0.001802444',
      '912 ReqEnd       c 426830165 1396492937.942003727 1396492938.001554251 0.000047207 0.057748079 0.001802444',
      '15 ReqEnd       c 426830162 1396492937.841098070 1396492938.020667315 0.000047445 0.165612936 0.013956308',
      '1335 ReqEnd       c 426830162 1396492937.841098070 1396492938.020667315 0.000047445 0.165612936 0.013956308',
      '12 ReqEnd       c 426830164 1396492937.916075230 1396492938.026303291 0.000047207 0.110175371 0.000052691',
      '14 ReqEnd       c 426830168 1396492938.102068901 1396492938.103570938 0.000054359 0.000049353 0.001452684',
      '12 ReqEnd       c 426830167 1396492938.040535212 1396492938.119291306 0.000049829 0.077115774 0.001640320'
    ]
  end

end
