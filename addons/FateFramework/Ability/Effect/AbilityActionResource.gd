extends Node
class_name AbilityActionResource
##Resource for handling all states of an abilities possible actions


##a [PhysicsShapeQueryParameters3D] to use for the ability area of effect
var abilityArea:PhysicsShapeQueryParameters3D=PhysicsShapeQueryParameters3D.new()
##stored to prevent having to call multiple times
var space_state:PhysicsDirectSpaceState3D

##sets the [member abilityArea] shape
func setShape(shape:Shape3D)->void:abilityArea.shape=shape
##updates the transform of the [member abilityArea]
func setShapeTransform(new_transform:Transform3D)->void:abilityArea.transform=new_transform

##returns an array of all the nodes that intersect [member abilityArea]
func getEntitiesInRange()->Array:
	var collisions:=space_state.intersect_shape(abilityArea)
	return collisions.map(func(val):return val.collider)
var root:Node=null
var origin_node:Node=null


func _ready():
	space_state=root.get_viewport().find_world_3d().direct_space_state
	loadAbility()

##unique to each ability, loads ability-specific data
func loadAbility()->void:pass


##unique to the ability, loads the ability animation/visuals
func loadAbilityVisuals()->void:pass

##runs whenever the ability is activated
func trigger():pass
