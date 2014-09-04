#!/usr/bin/env ruby
require File.dirname(__FILE__) + "/../test_helper.rb"

require 'parser/top'

class TestParserTop < Test::Unit::TestCase
    def setup
        sample = <<__DATA__
Mem: 727484K used, 12848K free, 0K shrd, 27448K buff, 195288K cached
CPU:  4.3% usr  6.5% sys  0.0% nic 89.1% idle  0.0% io  0.0% irq  0.0% sirq
Load average: 2.98 2.96 1.78 1/907 3607
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
        assert_nil top.peek_line
        assert_nil top.get_line
    end

    def test_mem
        mem = nil
        assert_nothing_thrown( mem = top.expect_mem )
        assert_equal "727484K", mem["used"]
        assert_equal "12848K", mem["free"]
        assert_equal "0K", mem["shrd"]
        assert_equal "27448K", mem["buff"]
        assert_equal "195288K", mem["cached"]

    end
end
