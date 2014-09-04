#!/usr/bin/env ruby
require File.dirname(__FILE__) + "/../test_helper.rb"

require 'parser/top'

class TestParserTop < Test::Unit::TestCase
    def test_peek_and_getline
        sample = <<__DATA__
Mem: 727484K used, 12848K free, 0K shrd, 27448K buff, 195288K cached
CPU:  4.3% usr  6.5% sys  0.0% nic 89.1% idle  0.0% io  0.0% irq  0.0% sirq
Load average: 2.98 2.96 1.78 1/907 3607
__DATA__
        io = StringIO.new sample 

        top = Parser::Top.new(io)

        assertEqual( 'Mem: 727484K used, 12848K free, 0K shrd, 27448K buff, 195288K cached', top.peek_line )
        assertEqual( 'Mem: 727484K used, 12848K free, 0K shrd, 27448K buff, 195288K cached', top.peek_line )
        assertEqual( 'Mem: 727484K used, 12848K free, 0K shrd, 27448K buff, 195288K cached', top.get_line )
        assertEqual( 'CPU:  4.3% usr  6.5% sys  0.0% nic 89.1% idle  0.0% io  0.0% irq  0.0% sirq', top.get_line )
        assertEqual( 'Load average: 2.98 2.96 1.78 1/907 3607', top.peek_line )
        assertEqual( 'Load average: 2.98 2.96 1.78 1/907 3607', top.get_line )
        assertNil top.peek_line
        assertNil top.get_line
    end
end
