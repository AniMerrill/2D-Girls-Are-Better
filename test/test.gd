extends Node2D


var dialogue_data = {}
var prompt_data = {}

var awaiting_response := false


# Called when the node enters the scene tree for the first time.
func _ready():
	var text_data = TextData.get_data("dialogue_test", "en")
	
	if text_data != null:
		dialogue_data = text_data["dialogue_data"]
		prompt_data = text_data["prompt_data"]
	
	# warning-ignore:return_value_discarded
	Message.connect("prompt_responded", self, "_on_prompt_responded")


func _input(_event):
	if Input.is_action_just_pressed("ui_accept") and not awaiting_response:
#		if not Message.display_dialogue(dialogue_data["test_size"]):
#			pass
		
		
		if Message.display_prompt(prompt_data["test_prompt"], false):
			awaiting_response = true
		else:
			# Handle non-display here if needed
			pass


func _on_prompt_responded(value):
	awaiting_response = false
	
	var response = ""
	
	match value:
		0:
			response = "Yes"
		1:
			response = "Double Yes"
		2:
			response = "Extra Yes"
		3:
			response = "Totally"
		_:
			response = "ERROR"
	
	var custom_dialogue = dialogue_data["test_size"]
	
	custom_dialogue[0] = custom_dialogue[0] % [response, "- AniMerrill"]
	
	Message.display_dialogue(custom_dialogue)

