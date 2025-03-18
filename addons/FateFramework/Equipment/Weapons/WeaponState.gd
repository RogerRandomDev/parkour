extends Node
class_name WeaponState
##a root Node for handling weapon data from the [WeaponResource] for entities

##the [annotation WeaponData] for the weapon.
##stored using a [WeaponResource]
@export var WeaponData:WeaponResource

func _ready():
	WeaponData._ready()
	get_parent().get_parent().get_node("WeaponModelManager").loadWeapon("HoldingGun",WeaponData)



