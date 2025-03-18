extends WeaponBaseScript
class_name WeaponRangedScript
##the [WeaponBaseScript] for the handling of a ranged weapon

var projectileCast:PhysicsRayQueryParameters3D=PhysicsRayQueryParameters3D.new()

var _timeTillNext:float=0.0

##the maximum range a projectile can be fired
const MAX_PROJECTILE_RANGE:float=100.
var weaponOrigin:Vector3
func _ready():
	super._ready()
	projectileCast.exclude=[_body]
	projectileCast.collision_mask=harmLayer+worldLayer
	weaponOrigin=_root.get_child(0).position

func _physics_process(delta):
	if _timeTillNext>0.:
		_timeTillNext-=delta
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		attack()
		

##triggers the attack action as long as [member weaponStats] is not empty
func attack()->void:
	if _timeTillNext>0.:return
	var weaponStats=_root.weaponStats;
	if not weaponStats.size():return
	
	#consume relevant energy for firing
	var energyNode=_body.get_node("Statistics").getStatistic("Energy")
	if !energyNode||!energyNode.attemptCast(weaponStats.Cost):return
	energyNode.changeBy(-weaponStats.Cost)
	
	_timeTillNext=_root.weaponStats.AttackSpeed
	
	
	
	var calculatedSpread:Array[Vector2]=[]
	#only generate a spread array when needed
	if weaponStats.Projectiles==1:
		calculatedSpread=[Vector2(0,0)]
	else:
		calculatedSpread=generateSpreadArray(
			weaponStats.Projectiles,
			weaponStats.Spread,
			weaponStats.BulletsX
			)
	flashMuzzle()
	fireProjectiles(calculatedSpread)
##creates a muzzle flash at the barrel of the ranged weapon
func flashMuzzle():
	var flash=Sprite3D.new()
	flash.texture=load("res://addons/kenney_particle_pack/magic_03.png")
	flash.pixel_size=0.002
	flash.position.z-=0.5
	add_child(flash)
	var t=flash.create_tween()
	t.tween_interval(0.1)
	t.tween_callback(flash.queue_free)
	
	
	
	
##fires [annotation Projectiles] along the [annotation spreadArray] vectors
func fireProjectiles(spreadArray:Array[Vector2]):
	var from=_body.get_node("CameraArm")
	projectileCast.from=from.global_transform.origin
	var faceDirection:Vector3=from.global_rotation
	for projectileDirection in spreadArray:
		var q=Quaternion.from_euler(faceDirection+Vector3(projectileDirection.x,projectileDirection.y,0.))
		var n=q.get_axis().normalized()
		while !n.is_normalized():n=n.normalized()
		var inDir=Vector3(0,0,MAX_PROJECTILE_RANGE).rotated(n,q.get_angle())
		projectileCast.to=(
			from.global_transform.origin-
			inDir
			)
		
		castProjectile()
		


##runs a check and the relevant proccesses for the projectile path currently held by projectileCast
func castProjectile()->void:
	var col:=get_world_3d().direct_space_state.intersect_ray(projectileCast)
	if col:
		if ProjectSettings.get_setting("graphics/DrawBulletImpacts"):createImpactEffect(col)
		if col.collider.is_in_group("Attackable"):
			applyBulletImpactEntity(col)


##applies a bullet action to any object that is collided with.
##separate from the [annotation applyBulletImpactEntity] so as to allow for different functionality.
func applyBulletImpactGeneric(col)->void:
	if col.collider is RigidBody3D:
		#applies the impulse at the location of collision
		col.collider.apply_impulse(
			col.collider.global_position-col.position,
			projectileCast.from.direction_to(projectileCast.to)*0.1
			)
##applies the action of the bullet impact onto the entity.
##done per-bullet and can be changed per-script as neccessary
func applyBulletImpactEntity(col)->void:
	col.collider.emit_signal("Attacked",
	{
		"Damage":_root.weaponStats.Damage,
		"local":col.position-col.collider.position,
		"hitType":"hitScan",
		})
	#col.collider.get_node("Statistics").getStatistic("Health").changeBy(-_root.weaponStats.Damage)




##creates an effect using data from a space_state intersect query.
##only requires the position, collider, and normal values.
func createImpactEffect(col)->void:
	var s=Sprite3D.new()
	s.texture=load("res://addons/kenney_particle_pack/star_09.png")
	s.pixel_size=0.0005
	s.render_priority=127
	
	col.collider.add_child(s)
	if abs(col.normal.normalized()).distance_squared_to(abs(Vector3.FORWARD))>0.001:
		s.look_at_from_position(Vector3.ZERO,col.normal.normalized(),Vector3.FORWARD)
	s.global_position=col.position+col.normal*0.01
	
	var t=create_tween()
	t.tween_interval(10)
	t.tween_property(s,'transparency',1,0.5)
	t.tween_callback(s.queue_free)


##creates an array with N number of values.
##Each value is a different angle vector for each projectile to follow
func generateSpreadArray(N:int,spreadRange:Vector2,spreadRatio:int)->Array[Vector2]:
	var directionVectors:Array[Vector2]=[]
	var curLeft:int=N
	#used to get the spread per-bullet axis
	#spreadRange is done for total, so this is converting that
	var spreadModifier:Vector2=spreadRange*Vector2(1/float(spreadRatio),1/floor(float(N)/float(spreadRatio)))
	
	
	#loops until 1 vector per bullet is obtained
	while curLeft>0:
		#creates the vector for the bullet
		#it handles x as the remainder so it is always from 0 to spreadRatio-1
		#and y is the floored curLeft over spreadRatio
		var bulletVector:Vector2=Vector2(
			float(curLeft%spreadRatio)*spreadModifier.x-(spreadRange/2.).x,
			floor(float(curLeft)/float(spreadRatio)-0.01)*spreadModifier.y-(spreadRange/2.).y
		)
		directionVectors.push_back(bulletVector)
		curLeft-=1;
	return directionVectors
