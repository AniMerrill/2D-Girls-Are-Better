extends Area
""" This is for overworld enemies who, upon collision, trigger a battle.
	
	TODO: I'm not sure if I'm going to go the Paper Mario and Earthbound route
	of having overworld enemies or the old Final Fantasy random encounter route
	yet, this is just a test of trying to get random battles to work.
	"""


export (String, FILE) var scene_path := ""

var scene : PackedScene
var timer : Timer
var allow_trigger := false

onready var current_scene : MapScene = get_tree().root.get_node(owner.name)


func _ready():
	scene = load(scene_path)
	
	# This timer prevents the trigger from being active for the first split
	# second upon the scene loading. This can prevent triggering from occuring
	# if the player returns right on top of the trigger.
	timer = Timer.new()
	add_child(timer)
	# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "_on_timeout")
	timer.one_shot = true
	timer.start(0.1)
	
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")


func _on_timeout():
	allow_trigger = true
	timer.disconnect("timeout", self, "_on_timeout")
	timer.queue_free()


func _on_body_entered(body):
	if body is PlayerOverworld:
		if scene == null:
			print_debug("Invalid scene path: '" + scene_path + "'")
		else:
			var scene_instance : BattleScene = scene.instance()
			
			current_scene.protag.allow_input = false
			
			SceneTransition.fade_out()
			yield(SceneTransition, "transition_completed")
			
			current_scene.visible = false
			current_scene.protag.get_node("Camera").current = false
			
			get_tree().root.add_child(scene_instance)
			
			scene_instance.main_camera.current = true
			
			# warning-ignore:return_value_discarded
			scene_instance.connect(
					"battle_resolved", 
					self, 
					"_on_battle_resolved"
					)


# TODO: Idk if body exit will be used yet.
func _on_body_exited(body):
	if body is PlayerOverworld:
		allow_trigger = true


func _on_battle_resolved(resolution : int):
	match resolution:
		BattleScene.Resolutions.WIN:
			battle_won_event()
		BattleScene.Resolutions.LOSE:
			battle_lose_event()
		BattleScene.Resolutions.RUN:
			battle_run_event()


# Virtual functions intended to be overwritten based on specific needs
func battle_won_event():
	# Example of coming back to current scene and removing the enemy trigger
	# Probably typical for normal enemy encounters that don't have story
	# or interaction attached.
	visible = false
	
	current_scene.visible = true
	current_scene.protag.get_node("Camera").current = true
	
	SceneTransition.fade_in()
	yield(SceneTransition, "transition_completed")
	
	current_scene.protag.allow_input = true
	
	queue_free()
	pass


func battle_lose_event():
	# Insert game over event
	pass


func battle_run_event():
	# Similar to battle won, but the enemy persists and after a short period
	# will resume normal behavior of trying to chase player
	pass
