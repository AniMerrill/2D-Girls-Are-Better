extends CanvasLayer
""" Message display singleton for dialogue, prompts, and menus.
	
	Message script/node inspired by the work Ereborn did for our project
	Metempsychosis (MIT)!
	https://github.com/AniMerrill/Metempsychosis
	"""

signal message_finished

enum MessageType {DIALOGUE, PROMPT, MENU}

const TOP_Y_POSITION := 0.0
const BOTTOM_Y_POSITION := 310

export var dialogue_rate := 20 # Characters per second

var message_type : int = MessageType.DIALOGUE
var current_index := 0
var current_messages : PoolStringArray = []

var current_chars_displayed := 0

var allow_new_message := true
var full_dialogue_shown := false

onready var main := $Main
onready var background := $Main/Background
onready var dialogue := $Main/Dialogue
onready var message_delay := $MessageDelay


func _ready():
	# warning-ignore:return_value_discarded
	message_delay.connect("timeout", self, "_on_message_delay_timeout")
	
	set_process(false)
	
	background.visible = false
	dialogue.visible = false


func _input(_event):
	if not current_messages.empty():
		match message_type:
			MessageType.DIALOGUE:
				if (
						Input.is_action_just_pressed("ui_accept") and 
						full_dialogue_shown
						):
					
					next_dialogue()


func _process(delta):
	if message_type == MessageType.DIALOGUE:
		if dialogue.percent_visible < 1:
			var char_percent = 1.0 / dialogue.text.length()
			
			var current_rate = dialogue_rate
			
			if Input.is_action_pressed("ui_cancel"):
				current_rate *= 2
			
			dialogue.percent_visible += char_percent * current_rate * delta
			
			var chars_displayed : int = dialogue.percent_visible / char_percent
			
			if current_chars_displayed < chars_displayed:
				current_chars_displayed = chars_displayed
				print(current_chars_displayed)
		else:
			full_dialogue_shown = true
			set_process(false)


# Used for a variety of purposes to ignore input for a split second so things
# can properly display. This function specifically is used so that when the last
# message of a dialogue, prompt, or menu is shown then the ability to display
# a new message can be delayed until the player has released the button.
func _on_message_delay_timeout():
	allow_new_message = true


func display_dialogue(messages : PoolStringArray, bottom := true):
	if allow_new_message:
		message_delay.start()
		yield(message_delay, "timeout")
		
		if bottom:
			main.rect_position.y = BOTTOM_Y_POSITION
		else:
			main.rect_position.y = TOP_Y_POSITION
		
		allow_new_message = false
		
		current_index = 0
		current_messages = messages
		
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
		
		emit_signal("message_finished")
		
		message_delay.start()
		return
	
	dialogue.bbcode_text = current_messages[current_index]
	current_index += 1
	
	background.visible = true
	dialogue.visible = true
	
	dialogue.percent_visible = 0
	current_chars_displayed = 0
	full_dialogue_shown = false
	set_process(true)

