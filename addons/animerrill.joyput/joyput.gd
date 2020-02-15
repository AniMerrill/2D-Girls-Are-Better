extends Node
""" An input helper class to unify digital and analogue input.
	
	The purpose of this class is to make switching between digital and analogue
	controls painless for game designers and seamless for the end user. It is
	designed specifically for games where full analogue control on a gamepad
	would need to have either the d-pad work similarly or where alternate 
	keyboard controls would be necessary.
	"""


# Enum for device indicator.
# JOYPUT_CURRENT will return the most recently used device, regardless of it's
# actual device index. Could be useful for single player games where it doesn't
# really matter what device is being used, or to determine who is "player one"
# upon game startup, or for a multiplayer lobby when checking for input.
# JOYPUT_KEYS will return keyboard only.
# JOYPUT_0_KEYS will return the Godot default, which groups "device 0" as both
# the keyboard and the first joypad plugged in.
# JOYPUT_0-7 will return only joypad devices.
enum Devices {
	JOYPUT_CURRENT = -3
	JOYPUT_KEYS = -2,
	JOYPUT_0_KEYS = -1,
	JOYPUT_0 = 0,
	JOYPUT_1 = 1,
	JOYPUT_2 = 2,
	JOYPUT_3 = 3,
	JOYPUT_4 = 4,
	JOYPUT_5 = 5,
	JOYPUT_6 = 6,
	JOYPUT_7 = 7,
	}

# How many devices to keep track of, maximum of 8 (per Godot's limitations)
var maximum_devices := 8 setget set_maximum_devices
# TODO: Not sure whether to make this a dictionary or an array of a class
var devices := []

var sticks := []


func _ready():
#	for i in 8:
#		print(i)
	
	pass


func _input(event):
	for stick in sticks:
		stick.update_input(event)


func set_maximum_devices(value : int):
	maximum_devices = value


# JoyputStick._init() expects a unique name for the stick and then the action
# names (i.e. those set in Project Settings->InputMap) for the four axis 
# directions.
func add_stick(
		stick_name : String, 
		left_actions : String, right_actions : String,
		up_actions : String, down_actions : String
		):
	
	var new_stick = JoyputStick.new(
			stick_name,
			left_actions, right_actions,
			up_actions, down_actions
			)
	
	sticks.append(new_stick)


func get_stick(
			stick_name : String, 
			device := Devices.JOYPUT_0_KEYS
			) -> JoyputStickData:
	for stick in sticks:
		if stick.name == stick_name:
			match device:
				Devices.JOYPUT_KEYS:
					return stick.key_data
				Devices.JOYPUT_0:
					return stick.joypad_data
				Devices.JOYPUT_0_KEYS:
					return stick.data
				_:
					print_debug("Joyput is not currently designed for multiple devices, sorry!")
					return null
	
	return null


func remove_stick(stick_name : String):
	for i in sticks.size():
		if sticks[i].name == stick_name:
			sticks.remove(i)
			return

