@tool
extends CharacterBody3D
class_name CharacterNode

signal attacked(attack_data)

var GRAVITY:Vector3

var floor_checker:=PhysicsRayQueryParameters3D.new()

@onready var _state_chart:StateChart = $StateChart

@export var MASS:float=1.
@export var SPEED:float=1.
@export var DAMPING:float=1.
@export var accelSpeed:float=0.5
@export var decelSpeed:float=60.0
@export var airDecelSpeed:float=100.0
@export var amplifiedDecelInMotion:float=2.0
@export_range(0,1) var rotationDamping:float=0.125;
@onready var abilityOrigin:Node=$Model/AbilityOrigin
@onready var gun_attachment_point=$Model/testingCharacter/Armature/Skeleton3D/BoneAttachment3D

var facing_direction:Vector3

var stateManager:Node;

var anim_data:Dictionary={}

var attempting_slide:bool=false

func _ready()->void:
	GRAVITY=Vector3(0,-64,0)
	floor_checker.exclude=[self]
	initializeStructure()
	#prime the state expressions
	_state_chart.set_expression_property("current_speed",velocity.length())
	
var rotate:float=0.
var moveTowards:Vector3=Vector3.ZERO
var on_floor=false

var ignore_floor_velocity_mod:bool=false

func is_on_floor():
	return is_on_floor()

func _physics_process(delta):
	if Engine.is_editor_hint():return
	RenderingServer.global_shader_parameter_set("character_position",position)
	
	
	
	_state_chart.set_expression_property("current_speed",get_real_velocity().length())
	_state_chart.set_expression_property("grounded_since_last_jump",grounded_since_last_jump)
	move_and_slide()
	rotation.y=rotate
	velocity.y+=GRAVITY.y*delta
	
	
	
	
	#whether you are on the floor or not
	if is_on_floor():
		_state_chart.send_event("grounded")
		#decelerate on floor
		if !ignore_floor_velocity_mod:
			if velocity.y<0:velocity.y=0
			velocity-=velocity*delta*decelSpeed*Vector3(1,0,1)
		
		if (velocity).length_squared()<2:
			_state_chart.send_event("idle")
		else:
			_state_chart.send_event("moving")
			
		
	else:
		#this check is to ensure if you are capable
		#of sliding at the given time
		var col=null
		#done to make sure you are on a VALID slope to slide
		floor_checker.from=global_position-Vector3(0,1,0)
		if is_on_wall():
			floor_checker.to=-get_wall_normal()+global_position-Vector3(0,1,0)
			col=get_world_3d().direct_space_state.intersect_ray(floor_checker)
		#send the event to change
		var dot_col_prod=null
		if col:
			dot_col_prod=Vector3.UP.dot(col.normal)
		if dot_col_prod!=null&&dot_col_prod<0.75&&dot_col_prod>0.125:
			
			_state_chart.send_event("sliding")
		else:
			if !$CloseEnoughToGround.is_colliding():
				_state_chart.send_event("airborne")
	#trigger sliding
	

#needs to be made into its own node/resource to allow swapping
#what handles the triggers more easily

func _input(event):
	if Input.is_action_just_pressed("TriggerAbility"):get_node("Abilities").emit_signal("AbilityTriggered",0)
	if Input.is_action_just_pressed("TriggerAbilitySecondary"):get_node("Abilities").emit_signal("AbilityTriggered",1)
	if Input.is_action_just_pressed("TriggerAbilityMotion"):get_node("Abilities").emit_signal("AbilityTriggered",2)
	#if Input.is_action_just_released("TriggerAbility"):get_node("Abilities").releaseAbility(0)
	#if Input.is_action_just_released("TriggerAbilitySecondary"):get_node("Abilities").releaseAbility(1)
	#if Input.is_action_just_released("TriggerAbilityMotion"):get_node("Abilities").releaseAbility(2)


#handles updating velocity when rotating
func rotateBy(rot:Vector2):
	rotate+=rot.x
	velocity=velocity*rotationDamping+velocity.rotated(Vector3.UP,rot.x)*(1-rotationDamping)


func moveTo(moveBy:Vector3):
	moveTowards=moveBy-global_transform.origin;
	global_transform.origin=moveBy



#functions below here are used in editor for making character creation easier

#creates base node structure for the character
func initializeStructure()->void:
	if !Engine.is_editor_hint():return;
	appendToScene(AbilityManagerNode.new(),"Abilities");

#appends given node to scene tree at the given parent node
func appendToScene(node:Node,nodeName:String,nodeParent:Node=self):
	if !nodeParent||nodeParent.get_node_or_null(nodeName):return;
	node.name=nodeName;
	nodeParent.add_child(node);
	node.set_owner(get_tree().get_edited_scene_root())
	return node;


