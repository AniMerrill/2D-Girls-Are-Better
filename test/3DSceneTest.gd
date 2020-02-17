extends Spatial


func _ready():
	# TODO: This should eventually be added to a proper game manager object
	# or otherwise done upon game startup so that everywhere that needs it can
	# have access to to advanced stick calculation values.
	Joyput.add_stick(
			"walk", 
			"ui_left", "ui_right", "ui_up", "ui_down"
			)
