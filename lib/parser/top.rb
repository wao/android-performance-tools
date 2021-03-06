require 'set'

module Parser
    # Parser busybox top -b output and put it into a list
    class Top
        Load = Struct.new( :one, :five, :fifteen )
        Sample = Struct.new(:mem, :cpu, :load, :pids)

        def initialize(io)
            @io = io
            @peek_line = nil
        end

        def get_line
            if @peek_line
                ret = @peek_line
                @peek_line = nil
            else
                ret = read_line
            end

            ret
        end

        def read_line
            if @io.eof?
                nil
            else
                @io.readline.strip
            end
        end

        def peek_line
            if @peek_line.nil?
                @peek_line = read_line
            end

            @peek_line
        end

        def parse(&b)
            while peek_line
                parse_sample(&b)
            end
        end

        def parse_sample(&b)
            mem = expect_mem
            cpu = expect_cpu
            loadstat = expect_load
            pids = expect_pids

            b.call( Sample.new( mem, cpu, loadstat, pids ) )
        end

        def expect_mem
            expect_hash_with_header( 'Mem', /[:|,]?\s+/ )
        end

        def expect_cpu
            expect_hash_with_header( 'CPU:', /\s+/ )
        end

        def expect_load
            line = get_line
            fields = line.split(/\s+/)

            if fields[0] != 'Load' and Fields[1] != 'average:'
                raise "expect Load average: but got '#{line}'"
            end

            Load.new( fields[2].to_f, fields[3].to_f, fields[4].to_f )
        end

        SEP_SPACES = /\s+/

        #Pid = Struct.new( :pid, :ppid, :user, :stat, :vsz, :vsz_usage, :cpu, :cpu_usage, :command )

        Pid_field_length = [ 0, 5, 11, 21, 25, 31, 36, 40, 44 ] #last field COMMAND don't included

        def expect_pids
            line = get_line
            
            pid_fields = line.split(SEP_SPACES)
            if pid_fields[0] != 'PID'
                raise "expect PID but got #{line}"
            end

            line = peek_line

            pids = []
            while line and !line.start_with? 'Mem:'
                puts line
                line = get_line

                pid_stat = {}
                1.upto( Pid_field_length.length - 1 ) do |i|
                    pid_stat[ pid_fields[ i - 1 ] ] = line.slice( Pid_field_length[ i - 1]...Pid_field_length[ i ] ).strip.lstrip
                end

                command_line = line.slice( Pid_field_length.last, line.length - Pid_field_length.last )
                if command_line.include? "tvos"
                   command_line = ">>/applications/bin/tvos<<"
                end

                if command_line.length > 30
                    command_line = command_line.slice( 0, 50 )
                end

                pid_stat[ "COMMAND" ] = command_line
                 
                pids.push pid_stat
                line = peek_line
            end

            pids
        end
           

        def expect_hash_with_header(header, sep)
            line = get_line
            fields = line.split(sep)
            if fields.shift != header
                raise "expect #{header} but got '#{line}'"
            end
 
            puts fields
            if ( fields.length % 2 ) != 0
                raise "Format error of '#{line}'"
            end

            result = {}
            0.upto( fields.length / 2 - 1 ) do |i|
                result[ fields[i*2 + 1] ] = fields[i*2]
            end

            result
        end
    end
end
