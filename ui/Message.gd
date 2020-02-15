extends CanvasLayer
""" Message display singleton for dialogue, prompts, and menus.
	
	Message script/node inspired by the work Ereborn did for our project
	Metempsychosis (MIT)!
	https://github.com/AniMerrill/Metempsychosis
	
	Message can handle three kinds of output: Dialogue, Prompt, and Menu. Needs
	to be added to Project Settings as an AutoLoad singleton.
	
	Dialogue is the most basic type output, it is simply text on the screen
	in a box. When display_dialogue() is called, it expects an array of strings.
	If you give it one string in that array, only one box worth of dialogue will
	be shown. If you give multiple, then several dialogue boxes will be shown
	in a row. Dialogue has a display limit of 320 characters, 8 lines w/ 40 
	chars per line.
	
	For best results, display_message should be called as thus:
		Message.display_dialogue(<dialogue array>)
		yield(Message, 'message_finished')
	
	Prompt is an output which then allows the player to pick one of four
	possible options. When display_prompt() is called, it expects a dictionary
	object with 'text' containing a string and 'options' containing an array
	of up to four strings. The text parameter will be used to display a maximum
	of two lines of up to 40 characters long, probably to contextualize the
	choice. The options will then each have a maximum of 15 characters for text.
	
	Example of prompt dictionary:
		{
			'text' : 'Is Godot the best game engine?'
			'options' : ['Yes', 'Double Yes', 'Extra Yes', 'Totally']
		}
	
	For best results, if display prompt is going to be used then you will want
	to connect Message to a function for the signal 'prompt_responded'. It would
	also be good to have a bool flag to switch when the prompt is sent and then
	when the response is handled by your connected function to prevent issues
	with the message system. Here's as good of an example as I can give:
		# In member variables
		var awaiting response = false
		
		# In _ready()
		Message.connect('prompt_responded', self, '_on_prompt_responded')
		
		# Function calling display_prompt
		if Message.display_prompt(<prompt dictionary>):
			awaiting_response = true
		else:
			# Handle non-display here if needed
			pass
		
		# Connected function
		func _on_prompt_responded(value):
			awaiting_response = false
			
			# Handle response value
	
	###########################################
	###### [Menu isn't implemented yet.] ######
	###########################################
	
	Each message display function also has an optional variable for the display
	position (called 'bottom') which is set true by default. If bottom is true,
	then the prompt will be drawn at the bottom half of the screen. If false, 
	then it will be shown on the top half.
	
	Each message display function returns a bool that will be true if the
	message successfully displays or false if it does not.
	"""

#signal message_finished
signal prompt_responded(value)

enum MessageType {DIALOGUE, PROMPT, MENU}

const TOP_Y_POSITION := 0.0
const BOTTOM_Y_POSITION := 310

export var dialogue_rate := 20 # Characters per second

var message_type : int = MessageType.DIALOGUE

var current_index := 0
var current_messages : PoolStringArray = []
var current_options : PoolStringArray = []

var current_chars_displayed := 0

var allow_new_message := true
var full_text_shown := false

onready var main := $Main
onready var message_delay := $MessageDelay
onready var background := $Main/Background

onready var dialogue := $Main/Dialogue

onready var prompt_text := $Main/Prompt/Text
onready var prompt_options := [
	$Main/Prompt/Option0,
	$Main/Prompt/Option1,
	$Main/Prompt/Option2,
	$Main/Prompt/Option3,
	]


func _ready():
	# warning-ignore:return_value_discarded
	message_delay.connect("timeout", self, "_on_message_delay_timeout")
	
	# Connect functions for each of the prompt option buttons
	for i in prompt_options.size():
		prompt_options[i].connect(
				"pressed", 
				self, 
				"_on_prompt_option_pressed", 
				[i]
				)
		
		prompt_options[i].connect(
				"focus_entered",
				self,
				"_on_prompt_option_focus_change",
				[prompt_options[i], true]
				)
		
		prompt_options[i].connect(
				"focus_exited",
				self,
				"_on_prompt_option_focus_change",
				[prompt_options[i], false]
				)
	
	# Make sure the Messages node is invisible.
	disable_all_visibility()


