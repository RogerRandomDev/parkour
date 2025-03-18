@tool
extends MeshInstance3D

@export_group("Child Dependencies")
@export var liquidShaderMaterial: ShaderMaterial

@export_group("Liquid Simulation")
@export_range (0.0, 1.0, 0.001) var liquid_mobility: float = 0.1 

@export var springConstant = 200
@export var reaction       = 4
@export var dampening      = 3

@onready var pos1 : Vector3 = get_global_transform().origin
@onready var pos2 : Vector3 = pos1
@onready var pos3 : Vector3 = pos2

var vel    : float = 0.0
var accell : Vector2
var coeff : Vector2
var coeff_old : Vector2
var coeff_old_old : Vector2

var cur_height:float=1.0

var tank_size:Vector3

func _ready():
	var parent=get_parent_node_3d()
	get_parent_node_3d().get_parent_node_3d().Attacked.connect(
		hit_handler
	)
	tank_size=parent.mesh.size
	

func _physics_process(delta):
	var accell_3d:Vector3 = (pos3 - 2 * pos2 + pos1) * 3600
	pos1 = pos2
	pos2 = pos3
	pos3 = get_global_transform().origin + rotation
	accell = Vector2(accell_3d.x + accell_3d.y, accell_3d.z + accell_3d.y)
	coeff_old_old = coeff_old
	coeff_old = coeff
	coeff = ((-springConstant * coeff_old - reaction * accell) + 2 * coeff_old - coeff_old_old - delta * dampening * (coeff_old - coeff_old_old) )/ 3600
	liquidShaderMaterial.set_shader_parameter("coeff", coeff*liquid_mobility)
	if (pos1.distance_to(pos3) < 0.01):
		vel = clamp (vel-delta*1.0,0.0,1.0)
	else:
		vel = 1.0
	liquidShaderMaterial.set_shader_parameter("vel", vel)

var cur_tween=null
var target_height:float=1.0
func hit_handler(hit_data):
	var hit_height:float=(
		hit_data.local.y*0.5+0.5
	)

	if hit_height<target_height:
		if cur_tween:cur_tween.stop()
		target_height=hit_height
		var tween:Tween=create_tween()
		var parameter_setter:Callable=get_active_material(0).set_shader_parameter
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_method(func(v):
			parameter_setter.call("fill_amount",v)
			,cur_height,hit_height,sqrt((cur_height-hit_height)*2)*tank_size.x*tank_size.z
			)
		tween.parallel().tween_property(
			self,'cur_height',hit_height,sqrt((cur_height-hit_height)*2)*tank_size.x*tank_size.z
		)
		cur_tween=tween
		#get_active_material(0).set_shader_parameter("fill_amount",cur_height)
	
	
