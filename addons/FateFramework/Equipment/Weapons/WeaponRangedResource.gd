extends WeaponResource
class_name WeaponRangedResource
##A Node for Handling Ranged Weapons based on [WeaponState]


@export_group("RANGED DATA")
##quantity of [annotation Projectiles] fired by the weapon
@export var ProjectileCount:int=1
##the [annotation Spread] of the weapon [annotation Projectiles]. [annotation Spread] is not applied when [member ProjectileCount] is 1.
##[annotation Spread] is handled in vertical and horizontal context
@export var ProjectileSpread:Vector2=Vector2(0,0)
##the [annotation Spread] per projectile along the [member ProjectileSpread].
##used for quantity to spread along the x direction
@export var ProjectileAlongX:int=5



##returns the unique stats for a Ranged Weapon
func getUniqueStats()->Dictionary:
	return {
		'Projectiles':ProjectileCount,
		'Spread':ProjectileSpread,
		'BulletsX':ProjectileAlongX,
		'WeaponType':'RANGED'
	}