func _input(_event):
	if not current_messages.empty():
		match message_type:
			MessageType.DIALOGUE:
				if (
						Input.is_action_just_pressed("ui_accept") and 
						full_text_shown
						):
					
					next_dialogue()


func _process(delta):
	match message_type:
		MessageType.DIALOGUE:
			full_text_shown = process_text_scroll(dialogue, delta)
			
			if full_text_shown:
				set_process(false)
		MessageType.PROMPT:
			full_text_shown = process_text_scroll(prompt_text, delta)
			
			if full_text_shown:
				set_process(false)
		_:
			pass


# Used for a variety of purposes to ignore input for a split second so things
# can properly display. This function specifically is used so that when the last
# message of a dialogue, prompt, or menu is shown then the ability to display
# a new message can be delayed until the player has released the button.
func _on_message_delay_timeout():
	allow_new_message = true


func _on_prompt_option_pressed(value : int):
	emit_signal("prompt_responded", value)
	allow_new_message = true
	disable_all_visibility()


func _on_prompt_option_focus_change(button : Button, focus : bool):
	if focus:
		if not button.text.begins_with(">"):
			button.text = "> " + button.text
	else:
		if button.text.begins_with(">"):
			var temp = button.text
			
			temp.erase(0, 2)
			
			button.text = temp


func process_text_scroll(label : RichTextLabel, delta : float):
	if label.percent_visible < 1:
		var char_percent = 1.0 / label.text.length()
		
		var current_rate = dialogue_rate
		
		if Input.is_action_pressed("ui_cancel"):
			current_rate *= 2
		
		label.percent_visible += char_percent * current_rate * delta
		
		var chars_displayed : int = label.percent_visible / char_percent
		
		if current_chars_displayed < chars_displayed:
			current_chars_displayed = chars_displayed
			
			# Good place to play dialogue noises
		
		return false
	else:
		return true


func display_dialogue(messages : PoolStringArray, bottom := true) -> bool:
	if allow_new_message:
		message_delay.start()
		yield(message_delay, "timeout")
		
		allow_new_message = false
		message_type = MessageType.DIALOGUE
		
		if bottom:
			main.rect_position.y = BOTTOM_Y_POSITION
		else:
			main.rect_position.y = TOP_Y_POSITION
		
		current_index = 0
		current_messages = messages
		
		background.visible = true
		dialogue.visible = true
		
		next_dialogue()
		
		return true
	else:
		# Can be used to check if message was rejected from whatever source
		# calls the dialogue to display.
		return false


func next_dialogue():
	if current_index >= current_messages.size():
		background.visible = false
		dialogue.visible = false
		
		current_messages = []
		
#		emit_signal("message_finished")
		
		message_delay.start()
		return
	
	dialogue.bbcode_text = current_messages[current_index]
	current_index += 1
	
	dialogue.percent_visible = 0
	current_chars_displayed = 0
	full_text_shown = false
	set_process(true)


func display_prompt(prompt, bottom := true) -> bool:
	if allow_new_message and not prompt["options"].empty():
		message_delay.start()
		yield(message_delay, "timeout")
		
#		allow_new_message = false
		message_type = MessageType.PROMPT
		
		if bottom:
			main.rect_position.y = BOTTOM_Y_POSITION
		else:
			main.rect_position.y = TOP_Y_POSITION
		
		for i in prompt_options.size():
			if i >= prompt["options"].size():
				prompt_options[i].visible = false
			else:
				prompt_options[i].visible = true
				prompt_options[i].text = prompt["options"][i]
		
		prompt_options[0].grab_focus()
		
		background.visible = true
		prompt_text.visible = true
		prompt_text.bbcode_text = prompt["text"]
		
		prompt_text.percent_visible = 0
		current_chars_displayed = 0
		full_text_shown = false
		set_process(true)
		
		return true
	else:
		# Can be used to check if message was rejected from whatever source
		# calls the dialogue to display.
		return false


func disable_all_visibility():
	background.visible = false
	dialogue.visible = false
	
	prompt_text.visible = false
	
	for option in prompt_options:
		option.visible = false
	
	set_process(false)
