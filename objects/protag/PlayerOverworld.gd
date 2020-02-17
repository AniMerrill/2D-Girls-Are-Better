class_name PlayerOverworld
extends KinematicBody


enum Direction {EAST, NORTH, SOUTH, WEST}

const SPEED := 4.0 # 1.5 seems about appropriate for normal walk anim

export (Direction) var starting_direction : int = Direction.EAST
export var debug_enabled := false setget set_debug_enabled

var velocity := Vector3.ZERO

var rig_facing_angle := 0.0 setget set_rig_facing_angle
var current_anim := "idle" setget set_current_anim
var katana_visible := false setget set_katana_visible

var look_target := Vector3.ZERO
var allow_input := true

var looping_anim_list := [
	"idle", 
	"walk",
	]

onready var rig := $protagkun
onready var anim := $protagkun/AnimationPlayer


func _ready():
	# Because we're just using the gltf resource for the protag mesh, changes
	# made to the AnimationPlayer unfortunately do not save but it is otherwise
	# a useful strategy for making sure we always have an up to date resource
	# without manually having to resave it.
	# This makes it so that upon loading, we can set all the animations we need
	# to loop to do so.
	for animation_name in anim.get_animation_list():
		if looping_anim_list.has(animation_name):
			anim.get_animation(animation_name).loop = true
	
	set_rig_direction(starting_direction)
	
	self.katana_visible = katana_visible
	self.debug_enabled = debug_enabled


func _process(_delta):
	var walking_input : JoyputStickData = Joyput.get_stick("walk")
	var walking_value := walking_input.value * SPEED
	
	velocity = Vector3(walking_value.x, velocity.y, walking_value.y)
	
	var current_velocity = Vector3.ZERO
	
	if allow_input:
		current_velocity = move_and_slide(velocity)
	
	if walking_input.strength > 0 and allow_input:
		if rig_facing_angle != walking_input.angle:
			self.rig_facing_angle = walking_input.angle
		
		if current_velocity.length() > 0.05:
			self.current_anim = "walk"
			anim.playback_speed = current_velocity.length() / 1.5
		else:
			self.current_anim = "idle"
			anim.playback_speed = 1
	else:
		self.current_anim = "idle"
		anim.playback_speed = 1
	
	if debug_enabled:
		show_debug_info(
				"Current Velocity: " + str(current_velocity)
				)


func set_rig_direction(direction := -1):
	match direction:
		Direction.EAST:
			# 0
			self.rig_facing_angle = Vector2(1,0).angle()
		Direction.NORTH:
			# PI / 2
			self.rig_facing_angle = Vector2(0,1).angle()
		Direction.WEST:
			# PI
			self.rig_facing_angle = Vector2(-1,0).angle()
		Direction.SOUTH:
			# 3 * PI / 2
			# The way Godot handles vector angles by default has this being
			# -PI/2 rather than the more logical and slightly easier to work
			# with +3*PI/2. Idk if I'll even get into interpolation crap during
			# this project but I want to prep it just in case.
			var temp_angle = Vector2(0,-1).angle() + 2 * PI
			self.rig_facing_angle = temp_angle


func set_rig_facing_angle(angle : float):
	rig_facing_angle = angle
	rig.rotation.y = rig_facing_angle + PI / 2


func set_current_anim(anim_name : String):
	if anim_name != current_anim:
		current_anim = anim_name
		anim.play(current_anim)


func set_katana_visible(value : bool):
	katana_visible = value
	$protagkun/Armature/Skeleton/Katana.visible = value


func set_debug_enabled(value : bool):
	$DebugInfo/Panel.visible = value
	debug_enabled = value


func show_debug_info(info : String):
	$DebugInfo/Panel/Label.text = info
