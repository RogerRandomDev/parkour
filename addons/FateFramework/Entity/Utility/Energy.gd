extends StatisticNode
class_name EnergyNode
##a [StatisticNode] for handling Energy

##calls when using energy
signal usedENERGY(used:int,remainder:int,max:int)
##calls when gaining energy
signal regainENERGY(used:int,remainder:int,max:int)
##calls whenever energy changes
signal changeENERGY(changedBy:int,remainder:int,max:int)
##current energy
@export var ENERGY:int=100;
##maximum energy
@export var maxENERGY:int=100;
##multiplier for increasing [member ENERGY] by x times [member maxENERGY]
@export var externalModifier:float=1.;

##delay time in Seconds before regenerating energy at a rate of [member energyRegenRate]
@export var energyRegenDelay:float=1.0;
##rate at which energy regenerated
@export var energyRegenRate:float=1.0

var _regenWait:float=0.
var _partialEnergy:float=0.


#stops regeneration while still waiting
func _process(delta):
	if _regenWait>0.:
		_regenWait-=delta
		return
	
	_partialEnergy+=energyRegenRate*delta
	while _partialEnergy>=1.:
		_partialEnergy-=1.
		changeBy(1)


##modify remaining ENERGY[br]
##calls the [signal regainENERGY] or [signal usedENERGY]
##based on if it was an increase or decrease[br]
##[member ENERGY] is clamped between 0 and [member externalModifier] times [member maxENERGY]
func changeBy(modifier:int)->void:
	
	var currentENERGY:int=ENERGY;
	ENERGY=clamp(ENERGY+modifier,0,int(maxENERGY*externalModifier))
	##begin regen delay timer
	if(modifier<0):_regenWait=energyRegenDelay
	
	
	#only emit signal if ENERGY changed
	if(ENERGY==currentENERGY):return
	emit_signal(
		"regainENERGY" if modifier>0 else "usedENERGY",
		abs(modifier),
		ENERGY,
		int(maxENERGY*externalModifier)
	)
	emit_signal(
		"changeENERGY",
		modifier,
		ENERGY,
		int(maxENERGY*externalModifier)
	)


##changes the [member externalModifier] and will also update the current values of [member ENERGY] as long as [annotation updateValues] is true[br]
##will also trigger [signal regainENERGY] or [signal usedENERGY] if updating current [member ENERGY]
func updateExternalModifier(modifier:float,updateValues:bool=true)->void:
	var lastModifier:float=externalModifier;
	externalModifier=modifier;
	
	#only continues if updateValues is true and the modifier has changed
	if(!(updateValues&&lastModifier!=externalModifier)):return
	var valueChanged:int=int(maxENERGY*(externalModifier-1.));
	ENERGY+=valueChanged
	emit_signal(
		"regainENERGY" if lastModifier < externalModifier else "usedENERGY",
		abs(valueChanged),
		ENERGY,
		int(maxENERGY*externalModifier)
	)
	emit_signal(
		"changeENERGY",
		modifier,
		ENERGY,
		int(maxENERGY*externalModifier)
	)



#returns if [annotation castEnergyRequired] is less or equal to current energy reserves
##returns if [annotation castEnergyRequired] is less than or equal to the current [member ENERGY] available
func attemptCast(castEnergyRequired:int)->bool:return ENERGY>=castEnergyRequired
