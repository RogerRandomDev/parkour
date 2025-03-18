extends Camera3D
class_name PlayerCamera
signal rotation_changed(rotationNew)

@export var mouseSensitivity:float=0.001
@export var joySensitivity:float=1.
@export_range(0,PI) var maxRotUp:float=0.0
@export_range(0,PI) var maxRotDown:float=0.0
@export var invertX:bool=false
@export var invertY:bool=false
@onready var targetOrigin=$"../../CameraTargetOrigin"
func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED


#handles rotation when moving the mouse
func _input(event):
	
	if Input.is_key_label_pressed(KEY_Z):
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode!=Input.MOUSE_MODE_CAPTURED:return
	if event is InputEventMouseMotion:
		
		
		get_parent().rotation.y-=event.relative.x*mouseSensitivity
		get_parent().rotation.x=clamp(
			get_parent().rotation.x-event.relative.y*mouseSensitivity,
			-maxRotUp,
			maxRotDown
		)
		emit_signal('rotation_changed',get_parent().rotation)
func _process(_delta):
	var parent=get_parent()
	var to_move_to=parent.global_position.move_toward(targetOrigin.global_position,_delta*5)
	if to_move_to.is_finite():
		parent.global_position=to_move_to
	
	
	if not Input.get_connected_joypads().size():return
	var relative=Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)*(int(invertY)*2-1),-Input.get_joy_axis(0,JOY_AXIS_TRIGGER_LEFT)*(int(invertX)*2-1))
	if(abs(relative.x)<0.25):relative.x=0.
	if(abs(relative.y)<0.25):relative.y=0.
	get_parent().get_parent().rotateBy(relative*joySensitivity)
	get_parent().rotation.x=clamp(
		get_parent().rotation.x-relative.y*joySensitivity,
		-maxRotUp,
		maxRotDown
	)
#	if(get_parent().get_hit_length()<0.15):get_parent().position.x*=-1

func get_crosshair_pos():
	
	pass
