extends Node


onready var audio := $AudioStreamPlayer


func _ready():
	Joyput.add_stick(
			"walk", 
			"ui_left", "ui_right", "ui_up", "ui_down"
			)
	
	# TODO: Have the songs just loaded from scenes where they are relevant.
	audio.stream = load("res://audio/bgm/GJ_ambient.ogg")
	audio.play()


func _input(_event):
	
	pass
