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

        def parse
            while peek_line
                parse_sample
            end
        end

        def parse_sample
            mem = expect_mem
            cpu = expect_cpu
            loadstat = expect_load
            pids = expect_pids

            Sample.new( mem, cpu, loadstat, pids )
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
        def expect_pids
            line = get_line
            pid_fields = line.split(SEP_SPACES)
            if !pid_fields.include?('PID')
                raise "expect PID but got #{line}"
            end

            line = peek_line

            pids = []
            while line and !line.start_with? 'Mem:'
                line = get_line
                values = line.split(SEP_SPACES)
                pid_values = values.slice( 0, pid_fields.length - 1 )
                pid_values.push values.slice( pid_fields.length - 1, values.length - pid_fields.length + 1 ).join(' ')
                if pid_values.length != pid_fields.length 
                    raise "Unmatch field numbers for pid output #{line}"
                end

                pids.push pid_fields.zip(pid_values).to_h
            end
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
