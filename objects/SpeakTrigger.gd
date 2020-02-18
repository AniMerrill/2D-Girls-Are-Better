class_name SpeakTrigger
extends Area
""" Base class for objects/NPCs that can be interacted with the 'accept' button.
	
	
	"""


export var text_data_file := "dialogue_test"

# Area captures the PlayerOverworld body into this variable when the body
# enters the area, otherwise this will be set to null. This is how it will
# determine whether or not to do anything when the player presses the accept
# button.
var player_body = null
# If using custom string insertion (%) you must get a deep copy of text_data
# before performing the operation, otherwise you will overwrite the stored
# value.
var text_data = {}
var awaiting_response = false


func _ready():
	# NOTE: This override behavior only happens for built in functions
	# it seems. Custom defined functions must be manually called with "."
	# if you want to use the base function (assuming you overrode it).
	# i.e. .my_function()
#	print("Original") # Original is automatically called before the override
	text_data = TextData.get_data(text_data_file, "en")
	
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")


func _input(_event):
	if Input.is_action_just_pressed("ui_accept") and not awaiting_response:
		if player_body is PlayerOverworld:
			_play_interaction()
		else:
			# Idk if anything is necessary here
			pass


func _on_body_entered(body):
	if body is PlayerOverworld:
		player_body = body


func _on_body_exited(body):
	if body is PlayerOverworld:
		player_body = null


# Intended to be a virtual function that can be overwritten by unique
# interactable objects/NPCs.
# warning-ignore:unused_argument
func _play_interaction():
	pass
	
#	# Sample of calling simple dialogue
#	player_body.allow_input = false
#	
#	if not Message.display_dialogue(text_data["dialogue_data"]["test_size"]):
#		pass
#	else:
#		yield(Message, "message_finished")
#	
#	player_body.allow_input = true

