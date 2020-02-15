extends Node2D


var dialogue_data = {}

var awaiting_response := false


# Called when the node enters the scene tree for the first time.
func _ready():
	var text_data = TextData.get_data("dialogue_test", "en")
	
	if text_data != null:
		dialogue_data = text_data["dialogue_data"]
	
	# warning-ignore:return_value_discarded
	Message.connect("prompt_responded", self, "_on_prompt_responded")


func _input(_event):
	if Input.is_action_just_pressed("ui_accept") and not awaiting_response:
		if Message.display_prompt(
				{
					"text" : "Hello World",
					"options" : ["Yes", "No", "Maybe", "So"]
					}
				):
			awaiting_response = true
		else:
			# Handle non-display here if needed
			pass

func _on_prompt_responded(value):
	awaiting_response = false
	
	var custom_dialogue = dialogue_data["test_size"]
	
	custom_dialogue[0] = custom_dialogue[0] % str(value)
	
	Message.display_dialogue(custom_dialogue)
	yield(Message, "message_finished")

