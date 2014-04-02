require 'test_helper'

class NginxLogParserTest < MiniTest::Unit::TestCase

  def test_it_prepends_the_default_scheme
    parser.get_stats.split("\n").each { |stat|
      assert_match(/#{Socket.gethostname}.requests.*?\t\d*\t\d*/, stat)
    }
  end


  def test_it_provides_all_stats_as_0_when_no_lines
    parser.get_stats.split("\n").each { |stat|
      assert_match(/requests.*?\t0\t\d*/, stat)
    }
  end


  def test_parsing_lines_calculates_request_stats_request_count
    stats = parser(log_lines).get_stats
    assert_match(/requests.count\t4\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_stats_request_average
    stats = parser(log_lines).get_stats
    assert_match(/requests.average\t0.0545\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_stats_request_min
    stats = parser(log_lines).get_stats
    assert_match(/requests.min\t0.031\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_stats_request_max
    stats = parser(log_lines).get_stats
    assert_match(/requests.max\t0.077\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_upstream_stats_request_average
    stats = parser(log_lines).get_stats
    assert_match(/requests.upstream_average\t0.031\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_upstream_stats_request_min
    stats = parser(log_lines).get_stats
    assert_match(/requests.upstream_min\t0.007\t\d*/, stats)
  end


  def test_parsing_lines_calculates_request_upstream_stats_request_max
    stats = parser(log_lines).get_stats
    assert_match(/requests.upstream_max\t0.067\t\d*/, stats)
  end

  protected

    attr_accessor :scheme

    def parser(log_lines=[])
      @parser ||= Logginator::NginxLogParser.new(scheme).tap { |parser|
        log_lines.each { |line|
          parser.parse_line(line)
        }
      }
    end


    def log_lines
      [
        'ofs-669f584d52824cb388695a1679ca6f34.read.overdrive.com -- 23.125.253.60 - - [13/Mar/2014:19:10:10 +0000] "POST /xhtml/toc.xhtml HTTP/1.1" 200 6599 "https://ofs-669f584d52824cb388695a1679ca6f34.read.overdrive.com/?p=25814" "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53" 0.043 0.042 .',
        'ofs-024919e3f00a07f18d0f43342123bdc0.read.overdrive.com -- 67.243.155.1 - - [13/Mar/2014:19:10:10 +0000] "POST /Text/book.xhtml HTTP/1.1" 200 12064 "https://ofs-024919e3f00a07f18d0f43342123bdc0.read.overdrive.com/?p=725728" "Mozilla/5.0 (Linux; Android 4.2.2; GT-P5210 Build/JDQ39) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.99 Safari/537.36" 0.067 0.067 .',
        'ofs-0a0d83babb622d4bcf5930775a5f2ff8.read.overdrive.com -- 66.161.229.34 - - [13/Mar/2014:19:10:10 +0000] "POST /_d/activity HTTP/1.1" 200 32 "https://ofs-0a0d83babb622d4bcf5930775a5f2ff8.read.overdrive.com/?p=433815" "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36" 0.031 0.007 .',
        'ofs-b164949ae92c2624f3b361d7900fe024.read.overdrive.com -- 173.186.50.68 - - [13/Mar/2014:19:10:10 +0000] "POST /_d/activity HTTP/1.1" 200 32 "https://ofs-b164949ae92c2624f3b361d7900fe024.read.overdrive.com/?p=901702" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36" 0.077 0.008 .'
      ]
    end

end
