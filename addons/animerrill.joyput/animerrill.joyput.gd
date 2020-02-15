tool
extends EditorPlugin
""" Plugin to manage Joyput
	
	Right now all this does is add the Joyput singleton to AutoLoad when
	activated, removes it when the plugin is deactivated.
	"""

func _enter_tree():
	add_autoload_singleton("Joyput", "res://addons/animerrill.joyput/joyput.gd")


func _exit_tree():
	remove_autoload_singleton("Joyput")

