extends Node3D
class_name WeaponModelManager
##manages the placing of weapons along the body along with creating the weapons into the scene.



##the [annotation Model] for the weapon to be loaded.
var MODEL:Node3D
##the holder [Node] for the [annotation WeaponScript].
##Should either be a [WeaponMeleeScript] or a [WeaponRangedScript].
var SCRIPT:Node



##loads the weapon data into self along with building the weapon structure. Returns attachment point
func loadWeapon(loadOnto:String,weapon:WeaponResource)->Node3D:
	var loadedTo=get_node_or_null(loadOnto)
	if !loadedTo:return null
	loadedTo.loadWeapon(weapon)
	return loadedTo

##updates current rotations based on input rotation
func updateRotations(newRotations:Vector3):
	pass
	#for child in get_children():
		#child.rotation.x=newRotations.x
