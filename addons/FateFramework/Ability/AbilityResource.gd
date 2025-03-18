@tool
extends Resource
class_name AbilityResource
##handles storing the information of an ability[br]
##encompases main, secondary, motion, passive, and the name and descriptions

##delay for primary updated
signal PrimaryDelayUpdated(maxDelay:float,curDelay:float)
##delay for secondary updated
signal SecondaryDelayUpdated(maxDelay:float,curDelay:float)
##delay for motion updated
signal MotionDelayUpdated(maxDelay:float,curDelay:float)

##emited whenever the ability attempts to trigger while [member is_active_currently] is set to true
##type is 0,1,2 based on primary secondary or motion, 3 when it is a special condition I.E. passive
##ability should be the ability resource itself
##failReason is for if it did not succeed, optional value to set why
signal ability_trigger_attempted(type:int,succeeded:bool,failReason:String,ability:AbilityResource)

##primary ability triggered
signal PrimaryTriggered
##secondary ability triggered
signal SecondaryTriggered
##motion ability triggered
signal MotionTriggered



##Name for the Ability itself
@export var Name:String
@export_group("Abilities")
@export_subgroup("Main")
##main ability exists
@export var hasMain:bool=false
##main ability name
@export var MainName:String
##main ability description
@export_multiline var MainDescription:String
##main ability [AbilityActionResource]
@export var MainEffect:Script:
	set(v):
		MainEffect=v
		var n=Node.new()
		n.set_script(v)
		MainNode=n
	get:return MainEffect
var MainNode:Node
##delay between using the main Ability
@export var abilityDelay:float=0.
var _mainTimeLeft:float=0.
##energy used for the main ability
@export var mainAbilityEnergy:int=0.

@export_subgroup("Secondary")
##secondary ability exists
@export var hasSecondary:bool=false
##secondary ability name
@export var SecondaryName:String
##secondary ability description
@export_multiline var SecondaryDescription:String
##secondary ability [AbilityActionResource]
@export var SecondaryEffect:Script:
	set(v):
		SecondaryEffect=v
		var n=Node.new()
		n.set_script(v)
		SecondaryNode=n
	get:return SecondaryEffect
var SecondaryNode:Node
##delay between using the secondary ability
@export var secondaryAbilityDelay:float=0.
var _secondaryTimeLeft:float=0.
##energy used for the secondary ability
@export var secondaryAbilityEnergy:int=0.

@export_subgroup("Motion")
##motion ability exists
@export var hasMotion:bool=false
##motion ability name
@export var MotionName:String
##motion ability description
@export_multiline var MotionDescription:String
##motion ability [AbilityActionResource]
@export var MotionEffect:Script:
	set(v):
		MotionEffect=v
		var n=Node.new()
		n.set_script(v)
		MotionNode=n
	get:return MotionEffect
var MotionNode:Node

##delay between using the motion ability
@export var motionAbilityDelay:float=0.
##energy used for the motion ability
@export var motionAbilityEnergy:int=0.

var _motionTimeLeft:float=0.
var _last_motion_press:int=0

@export_subgroup("Passive")
##passive ability exists
@export var hasPassive:bool=false
##passive ability name
@export var PassiveName:String
##passive ability description
@export_multiline var PassiveDescription:String
##passive ability [AbilityActionResource]
@export var PassiveEffect:Script:
	set(v):
		PassiveEffect=v
		var n=Node.new()
		n.set_script(v)
		PassiveNode=n
	get:return PassiveEffect

var PassiveNode:Node

#this is set to the character containing the ability list
#it is used for getting things like statistics from the character
#using the ability
var _inheritedRoot:Node
var _inheritedOrigin:Node


var _lastTime:int=0




##set to manage if the ability can be triggered or not
##makes it easier to manage the signals from other abilities as well
var is_active_currently:bool=false

##links the signals to the ability sub-scripts
func _initialize_signals()->void:
	PrimaryTriggered.connect(MainNode.trigger)
	SecondaryTriggered.connect(SecondaryNode.trigger)
	MotionTriggered.connect(MotionNode.trigger)

##sets root node for all sub scripts
##mainly to keep them laid out correctly and
##for ease of use
func load_structure_root(root_node:Node,origin_node:Node=null)->void:
	MainNode.root=root_node
	SecondaryNode.root=root_node
	MotionNode.root=root_node
	_inheritedOrigin=origin_node
	if _inheritedOrigin==null:_inheritedOrigin=root_node
	MainNode.origin_node=origin_node
	SecondaryNode.origin_node=origin_node
	MotionNode.origin_node=origin_node
	
	
	MainNode._ready()
	SecondaryNode._ready()
	MotionNode._ready()


##updates whether this ability is currently active.
##Sets [member is_active_currently] to if the input is itself
func updateActive(changedTo:AbilityResource)->void:
	is_active_currently=(changedTo==self)
	


#updates the time left
func _process(_delta:float=0.0):
	if _mainTimeLeft>0.:
		_mainTimeLeft-=_delta
		emit_signal("PrimaryDelayUpdated",abilityDelay,_mainTimeLeft)
	if _secondaryTimeLeft>0.:
		_secondaryTimeLeft-=_delta
		emit_signal("SecondaryDelayUpdated",secondaryAbilityDelay,_secondaryTimeLeft)
	if _motionTimeLeft>0.:
		_motionTimeLeft-=_delta
		emit_signal("MotionDelayUpdated",motionAbilityDelay,_motionTimeLeft)


