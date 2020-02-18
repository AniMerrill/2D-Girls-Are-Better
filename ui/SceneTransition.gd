extends CanvasLayer
""" Helper class for doing fade and other transitions when changing scenes.
	
	SceneTransition singleton inspired by the work Ereborn did for our project
	Metempsychosis (MIT)!
	https://github.com/AniMerrill/Metempsychosis
	"""


signal transition_completed


func _ready():
	# warning-ignore:return_value_discarded
	$AnimationPlayer.connect(
			"animation_finished", 
			self, 
			"_on_transition_complete"
			)


func fade_in():
	$AnimationPlayer.play("fade")


func fade_out():
	$AnimationPlayer.play_backwards("fade")


func _on_transition_complete(_value):
	emit_signal("transition_completed")
