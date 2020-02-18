extends CanvasLayer
""" Helper class for doing fade and other transitions when changing scenes.
	
	SceneTransition singleton inspired by the work Ereborn did for our project
	Metempsychosis (MIT)!
	https://github.com/AniMerrill/Metempsychosis
	"""


signal transition_completed(value)

enum TransitionType { FADE_IN, FADE_OUT }

var current_transition : int = TransitionType.FADE_IN


func _ready():
	# warning-ignore:return_value_discarded
	$AnimationPlayer.connect(
			"animation_finished", 
			self, 
			"_on_transition_complete"
			)


func fade_in():
	$AnimationPlayer.play("fade")
	current_transition = TransitionType.FADE_IN


func fade_out():
	$AnimationPlayer.play_backwards("fade")
	current_transition = TransitionType.FADE_OUT


func _on_transition_complete(_value):
	emit_signal("transition_completed", current_transition)
