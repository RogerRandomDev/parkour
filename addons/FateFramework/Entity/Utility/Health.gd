extends StatisticNode
class_name HealthNode
##[StatisticNode] for handling the Health of an entity

##emits when health decreases
signal hurt(change: int,remainder:int,max:int)
##emits when health increases
signal heal(change: int,remainder:int,max:int)
##emits whenever health changes
signal changeHealth(change:int,remainder:int,max:int)
##emits when health is <= 0 and nothing intercepted its death
signal triggerDeath


##the current HEALTH
@export var HP:int=100;
##the max value of [member HP]
@export var maxHP:int=100;
##the modifier for [member maxHP]
@export var externalModifier:float=1.;

#remaining damage that wasn't applied
var _remainderLeft:int=0



func _ready():
	attributeCollision(512)


#modify remaining health
##modifies current health and calls [signal hurt] or [signal heal] based on if it increased or decreased[br]
##[member HP] is clamped between 0 and [member maxHP] times [member externalModifier]
func changeBy(modifier:int)->void:
	var currentHP=HP;
	HP=clamp(HP+modifier,0,maxHP*externalModifier)
	#sets the amount that wasn't applied
	_remainderLeft=abs(currentHP-(HP+modifier))
	#attempt to die if HP is zero
	if(HP<=0):attemptDeath()
	
	
	if(HP==currentHP):return
	emit_signal(
		"heal" if modifier>0 else "hurt",
		abs(modifier),
		HP,
		maxHP*externalModifier
	)
	emit_signal(
		"changeHealth",
		modifier,
		HP,
		maxHP*externalModifier
	)
	
	
func _input(event):
	if Input.is_key_pressed(KEY_H):
		changeBy(-5)
##changes the [member externalModifier] and will also update the current [member HP] values as long as [annotation updateValues] is true[br]
##will emit [signal hurt] or [signal heal] if it changes [member HP]
func updateExternalModifier(modifier:float,updateValues:bool=true)->void:
	var lastModifier:float=externalModifier;
	externalModifier=modifier;
	
	#only continues if updateValues is true and the modifier has changed
	if(!(updateValues&&lastModifier!=externalModifier)):return
	var valueChanged:int=int(maxHP*(externalModifier-1.));
	HP=int(min(HP+valueChanged,maxHP*externalModifier))
	
	emit_signal(
		"heal" if lastModifier < externalModifier else "hurt",
		abs(valueChanged),
		HP,
		maxHP*externalModifier
	)
	emit_signal(
		"changeHealth",
		modifier,
		HP,
		maxHP*externalModifier
	)



##checks no external circumstance is preventing death
func attemptDeath()->void:
	var externalCircumstanceExists:bool=false
	#if it receives any "dontDie" it won't queue_free itself
	var externalChecks=get_parent().runFullExternalCheck("attemptingToDie",self,"dontDie")
	externalCircumstanceExists=externalChecks.any(func(a):return a)
	
	if !externalCircumstanceExists:get_parent().get_parent().queue_free()
