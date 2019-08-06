require "test_helper2.rb"
require "parser/top"

class TopTest < Minitest::Test

  def dotest_process( res, line )
    assert_equal res, @top.parse_process(@pids, line)
  end

  def dump_process(line)
    puts @top.parse_process(@pids,line)
  end

  context "Top" do
    context "parse_line" do
      setup do
        @top = Parser::Top.new(nil)
        @pids = @top.parse_pids(       "  PID USER         PR  NI VIRT  RES  SHR S[%CPU] %MEM     TIME+ ARGS                      ".strip)
      end

      should "parse normal line" do
        line = " 2909 audioserver  20   0  55M  16M  13M S 13.3   0.2 1222:18.64 avb_streamhandler_app -v -s pluginias-media_transport-avb_configuration_reference.so --fg setup -t GM3 -p CSM -k ptp.pdelaycount=0 -k ptp.synccount=0 -k debug.loglevel._AAS=3 -k debug.loglevel._AEN=3 -k debug.loglevel._PTP=3 -k debug.loglevel._ACS=3 -k debug.loglevel._TX2=3 -k debug.loglevel._LAB=3 -k debug.loglevel._RXE=4 -k debug.loglevel._SHM=3 -k audio.tstamp.buffer=1 -k debug.loglevel._ASH=3 -k debug.loglevel.TX1=3 -k tspec.vlanprio.low=2 -k tspec.vlanprio.high=2 -n eth0 -k alsa.groupname=audio -k compatibility.audio=d6_1722a -k local.alsa.ringbuffer=9216 -k alsa.smartx.switch=0 -k clockdomain.raw.deviation.unlock=3 -k clockdomain.raw.xtstamp=2 -k clockdomain.raw.xtstamp.threshold=3500 -k alsa.clock.threshold.reset=12000000"
        res = {"PID"=>"2909", "USER"=>"audioserver", "PR"=>"20", "NI"=>"0", "VIRT"=>"55M", "RES"=>"16M", "SHR"=>"13M", "S"=>"S", "%CPU"=>"13.3", "%MEM"=>"0.2", "TIME+"=>"1222:18.64", "COMMAND"=>"avb_streamhandler_app -v -s pluginias-media_transp"}
        dotest_process(res, line)
      end

      should "parse another line" do

      end
    end
  end
end
