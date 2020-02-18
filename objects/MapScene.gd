class_name MapScene
extends Spatial
""" Intended to be kind of a base class for all 3d map scenes
	
	"""


export var background_music : AudioStream

onready var protag : PlayerOverworld = $Protag


func _ready():
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
			protag.allow_input = true
