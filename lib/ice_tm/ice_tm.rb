
#!/usr/bin/ruby -w
# Frozen_String_Literal: true

require 'fcntl'
require 'linux_stat'

module IceTM
	# Detect device
	def find_device
		dev = nil

		Dir.glob('/sys/bus/usb/devices/*').each { |x|
			v = File.join(x, 'idVendor')
			vendor = IO.read(v).strip if File.readable?(v)

			p = File.join(x, 'idProduct')
			product = IO.read(p).strip if File.readable?(p)

			if vendor == '1a86' && product == '7523'
				puts "#{BOLD}#{GREEN}:: #{Time.now.strftime('%H:%M:%S.%2N')}: A potential device discovered: #{vendor}:#{product}#{RESET}"

				Dir.glob('/dev/ttyUSB[0-9]*').each { |x|
					if File.writable?(x)
						puts "#{IceTM::BOLD}#{IceTM::BLUE}:: #{Time.now.strftime('%H:%M:%S.%2N')}: Changing `baudrate` to 57600...#{IceTM::RESET}"

						if IceTM.set_baudrate(x, IceTM::BAUDRATE)
							puts "#{IceTM::BOLD}#{IceTM::BLUE}:: #{Time.now.strftime('%H:%M:%S.%2N')}: Changing baudrate to 57600...#{IceTM::RESET}"
						else
							puts "#{IceTM::BOLD}#{IceTM::RED}:: #{Time.now.strftime('%H:%M:%S.%2N')}: Cannot change the baudrate#{IceTM::RESET}"
						end

					else
						"#{BOLD}#{RED}:: #{Time.now.strftime('%H:%M:%S.%2N')}: No permission granted to change Baudrate#{RESET}"
					end

					if File.readable?(x)
						1000.times {
							if File.open(x).gets.to_s.scrub.strip.include?("IceTM")
								puts "#{BOLD}#{ORANGE}:: #{Time.now.strftime('%H:%M:%S.%2N')}: Multiple Ice Task "\
								"Manager Hardware Found! "\
								"Selecting: #{vendor}:#{product}#{RESET}" if dev

								dev = x
								break
							end
						}
					end
				}
			end
		}

		dev
	end

	# Convert Numeric bytes to the format that ice-taskmanager can read
	def convert_bytes(n)
		if n >= TB
			"%06.2f".%(n.fdiv(TB)).split('.').join + ?4
		elsif n >= GB
			"%06.2f".%(n.fdiv(GB)).split('.').join + ?3
		elsif n >= MB
			"%06.2f".%(n.fdiv(MB)).split('.').join + ?2
		elsif n >= KB
			"%06.2f".%(n.fdiv(KB)).split('.').join + ?1
		else
			"%06.2f".%(n).split('.').join + ?0
		end
	end

	# Convert percentages to the format that ice-taskmanager can read
	def convert_percent(n)
		"%06.2f".%(n).split('.').join
	end

	def start(device)
		return false if(!device)

		cpu_u = mem_u = swap_u = iostat = net_upload = net_download = 0

		Thread.new {
			cpu_u = LS::CPU.total_usage(0.25).to_f while true
		}

		Thread.new {
			while true
				netstat = LS::Net::current_usage(0.25)
				net_upload = netstat[:transmitted].to_i
				net_download = netstat[:received].to_i
			end
		}

		begin
			in_sync = false
			fd = IO.sysopen(device, Fcntl::O_RDWR | Fcntl::O_EXCL)
			file = IO.open(fd)

			until in_sync
				file.syswrite(?! * 1000)
				STDOUT.flush

				begin
					if file.readpartial(8000).include?(?~)
						in_sync = true
						break
					end
				rescue EOFError
					sleep 0.05
					retry
				end

				sleep 0.05
			end

			puts "#{IceTM::BOLD}#{IceTM::GREEN}:: #{Time.now.strftime('%H:%M:%S.%2N')}: Device ready!#{IceTM::RESET}"

			while true
				# cpu(01234) memUsed(999993) swapUsed(999992) io_active(0)
				# netUpload(999991) netDownload(999990)
				# disktotal(999990) diskused(999990)

				memstat = LS::Memory.stat
				mem_t = convert_bytes(memstat[:total].to_i.*(1000))
				mem_u = convert_bytes(memstat[:used].to_i.*(1000))
				mem_percent = convert_percent(memstat[:used].to_i.*(100).fdiv(memstat[:total].to_i))

				swapstat = LS::Swap.stat
				swap_u = convert_bytes(swapstat[:used].to_i.*(1000))
				swap_percent = convert_percent(swapstat[:used].to_i.*(100).fdiv(swapstat[:total].to_i))

				diskstat = LS::Filesystem.stat
				disk_total = convert_bytes(diskstat[:total])
				disk_used = convert_bytes(diskstat[:used])
				_diskavail = LS::Filesystem.available
				disk_avail = convert_bytes(_diskavail)

				disk_used_percent = convert_percent(diskstat[:used].*(100).fdiv(diskstat[:total]))
				disk_avail_percent = convert_percent(_diskavail.*(100).fdiv(diskstat[:total]))

				total_process = ps_r = ps_sl = ps_i = ps_t = ps_z = 0

				# Get process count
				process_types = LS::Process.types

				total_process = 0
				process_types.values.each { |x|
					ps_r += 1 if x == :running
					ps_sl += 1 if x == :sleeping
					ps_i += 1 if x == :idle
					ps_t += 1 if x == :stopped
					ps_z += 1 if x == :zombie

					total_process += 1
				}

				# Output has to be exactly this long. If not, ice-taskmanager shows invalid result.
				# No string is split inside ice-task manager, it just depends on the string length.
				#
				# cpu(01234) memUsed(999993) swapUsed(999992) io_active(0)
				# netUpload(999991) netDownload(999990)
				# disktotal(999990) diskused(999990) diskAvail(999990) totalProcess(12345678)
				# memPercent(01234) swapPercent(01234) diskPercent(01234) diskAvailPercent(01234)
				# psR(65536) psS(65536) psI(65536) psT(65536) psZ(65536)

				# Array for better debugging
				# a = [
				# 	convert_percent(cpu_u),
				# 	mem_u, swap_u, iostat(),
				# 	convert_bytes(net_upload), convert_bytes(net_download),
				# 	disk_total, disk_used, disk_avail,
				# 	"%08d" % total_process,
				# 	mem_percent, swap_percent, disk_used_percent, disk_avail_percent,
				# 	"%05d" % ps_r, "%05d" % ps_sl, "%05d" % ps_i, "%05d" % ps_t, "%05d" % ps_z
				# ]

				str = "#{convert_percent(cpu_u)}#{mem_u}#{swap_u}#{iostat()}"\
				"#{convert_bytes(net_upload)}#{convert_bytes(net_download)}"\
				"#{disk_total}#{disk_used}#{disk_avail}#{"%08d" % total_process}"\
				"#{mem_percent}#{swap_percent}#{disk_used_percent}#{disk_avail_percent}"\
				"#{"%05d" % ps_r}#{"%05d" % ps_sl}#{"%05d" % ps_i}#{"%05d" % ps_t}#{"%05d" % ps_z}"

				file.syswrite('!')
				STDOUT.flush
				sleep 0.0125
				file.syswrite(str)
				STDOUT.flush
				sleep 0.0125
				file.syswrite('~')
				STDOUT.flush

				sleep 0.25
			end
		rescue Interrupt, SystemExit, SignalException
			file &.close
			exit 0
		rescue Errno::ENOENT, IceTM::NoDeviceError
			device = find_device

			unless device
				puts "#{IceTM::BOLD}#{IceTM::RED}:: #{Time.now.strftime('%H:%M:%S.%2N')}: Error establishing connection. Don't worry if this is a valid device. Retrying...#{IceTM::RESET}"
				sleep 0.1
			end

			retry
		rescue Exception
			puts $!.full_message
			file &.close
			sleep 0.1
			retry
		end
	end

	def iostat
		@@root_partition ||= IO.foreach('/proc/mounts').detect {
			|x| x.split[1] == ?/
		}.to_s.split[0].to_s.split(?/).to_a[-1]

		iostat = IO.foreach('/proc/diskstats'.freeze).find { |x|
			x.split[2] == @@root_partition
		} &.split.to_a[11]
	end

	extend(self)
end
