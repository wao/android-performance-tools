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

        def get_line(strip = true)
            if @peek_line
                ret = @peek_line
                @peek_line = nil
            else
                ret = read_line
            end

            if strip
              ret&.strip
            else
              ret
            end
        end

        def read_line
            if @io.eof?
                nil
            else
                @io.readline
            end
        end

        def peek_line(strip=true)
            if @peek_line.nil?
                @peek_line = read_line
            end

            if strip
              @peek_line&.strip
            else
              @peek_line
            end
        end

        def parse(&b)
            while peek_line
                parse_sample(&b)
            end
        end

        def parse_sample(&b)
            expect_tasks
            mem = expect_mem
            expect_swap
            cpu = expect_cpu
            # loadstat = expect_load
            pid_fields = expect_pids
            pids = expect_processes(pid_fields)

            b.call( Sample.new( mem, cpu, nil, pids ) )
        end

        def expect_mem
            expect_hash_with_header( 'Mem', /[:|,]?\s+/ )
        end

        def expect_swap
            expect_hash_with_header( 'Swap', /[:|,]?\s+/ )
        end

        def expect_cpu
            # expect_hash_with_header( 'CPU:', /\s+/ )
            line = get_line

            fields = line.split(/\s+/).inject({}) do |memo, f| 
              a=f.split("%")
              memo[a[1]]=a[0]
              memo
            end

            fields
        end

        def expect_tasks
            expect_hash_with_header( 'Tasks', /[:|,]?\s+/ )
        end

        def expect_load
            line = get_line
            # fields = line.split(/\s+/)

            # if fields[0] != 'Load' and Fields[1] != 'average:'
                # raise "expect Load average: but got '#{line}'"
            # end

            # Load.new( fields[2].to_f, fields[3].to_f, fields[4].to_f )
            [line]
        end

        SEP_SPACES = /\s+/


        def expect_pids
            line = get_line

            parse_pids(line)
        end

        def parse_pids(line)
            line = line.gsub(/(\[|\])/, " ")
            
            pid_fields = line.split(SEP_SPACES)
            if pid_fields[0] != 'PID'
                raise "expect PID but got #{line}"
            end

            pid_fields
        end

        def expect_processes(pid_fields)
            line = peek_line(false)

            pids = []
            while line and !line.start_with? 'Tasks:'
                line = get_line(false)

                if !line.strip.empty?
                  pids.push parse_process(pid_fields, line)
                end

                line = peek_line(false)
            end
            
            # puts pids

            pids
        end

        #                      PID USER         PR  NI VIRT  RES  SHR S[%CPU] %MEM     TIME+ ARGS  
        #                      PID USER PR  NI VIRT RES SHR S[%CPU] %MEM     TIME+ ARGS  
        Pid_field_length = [ 0, 5, 18,  21, 26, 30, 35, 40, 42, 47, 53, 64] #last field COMMAND don't included

        def parse_process(pid_fields, line)
          pid_stat = {}
          1.upto( Pid_field_length.length - 1 ) do |i|
            pid_stat[ pid_fields[ i - 1 ] ] = line.slice( Pid_field_length[ i - 1]...Pid_field_length[ i ] ).strip.lstrip
          end

          command_line = line.slice( Pid_field_length.last, line.length - Pid_field_length.last ).chop

          if command_line.length > 30
            command_line = command_line.slice( 0, 50 )
          end

          pid_stat[ "COMMAND" ] = command_line

          pid_stat
        end


        def expect_hash_with_header(header, sep)
            line = get_line
            fields = line.split(sep)
            if fields.shift != header
                raise "expect #{header} but got '#{line}'"
            end
 
            # puts fields
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
