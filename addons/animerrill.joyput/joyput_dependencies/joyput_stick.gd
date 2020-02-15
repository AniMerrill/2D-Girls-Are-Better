class_name JoyputStick
""" Helper class to track 'joystick' information.
	
	Data container for all input events and values for a 'stick', which includes
	a two dimensional possibility space for input (x,y). Defined by the model of
	a typical joystick with a vertical direction and a horizontal direction,
	i.e. left, right, up, and down. For exotic input devices, this is not a
	problem as you should be able to get the raw values either way. Although it
	is suggested if you veer too far away from the standard input model for
	games, as this is intended to streamline, to probably write whatever unique
	input script you need for your game.
	
	This is mainly intended to make games where switching between
	controllers/keyboard for analogue based movement much easier on the game
	logic level by having this be a separate module
	"""

# Directional indicies for arrays
enum {LEFT, RIGHT, UP, DOWN}
# Indicies for analogue axis arrays, see InputEventJoypadMotion
# InputEventJoypadMotion-> axis (INDEX), axis_value (VALUE)
enum {INDEX, VALUE}

# To get sticks later using get_stick() you will need to give each one a
# unique name upon adding using the add_stick() function (both in the master
# class).
var name : String = ""

# These three arrays hold the relevant InputEvent data to be able to poll for
# them later: keys contains scancode, buttons contains button_index, and
# axes contains the axis index (just "axis" in InputEventJoypadMotion) as well
# as the axis value (usually -/+ 1).
var keys := [null, null, null, null]
var buttons := [null, null, null, null]
var axes := [[null, null], [null, null], [null, null], [null, null]]

# These use the joystick data containers to hold both a unified collection
# of input data as well as separate ones for just keyboard and just joypad.
var data := JoyputStickData.new()
var key_data := JoyputStickData.new()
var joypad_data := JoyputStickData.new()


# _init() expects a unique name for the stick and then the action names
# (i.e. those set in Project Settings->InputMap) for the four axis directions.
func _init(
		stick_name: String,
		_left : String, _right : String, 
		_up : String, _down : String):
	name = stick_name
	
	store_input_events(_left, LEFT)
	store_input_events(_right, RIGHT)
	store_input_events(_up, UP)
	store_input_events(_down, DOWN)


# Will parse out all key events, button events, and motion events for the
# current axis. Please note, it is not necessary to have all three as aliases
# for the same action (i.e. I can think of plenty of games where having the
# d-pad and joystick of a controller do much different things) but the option
# is here for whatever you need.
func store_input_events(action_name : String, direction_index : int):
	for event in InputMap.get_action_list(action_name):
		if event is InputEventKey:
			keys[direction_index] = event.scancode
		elif event is InputEventJoypadButton:
			buttons[direction_index] = event.button_index
		elif event is InputEventJoypadMotion:
			axes[direction_index][INDEX] = event.axis
			axes[direction_index][VALUE] = event.axis_value


# Parses an input event for any data that might be relevant to updating
# the Stick position.
func update_input(event : InputEvent, device := 0):
	if event is InputEventKey:
		check_digital_input(
				event, event.scancode, key_data,
				keys[LEFT], keys[RIGHT], keys[UP], keys[DOWN]
				)
	elif event is InputEventJoypadButton:
		check_digital_input(
				event, event.button_index, joypad_data,
				buttons[LEFT], buttons[RIGHT], buttons[UP], buttons[DOWN]
				)
	elif event is InputEventJoypadMotion:
		check_analogue_input(event)
	
	update_data()


# Checks the input event for any key or button presses, depending on the
# event_index passed (scancode/button_index). If a match is detected, it will
# update the direction value depending on whether the input is currently
# pressed (or, if an event is triggered but is_pressed() is false then that
# means it was released). Digital inputs can only be between 0 and 1.
func check_digital_input(
		event : InputEvent, event_index : int, data_set : JoyputStickData,
		_left : int, _right : int, _up : int, _down : int
		):
	
	match event_index:
		_left:
			if event.is_pressed():
				data.left = 1.0
				data_set.left = 1.0
			else:
				data.left = 0.0
				data_set.left = 0.0
		_right:
			if event.is_pressed():
				data.right = 1.0
				data_set.right = 1.0
			else:
				data.right = 0.0
				data_set.right = 0.0
		_up:
			if event.is_pressed():
				data.up = 1.0
				data_set.up = 1.0
			else:
				data.up = 0.0
				data_set.up = 0.0
		_down:
			if event.is_pressed():
				data.down = 1.0
				data_set.down = 1.0
			else:
				data.down = 0.0
				data_set.down = 0.0


# TODO: Potentially find more efficient way to process this other than for loop
# Checks the input event for matching axis index and the sign of the axis
# value (i.e. -/+) to see if there is a match. If so, then the raw value of
# the axis is stored in the data container.
func check_analogue_input(event : InputEventJoypadMotion):
	for i in axes.size():
		if event.axis == axes[i][INDEX] and sign(event.axis_value) == sign(axes[i][VALUE]):
			match i:
				LEFT:
					data.left = abs(event.axis_value)
					joypad_data.left = abs(event.axis_value)
				RIGHT:
					data.right = event.axis_value
					joypad_data.right = event.axis_value
				UP:
					data.up = abs(event.axis_value)
					joypad_data.up = abs(event.axis_value)
				DOWN:
					data.down = event.axis_value
					joypad_data.down = event.axis_value
			
			return


# Processes all the number crunching of the data containers so they can be
# used ASAP by game logic elsewhere.
func update_data():
	data.calculate_stick_data()
	key_data.calculate_stick_data()
	joypad_data.calculate_stick_data()


