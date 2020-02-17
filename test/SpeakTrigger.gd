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
var text_data = {}
var awaiting_response = false


func _ready():
#	print("Original") # Original is automatically called before the override
	text_data = TextData.get_data(text_data_file, "en")
	
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")


func _input(_event):
	if Input.is_action_just_pressed("ui_accept") and not awaiting_response:
		if player_body is PlayerOverworld:
			_play_interaction(player_body)
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
func _play_interaction(player : PlayerOverworld):
	pass
	
#	# Sample of calling simple dialogue
#	player_body.allow_input = false
#
#	if not Message.display_dialogue(text_data["dialogue_data"]["test_size"]):
#		pass
#	else:
#		yield(Message, "message_finished")
#
#	player.allow_input = true
