extends Resource
class_name WeaponResource



@export_group('GENERIC DATA')
##The Weapon model mesh.
##It expects the input to be a GLTF format
@export var WeaponModel:PackedScene
##the [Script] of the weapon. Should extend the [WeaponBaseScript]
@export var WeaponScript:Script

##minimum delay between attacks.
##when used by [WeaponRangedResource] it is the time between shots
@export var AttackSpeed:float=0.0
##Damage dealt per hit.
##Is the default damage applied to projectiles from [WeaponRangedResource].
@export var Damage:int=1
##amount of a resource consumed per use of the weapon.
##primarily used via the [WeaponRangedResource] weapons
@export var CostPerShot:int=1



#the created model for faster access
#should never be accessed except through functions
#should ABSOLUTELY NEVER be EDITED by any code beyond the init and reload
var _WeaponInstance:Node3D



#used only to create the starting _WeaponInstance for convenience
func _ready():
	_WeaponInstance=WeaponModel.instantiate()





##returns the [Node3D] of the weapon model
func getWeaponModel()->Node3D:return _WeaponInstance




##returns the weapon statistics
func getWeaponStats()->Dictionary:
	var StatsReturn=_getGenericStats()
	StatsReturn.merge(getUniqueStats(),true)
	return StatsReturn

##handles the generic stat data for the weapon types. 
##used to provide data non-unique to any weapon types.
func _getGenericStats()->Dictionary:
	return {
		'AttackSpeed':AttackSpeed,
		'Damage':Damage,
		'WeaponModel':_WeaponInstance,
		'Cost':CostPerShot,
		'Script':WeaponScript
		}

##returns the stat data unique to the weapon/weapon type.
##primarily used for merging with the Generic Stats.
##any stats sent from here that are found in the Generic Stats will overwrite the Generic version.
##defaults the WeaponType to GENERIC
func getUniqueStats()->Dictionary:
	return {
		'WeaponType':'GENERIC'
	}




##reloads current instance of the [member WeaponModel].
##Primary purpose is when adjusting info about weapon location etc.
##as a quick and dirty fix for when nothing else fixes an issue.
##avoid usage due to efficiency decreasing as [member WeaponModel] detail increases
func reloadInstance()->Node3D:
	_WeaponInstance=WeaponModel.instantiate()
	return _WeaponInstance


