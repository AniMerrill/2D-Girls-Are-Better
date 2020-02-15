extends CanvasLayer


signal message_finished

enum MessageType {DIALOGUE, PROMPT, MENU}

const TOP_Y_POSITION := 0.0
const BOTTOM_Y_POSITION := 310

var message_type : int = MessageType.DIALOGUE

var current_index := 0
var current_messages : PoolStringArray = []

onready var main := $Main
onready var background := $Main/Background
onready var dialogue := $Main/Dialogue


func _ready():
	background.visible = false
	dialogue.visible = false


func _input(event):
	if message_type == MessageType.DIALOGUE:
		if Input.is_action_just_pressed("ui_accept"):
			next_message()


func display_dialogue(messages : PoolStringArray, bottom := true):
	if bottom:
		main.rect_position.y = BOTTOM_Y_POSITION
	else:
		main.rect_position.y = TOP_Y_POSITION
	
	current_index = 0
	current_messages = messages
	
	next_message()


func next_message():
	if current_index >= current_messages.size():
		background.visible = false
		dialogue.visible = false
		
		emit_signal("message_finished")
		return
	
	dialogue.bbcode_text = current_messages[current_index]
	current_index += 1
	
	background.visible = false
	dialogue.visible = false
