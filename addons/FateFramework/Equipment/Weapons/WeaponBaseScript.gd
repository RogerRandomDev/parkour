extends Node3D
class_name WeaponBaseScript
##Base script for handling weapons in the scene tree.
##Inherited by the [WeaponMeleeScript] and [WeaponRangedScript].

var _root:Node3D
var _body:Node3D

##the collision layer dedicated to harmable entities.
##set via the health statistic node to 512
const harmLayer:int=512
##the world layer for collision.
##added to [member harmLayer] as a way to manage what can block bullets anyways.
const worldLayer:int=3

#set the root node to the rigid body
func _ready():
	_root=get_parent()
	_body=get_parent().get_parent().get_parent()


