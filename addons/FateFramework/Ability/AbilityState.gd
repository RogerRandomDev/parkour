extends Node
class_name AbilityState
##the base node for Abilities
##handled using a [AbilityManagerNode]

##the [AbilityResource] for the ability's data and effects
@export var abilityResource:AbilityResource


##the root node, should usually be a [CharacterBody3D] acting as an [annotation entity] or [annotation player]
var root:Node3D


##main ability just activated
var justTriggered:bool=false
##secondary ability just activated
var justTriggeredSecondary:bool=false
#motion ability just activated
var justTriggeredMotion:bool=false
func _ready():
	abilityResource.setup_local_to_scene()
	root=get_parent().get_parent()
	abilityResource._inheritedRoot=root
	if abilityResource.get("MainEffect"):
		attachSignalToAbility("AbilityTriggered","trigger",abilityResource.MainEffect)
	if abilityResource.get("SecondaryEffect"):
		attachSignalToAbility("SecondaryAbilityTriggered","trigger",abilityResource.SecondaryEffect)
	if abilityResource.get("MotionEffect"):
		attachSignalToAbility("MotionAbilityTriggered","trigger",abilityResource.MotionEffect)

##attaches signal to ability resource scripts by attaching them to nodes
func attachSignalToAbility(signalName:String,functionName:String,abilityEffect:Script)->void:
	var n=Node.new()
	n.set_script(abilityEffect)
	add_child(n)
	
	get_parent().connect(signalName,n.get(functionName))


#updates ability timers
func _process(delta):
	abilityResource._process()







#everything below is per-ability
#change them as needed to match needs

##run whenever you choose the given ability
func onTrigger()->void:pass


##intercepts attempts to die to see if it should do anything.
##should return a boolean of true or false based on if it will still die or not
func attemptingDeathCheck()->bool:return true


#ability drawing function
#put in the code that creates the vfx for the ability itself
##DEPRACATED FUNCTION
func drawAbilityEffect()->void:pass