##returns the look direction of the character currently
func getFaceDirection()->Vector3:
	return facing_direction


func _on_player_camera_rotation_changed(rotationNew):
	facing_direction=rotationNew
	
	$WeaponModelManager.updateRotations(rotationNew)


func getCamera()->Camera3D:
	return $CameraArm/PlayerCamera


func update_model_rotation(dir:Vector3)->void:
	if dir.is_equal_approx(Vector3.ZERO):return
	
	$Model.look_at(dir+global_position)

#rotates the input vector by the current rotation basis of the root node
func applyFacingDirection(inputVector:Vector2)->Vector3:
	var direction=(Basis.from_euler(facing_direction) * Vector3(inputVector.y,0,inputVector.x)).normalized()*inputVector.length()
	return direction



func _on_jump_enabled_state_physics_process(delta):
	grounded_since_last_jump=true
	if Input.is_action_just_pressed("jump"):
		velocity.y = -GRAVITY.y*0.275
		_state_chart.send_event("jump")

func _on_movement_enabled_state_physics_process(delta):
	var baseInput=Vector2(
		Input.get_axis("forward","backward"),
		Input.get_axis("left","right")
	)
	var dir=(applyFacingDirection(baseInput)*Vector3(1,0,1)).normalized()
	if !is_on_floor():
		velocity+=dir*delta*(accelSpeed-airDecelSpeed)
		dir=(velocity*Vector3(1,0,1)).normalized()
		update_model_rotation(dir)
	else:
		velocity+=dir*delta*accelSpeed*(1+0.25*int(Input.is_action_pressed("TriggerAbilityMotion")))
		update_model_rotation(dir)
	if Input.is_action_pressed("slide")&&velocity.length()>4.0&&is_on_floor():
			velocity*=1.5
			_state_chart.send_event("slide_grounded")
			

var grounded_since_last_jump:bool=true

func _on_sliding_enabled_state_physics_process(delta):
	
	_state_chart.send_event("sliding")
	if !(is_on_wall()||is_on_floor()):
		_state_chart.send_event("force_airborne")
		return
	#set normal to either wall or floor, depending on which is available
	var active_normal=get_floor_normal()
	if active_normal==Vector3.ZERO:active_normal=get_wall_normal()
	
	
	
	var dir=Quaternion(Vector3.UP,active_normal)
	
	var direction=(Vector3(1,0,1)*velocity).normalized()
	#look towards the target normal
	if active_normal.y!=1.0:
		$Model.look_at(active_normal+$Model.global_position)
	else:
		if direction!=Vector3.ZERO:
			$Model.look_at(direction+$Model.global_position)
			$Model.rotation.x=PI/2
	#still need the slide to face the motion direction
	#if is_on_floor():
		#var v=get_real_velocity()
		#var q=Quaternion(v.normalized(),Vector3.DOWN)
		#$Model.rotation=q.get_euler()

	
	
	var binormal=Vector3.UP
	if active_normal.y!=1:
		var normal=active_normal
		# Calculate a vector perpendicular to both the normal and gravity direction
		var tangent = Vector3.DOWN.cross(normal).normalized()

		# Calculate the downward direction by taking the cross product with the normal
		binormal = normal.cross(tangent).normalized()
		
		
		var speed_to_mod_by=sliding_velocity
		# If not moving towards the slope, update the velocity
		if (get_real_velocity().y<0.0||get_real_velocity().length()<1.0)&&abs(binormal.y)>0.1:
			velocity = speed_to_mod_by * (motion_direction_sliding+binormal*Vector3(0,1,0))
			if velocity.y>0:velocity*=-1
			sliding_velocity+=GRAVITY.y*delta*(2.5-5*(PI-binormal.dot(Vector3.UP))/PI)
			motion_direction_sliding=motion_direction_sliding.move_toward(binormal,delta*30.0)
		else:
			velocity=abs(speed_to_mod_by)*motion_direction_sliding
		sliding_velocity-=delta*sliding_velocity*5.0
	else:
		velocity=sliding_velocity*motion_direction_sliding
		sliding_velocity-=delta*sliding_velocity*4.0
	#sliding jump
	if Input.is_action_just_pressed("jump"):
		#used for getting direction you are moving relative to the jump direction
		var baseInput=Vector2(
			Input.get_axis("forward","backward"),
			Input.get_axis("left","right")
		).normalized()
		if baseInput!=Vector2.ZERO:
			var dir_input=(applyFacingDirection(baseInput)*Vector3(1,0,1)).normalized()
			var dot_val=dir_input.dot(get_real_velocity()*Vector3(1,0,1))

			#if you are moving in the opposite direction of the sliding, remove most of the forward jump momentum
			if dot_val<0.0:
				
				dir=Quaternion(Vector3.UP,Vector3.UP).normalized()
				motion_direction_sliding*=0.2
				

		velocity = (dir.normalized()*Vector3.UP+motion_direction_sliding*Vector3(1,0,1)).normalized()*max(min(sliding_velocity,40),20)
		velocity.y=max(velocity.y,-GRAVITY.y*0.25)
		
		grounded_since_last_jump=false
		
		_state_chart.send_event("jump")



