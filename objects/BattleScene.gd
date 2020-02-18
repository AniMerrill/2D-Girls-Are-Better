class_name BattleScene
extends Spatial
""" Intended to be kind of a base class for all battle scenes
	
	"""


signal battle_resolved(value)

enum Resolutions { WIN, LOSE, RUN }

export var text_data_file := "battle"

var text_data := {}

onready var main_camera : Camera = $MainCamera


func _ready():
	text_data = TextData.get_data(text_data_file, "en")
	
	# warning-ignore:return_value_discarded
	SceneTransition.connect(
			"transition_completed", 
			self, 
			"_on_transition_complete"
			)
	
	SceneTransition.fade_in()


func _on_transition_complete(value):
	match value:
		SceneTransition.TransitionType.FADE_IN:
#			print("Battle Scene Ready!")
			pass
			
			resolve_battle(Resolutions.WIN)


func resolve_battle(resolution : int):
	Message.display_dialogue(text_data["dialogue_data"]["test_dialogue"])
	yield(Message, "message_finished")
	
	SceneTransition.fade_out()
	yield(SceneTransition, "transition_completed")
	
	emit_signal("battle_resolved", resolution)
	queue_free()
	
