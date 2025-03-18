extends CSGBox3D

@export var bounce_force:float=100.0

var query:=PhysicsShapeQueryParameters3D.new()

func _ready():
	var shape=BoxShape3D.new()
	shape.size=(size+Vector3(-0.1,0.5,-0.1))
	query.shape=shape
	query.transform=global_transform
	query.collision_mask=collision_mask

func _physics_process(delta):
	var col:=get_world_3d().direct_space_state.intersect_shape(query)
	
	for s in col:
		
		if s.collider is CharacterBody3D:
			if s.collider.velocity.y>0.0:
				s.collider.velocity.y=abs(s.collider.velocity.y*0.125)
			s.collider.velocity.y+=bounce_force
			$GPUParticles3D.emitting=true
