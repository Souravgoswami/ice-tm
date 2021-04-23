# Frozen_String_Literal: true
require 'ice_tm/baudrate'

module IceTM
	# Errors
	NoDeviceError = Class.new(StandardError)

	# Other Important Constants
	BAUDRATE = IceTM::B57600

	TB = 10 ** 12
	GB = 10 ** 9
	MB = 10 ** 6
	KB = 10 ** 3

	RED = "\e[38;2;225;79;67m"
	BLUE = "\e[38;2;45;125;255m"
	GREEN = "\e[38;2;40;175;95m"
	ORANGE = "\e[38;2;245;155;20m"
	BOLD = "\e[1m"
	RESET = "\e[0m"
end

require 'ice_tm/version'
require 'ice_tm/ice_tm'
