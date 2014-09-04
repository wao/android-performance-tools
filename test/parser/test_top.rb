#!/usr/bin/env ruby
require File.dirname(__FILE__) + "/../test_helper.rb"

require 'parser/top'

class TestParserTop < Test::Unit::TestCase
    def setup
        sample = <<__DATA__
Mem: 727484K used, 12848K free, 0K shrd, 27448K buff, 195288K cached
CPU:  4.3% usr  6.5% sys  0.0% nic 89.1% idle  0.0% io  0.0% irq  0.0% sirq
Load average: 2.98 2.96 1.78 1/907 3607
  PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
 1120  1106 0        S    1265m175.0   0  2.7 /applications/bin/tvos
 1099     1 1013     S     279m 38.6   0  2.7 {OPEN} /system/bin/mediaserver
 1096     1 1000     S     154m 21.3   0  2.7 {Binder_2} /system/bin/surfaceflinger
 1148     1 0        S     2660  0.3   3  1.3 /system/bin/logcat -b system -b events -b main -b radio -K -n 20 -r 5000 -v threadtime -f /data/Logs/Log.0/logcat.log
__DATA__
        @io = StringIO.new sample 
    end

    def test_peek_and_getline

        top = Parser::Top.new(@io)

        assert_equal( 'Mem: 727484K used, 12848K free, 0K shrd, 27448K buff, 195288K cached', top.peek_line )
        assert_equal( 'Mem: 727484K used, 12848K free, 0K shrd, 27448K buff, 195288K cached', top.peek_line )
        assert_equal( 'Mem: 727484K used, 12848K free, 0K shrd, 27448K buff, 195288K cached', top.get_line )
        assert_equal( 'CPU:  4.3% usr  6.5% sys  0.0% nic 89.1% idle  0.0% io  0.0% irq  0.0% sirq', top.get_line )
        assert_equal( 'Load average: 2.98 2.96 1.78 1/907 3607', top.peek_line )
        assert_equal( 'Load average: 2.98 2.96 1.78 1/907 3607', top.get_line )
        top.get_line
        top.get_line
        top.get_line
        top.get_line
        top.get_line
        assert_nil top.peek_line
        assert_nil top.get_line
    end

    def test_mem
        mem = nil
        top = Parser::Top.new(@io)
        assert_nothing_thrown do
            mem = top.expect_mem
        end
        assert_equal "727484K", mem["used"]
        assert_equal "12848K", mem["free"]
        assert_equal "0K", mem["shrd"]
        assert_equal "27448K", mem["buff"]
        assert_equal "195288K", mem["cached"]

        cpu = nil
        assert_nothing_thrown do
            cpu = top.expect_cpu
        end

        assert_equal "4.3%", cpu["usr"]
    end
end
