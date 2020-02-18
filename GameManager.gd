extends Node


onready var audio := $AudioStreamPlayer


func _ready():
	Joyput.add_stick(
			"walk", 
			"ui_left", "ui_right", "ui_up", "ui_down"
			)
	
	audio.stream = load("res://audio/bgm/GJ_ambient.ogg")
	audio.play()


