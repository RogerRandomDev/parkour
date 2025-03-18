extends Marker3D
class_name WeaponAttachmentPoint
##a marker for where to place a weapon on the character

##the [annotation Model] for the weapon to be loaded.
var MODEL:Node3D
##the holder [Node] for the [annotation WeaponScript].
##Should either be a [WeaponMeleeScript] or a [WeaponRangedScript].
var SCRIPT:Node
##Stats for the current [WeaponResource].
var weaponStats:Dictionary


##loads the weapon data into self along with building the weapon structure. Returns self
func loadWeapon(weapon:WeaponResource)->Node3D:
	#only free if the child isn't the weapon model itself
	for child in get_children():
		if child.name=="WEAPONMODEL":
			remove_child(child);continue
		child.queue_free()
	weapon.reloadInstance()
	
	#stores stats
	weaponStats=weapon.getWeaponStats()
	MODEL=weaponStats.WeaponModel
	MODEL.name="WEAPONMODEL"
	MODEL.rotation.y=-PI/2
	SCRIPT=Node3D.new()
	SCRIPT.set_script(weaponStats.Script)
	
	#makes sure MODEL and SCRIPT aren't already child nodes
	if !MODEL.get_parent():
		add_child(MODEL)
		add_child(SCRIPT)
	return self
