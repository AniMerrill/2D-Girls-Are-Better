extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _input(event):
	if Input.is_action_pressed("ui_accept"):
		Message.display_dialogue(["[tornado]Hello, World![/tornado]"])
		yield(Message, "message_finished")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