##checks and emits trigger signals based on abilities and conditions
func checkTrigger(type:int)->void:
	#don't skip if it is 3, in case it is a passive ability check
	if !is_active_currently&&type!=3:return
	match type:
		0:
			if _mainTimeLeft>0.:return emit_signal("ability_trigger_attempted",0,false,"still_on_cooldown",self)
			if !attemptTriggerMain():return emit_signal("ability_trigger_attempted",0,false,"energy_low",self)
			emit_signal("PrimaryTriggered")
			_mainTimeLeft=abilityDelay
			
			return emit_signal("ability_trigger_attempted",0,true,"success",self)
		1:
			if _secondaryTimeLeft>0.:return emit_signal("ability_trigger_attempted",1,false,"still_on_cooldown",self)
			if !attemptTriggerSecondary():return emit_signal("ability_trigger_attempted",1,false,"energy_low",self)
			emit_signal("SecondaryTriggered")
			_secondaryTimeLeft=secondaryAbilityDelay
			
			return emit_signal("ability_trigger_attempted",1,true,"success",self)
		2:
			if _motionTimeLeft>0.:return emit_signal("ability_trigger_attempted",2,false,"still_on_cooldown",self)
			if !attemptTriggerMotion():return emit_signal("ability_trigger_attempted",2,false,"energy_low",self)
			emit_signal("MotionTriggered")
			_motionTimeLeft=motionAbilityDelay
			
			return emit_signal("ability_trigger_attempted",2,true,"success",self)
			





##returns the [member Name] of the ability itself[br]
##this is different than the names of the ability subsets
##I.E. [member MainName], [member SecondaryName]
func getName()->String:
	return Name

##returns a [Dictionary] containing the data for the ability and it's separate parts
func getDescription()->Dictionary:
	var out={}
	if hasMain:out.Primary={"Name":MainName,"Description":MainDescription,"Cost":mainAbilityEnergy}
	if hasSecondary:out.Secondary={"Name":SecondaryName,"Description":SecondaryDescription,"Cost":secondaryAbilityEnergy}
	if hasMotion:out.Motion={"Name":MotionName,"Description":MotionDescription,"Cost":motionAbilityEnergy}
	if hasPassive:out.Passive={"Name":PassiveName,"Description":PassiveDescription}
	return out

##returns a dictionary of the abilty data
func getAbilityData()->Dictionary:
	var out:Dictionary={}
	#adds the descriptions and names of the component abilities
	out.merge(getDescription())
	
	return out




##returns a [Boolean] based on if you have enough energy to trigger the [annotation Main Ability][br]
##defaults to true if the [annotation Inherited Node] lacks an [annotation Energy Statistic]
func canTriggerMain()->bool:
	return _inheritedRoot.get_node("Statistics").getStatistic("Energy")==null||_inheritedRoot.get_node("Statistics").getStatistic("Energy").attemptCast(mainAbilityEnergy)

##returns a [Boolean] based on if you have enough energy to trigger the [annotation Secondary Ability][br]
##defaults to true if the [annotation Inherited Node] lacks an [annotation Energy Statistic]
func canTriggerSecondary()->bool:
	return _inheritedRoot.get_node("Statistics").getStatistic("Energy")==null||_inheritedRoot.get_node("Statistics").getStatistic("Energy").attemptCast(secondaryAbilityEnergy)

##returns a [Boolean] based on if you have enough energy to trigger the [annotation Motion Ability][br]
##defaults to true if the [annotation Inherited Node] lacks an [annotation Energy Statistic]
func canTriggerMotion()->bool:
	return _inheritedRoot.get_node("Statistics").getStatistic("Energy")==null||_inheritedRoot.get_node("Statistics").getStatistic("Energy").attemptCast(motionAbilityEnergy)

##attempts to trigger the [annotation Main Ability] if [method canTriggerMain] returns true[br]
##if it triggers, it will consume the corresponding [annotation ENERGY] for the ability
func attemptTriggerMain()->bool:
	if !canTriggerMain():return false
	var energy=_inheritedRoot.get_node("Statistics").getStatistic("Energy")
	if energy!=null:energy.changeBy(-mainAbilityEnergy)
	
	return true

##attempts to trigger the [annotation Secondary Ability] if [method canTriggerSecondary] returns true[br]
##if it triggers, it will consume the corresponding [annotation ENERGY] for the ability
func attemptTriggerSecondary()->bool:
	if !canTriggerSecondary():return false
	
	var energy=_inheritedRoot.get_node("Statistics").getStatistic("Energy")
	if energy!=null:energy.changeBy(-secondaryAbilityEnergy)
	
	return true

##attempts to trigger the [annotation Motion Ability] if [method canTriggerMotion] returns true[br]
##if it triggers, it will consume the corresponding [annotation ENERGY] for the ability
func attemptTriggerMotion()->bool:
	if !canTriggerMotion():return false
	
	var energy=_inheritedRoot.get_node("Statistics").getStatistic("Energy")
	if energy!=null:energy.changeBy(-motionAbilityEnergy)
	
	return true
