class_name JoyputStickData
""" Data container to hold and perfom calculations for JoyputStick
	
	When JoyputStick calls update_input() during the _input() polling for
	Joyput, it stores the left, right, up, and down values collected from the
	input into this data container. These values are then calculated into
	usable data points for game logic. The `value` property is probably the
	most commonly needed output as it can very easily be multiplied by a speed
	variable for velocity, or something to that effect.
	
	TODO: A lot of functionality is missing, and there are certain variables
	and settings that should be done on a device by device basis.
	"""


###########################################################################
# TODO: This, as well as options like invert_y should be on a device by
# device basis.
# TODO: Possibly need to adjust strength to be dependent on the deadzone limits.
### CONFIGURATION VARIABLES ###
# The inner radius of inputs on the joystick which should be ignored
var inner_deadzone := 0.4
# The outer radius of inputs on the joystick which should be ignored
var outer_deadzone := 0.95
# The maximum value that should be allowed for joystick motions. There's
# almost no reason this should be more than 1.0, but there could be situations
# where having it below 1.0 could be a quality of life improvement
var maximum_value := 1.0
###########################################################################

# Direct value of button/motion inputs.
var raw_value := Vector2.ZERO
# Corrected value for w/ angle and deadzones accounted for.
var value := Vector2.ZERO 

# Normalized vector value based only on the angle of input.
var direction := Vector2.ZERO
# Angle based off of raw input.
var angle := 0.0
# Variable strength of input between 0 and the maximum_value (usually 1).
# Digital controls (keys/buttons) will always produce a binary result, while
# analogue controls will give a range between the two. Checking for this allows
# such things as walk speeds, or other things that might depend on specific
# player input.
var strength := 0.0

# Per direction input values
var left := 0.0 # Negative horizontal axis input
var right := 0.0 # Positive horizontal axis input
var up := 0.0 # Negative horizontal axis input
var down := 0.0 # Positive horizontal axis input


# TODO: It might be helpful to have an option where all the values have a
# getter function, and the end user can decide whether to only calculate things
# `on_query` or something. The only thing that would be definitely set are the
# raw left, right, up, down values because those are necessary for accurate
# calculations of the other properties.
func calculate_stick_data():
	# Discard input that falls under the inner deadzone (minimum values).
	if left < inner_deadzone:
		left = 0.0
	if right < inner_deadzone:
		right = 0.0
	if up < inner_deadzone:
		up = 0.0
	if down < inner_deadzone:
		down = 0.0
	
	# Although unlikely under normal circumstances, if the input is over the
	# specified maximum value (by default 1) then clamp it down to that value.
	if left > maximum_value:
		left = maximum_value
	if right > maximum_value:
		right = maximum_value
	if up > maximum_value:
		up = maximum_value
	if down > maximum_value:
		down = maximum_value
	
	# Calculate aggregate vector of axis inputs.
	raw_value = Vector2(right - left, down - up)
	
	# Calculate secondary data.
	angle = raw_value.angle_to(Vector2.RIGHT)
	strength = raw_value.length()
	# TODO: Add option to "invert_y" per device.
	direction = Vector2(cos(angle), -sin(angle))
	
	# For the sake of keeping the values manageable and understandable at run
	# time, negative angles are understood to simply be continuations from the
	# 180 degrees / pi radians point of the rotation. This results in a full
	# rotation potential from 0.0 (facing eastward) turning counter-clockwise,
	# as is standard in the Cartesian coordinate system.
	if angle < 0:
		angle = PI + abs(angle + PI)
	
	# The strength calculation can potentially corrupt values outside of the
	# intended range, but this is also a good time to apply the outer deadzone.
	if strength < inner_deadzone:
		strength = 0.0
	elif strength > outer_deadzone or strength > maximum_value:
		strength = maximum_value
	
	# Finally, this is a clean input value that can easily be used (when
	# multiplied by a speed to get velocity for example) to produce consistent
	# 360 motion using both digital and analogue inputs.
	value = strength * direction

