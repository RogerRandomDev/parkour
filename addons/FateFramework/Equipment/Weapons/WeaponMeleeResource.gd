extends WeaponResource
class_name WeaponMeleeResource
##A Node for Handling Ranged Weapons based on [WeaponState]

@export_group("MELEE DATA")
##The [annotation Reach] of the melee weapon
@export var Reach:float=3.




func getUniqueStats()->Dictionary:
	return {
		'Reach':Reach,
		'WeaponType':'MELEE'
	}