func _on_walljump_enabled_state_physics_process(delta)->void:
	if not Input.is_action_just_pressed("jump"):return
	if not is_on_wall():return
	var normal=get_wall_normal()
	var  y_rot:float=Input.get_axis("right","left")*PI*0.5+max(Input.get_axis("forward","backward")*PI,0.0)
	y_rot+=$CameraArm.rotation.y
	
	var motion_velocity=normal+Vector3(sin(y_rot),-2.5,cos(y_rot))
	var bounced_velocity=motion_velocity.reflect(normal)
	velocity.y=min(max(bounced_velocity.y*10,-30),velocity.y)
	velocity+=bounced_velocity*10
	
	
	var jumpingParticles=$JumpParticles.duplicate()
	get_parent_node_3d().add_child(jumpingParticles)
	jumpingParticles.global_position=$JumpParticles.global_position
	jumpingParticles.emitting=true
	var wall_normal=get_wall_normal()
	#align particles with the direction of the face you jumped off of
	if is_on_wall():
		jumpingParticles.rotation.x=-PI/2
		if wall_normal.y!=1.0:jumpingParticles.look_at(-wall_normal+jumpingParticles.global_position)
	else:
		jumpingParticles.rotation=$Model.rotation
		#realigns particles if jumping during coyote time
		if grounded_since_last_jump:jumpingParticles.rotation=Vector3(-PI/2,0,0)
	
	jumpingParticles.finished.connect(func():jumpingParticles.queue_free())




func _on_holster_weapon_state_entered():
	gun_attachment_point.bone_idx=2



##offsets the model downwards so sliding is in contact with the floor
func _on_sliding_state_entered():
	floor_block_on_wall=false
	floor_stop_on_slope=false
	
	$Model/SlidingParticles.emitting=true
	var normal=get_wall_normal()
	
		
	# Calculate a vector perpendicular to both the normal and gravity direction
	var tangent = Vector3.DOWN.cross(normal).normalized()

	# Calculate the downward direction by taking the cross product with the normal
	var binormal = normal.cross(tangent).normalized()
	
	if motion_direction_sliding==Vector3.ZERO:motion_direction_sliding=binormal

	sliding_velocity=velocity.length()
	if normal==Vector3.ZERO:
		velocity.y=0.0
		motion_direction_sliding=velocity.normalized()
		
	$Model.position.y=-0.875
	
	$Model/CameraOrigin.position.z = -0.5
	
	

#resets player model rotation and position
func _on_sliding_state_exited():
	var dir=(Vector3(-1,0,0))
	$Model.position.y=0
	$Model/SlidingParticles.emitting=false
	update_model_rotation(dir)
	motion_direction_sliding=Vector3.ZERO
	$Model/CameraOrigin.position.z = 0
	floor_block_on_wall=true
	floor_stop_on_slope=true


var last_wall_normal:Vector3=Vector3.ZERO
var motion_direction_sliding:Vector3=Vector3.ZERO
var sliding_velocity:float=0.0



func _on_jumped_state_entered():
	var jumpingParticles=$JumpParticles.duplicate()
	get_parent_node_3d().add_child(jumpingParticles)
	jumpingParticles.global_position=$JumpParticles.global_position
	jumpingParticles.emitting=true
	var floor_normal=get_floor_normal()
	#align particles with the direction of the face you jumped off of
	if is_on_floor():
		jumpingParticles.rotation.x=-PI/2
		if floor_normal.y!=1.0:jumpingParticles.look_at(-floor_normal+jumpingParticles.global_position)
	else:
		jumpingParticles.rotation=$Model.rotation
		#realigns particles if jumping during coyote time
		if grounded_since_last_jump:jumpingParticles.rotation=Vector3(-PI/2,0,0)
		
	
	
	
	jumpingParticles.finished.connect(func():jumpingParticles.queue_free())
	


func _on_cannotjump_airborne_physics_process(delta):
	if Input.is_action_just_pressed("slide"):_state_chart.send_event("poseMidJump")
