extends SpeakTrigger
""" Test of extending SpeakTrigger to display a prompt
	
	"""


var response_given := false
var response := ""


func _ready():
	# NOTE: This override behavior only happens for built in functions
	# it seems. Custom defined functions must be manually called with "."
	# if you want to use the base function (assuming you overrode it).
	# i.e. .my_function()
#	print("Override") # Original is automatically called before the override
	# warning-ignore:return_value_discarded
	Message.connect("prompt_responded", self, "_on_prompt_responded")


func _play_interaction():
	player_body.allow_input = false
	
	if not response_given:
		if Message.display_prompt(text_data["prompt_data"]["test_prompt"]):
			awaiting_response = true
	else:
		var text_data_copy = text_data.duplicate(true)
		var custom_dialogue = text_data_copy["dialogue_data"]["test_responded"]
		
		custom_dialogue[0] = custom_dialogue[0] % response
		
		Message.display_dialogue(custom_dialogue)
		yield(Message, "message_finished")
		player_body.allow_input = true


func _on_prompt_responded(value):
	if awaiting_response:
		awaiting_response = false
		
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
		
		# If you want to use the string insertion (%) to modify dialogue, you must
		# get a deep copy of the dictionary or else you will just rewrite into
		# text data.
		var text_data_copy = text_data.duplicate(true)
		var custom_dialogue = text_data_copy["dialogue_data"]["test_size"]
		
		custom_dialogue[0] = custom_dialogue[0] % [response, "- AniMerrill"]
		
		Message.display_dialogue(custom_dialogue)
		yield(Message, "message_finished")
		response_given = true
		player_body.allow_input = true
