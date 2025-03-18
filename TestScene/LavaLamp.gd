@tool
extends Marker3D
const lavaCol=preload("res://TestScene/lavapan.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time:float=0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time+=delta
	$OmniLight3D.light_color=lavaCol.gradient.sample(fmod(floor(time*8)*0.00875,1.0))
	$Lava.material_override.set_shader_parameter("curTime",floor(time*8)*0.0875)
