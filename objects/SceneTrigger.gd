extends Area


export var scene_path := ""
export var trigger_name := ""
export (PlayerOverworld.Direction) var direction := PlayerOverworld.Direction.EAST

var scene : PackedScene
#var timer : Timer

# TODO: This was only needed for the timer setup where I had the player spawning
# inside an active trigger rather than just a blank one. Might need to remove.
var allow_trigger = true


func _ready():
	scene = load(scene_path)
	
	if scene == null:
		print_debug("Invalid scene path: '" + scene_path + "'")
	else:
		# TODO: Idk if this timer system is needed
#		timer = Timer.new()
#		add_child(timer)
#		timer.connect("timeout", self, "_on_timeout")
#		timer.one_shot = true
#		timer.start(0.1)
		
		# warning-ignore:return_value_discarded
		connect("body_entered", self, "_on_body_entered")
		# warning-ignore:return_value_discarded
		connect("body_exited", self, "_on_body_exited")


#func _on_timeout():
#	allow_trigger = true
#	timer.disconnect("timeout", self, "_on_timeout")
#	timer.queue_free()


func _on_body_entered(body):
	if body is PlayerOverworld:
		if scene == null:
			print_debug("Invalid scene path: '" + scene_path + "'")
		elif allow_trigger:
			var instance_scene = scene.instance()
			
			if instance_scene.has_node("SceneTriggers/" + trigger_name):
				var trigger : Area = instance_scene.get_node(
						"SceneTriggers/" + trigger_name
						)
				
				if instance_scene.has_node("Protag"):
					body.allow_input = false
					
					SceneTransition.fade_out()
					yield(SceneTransition, "transition_completed")
					
					var protag : PlayerOverworld = instance_scene.get_node("Protag")
					
					protag.translation = trigger.translation
					protag.starting_direction = direction
					protag.allow_input = false
					
					get_tree().root.get_node(owner.name).queue_free()
					get_tree().root.add_child(instance_scene)
				else:
					print_debug(
							"Invalid scene! Has no protag node! ",
							scene_path
							)
			else:
				print_debug(
						"Invalid trigger name! ",
						scene_path + " : " + trigger_name
						)


# TODO: Idk if body exited is needed yet
func _on_body_exited(body):
	if body is PlayerOverworld:
		if scene == null:
			print_debug("Invalid scene path: '" + scene_path + "'")
		else:
			allow_trigger = true
