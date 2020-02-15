extends CanvasLayer
# Message script/node inspired by the work Ereborn did for our project
# Metempsychosis (MIT)!
# https://github.com/AniMerrill/Metempsychosis


signal message_finished

enum MessageType {DIALOGUE, PROMPT, MENU}

const TOP_Y_POSITION := 0.0
const BOTTOM_Y_POSITION := 310

var message_type : int = MessageType.DIALOGUE

var current_index := 0
var current_messages : PoolStringArray = []

var allow_new_message := true

onready var main := $Main
onready var background := $Main/Background
onready var dialogue := $Main/Dialogue
onready var message_delay := $MessageDelay


func _ready():
	message_delay.connect("timeout", self, "_on_message_delay_timeout")
	
	background.visible = false
	dialogue.visible = false


func _input(event):
	if not current_messages.empty():
		if message_type == MessageType.DIALOGUE:
			if Input.is_action_just_pressed("ui_accept"):
				next_dialogue()


func _on_message_delay_timeout():
	allow_new_message = true


func display_dialogue(messages : PoolStringArray, bottom := true):
	if allow_new_message:
		print("display dialogue")
		
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

