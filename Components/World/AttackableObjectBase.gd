extends Node3D
class_name AttackableObjectBase

signal Attacked(attack_data)



@export_category("AttackTypes")
@export var HitScanBullet:bool=false
@export var Explosion:bool=false
@export var Fire:bool=false
@export var Blade:bool=false
@export var Blunt:bool=false
@export var Special:bool=false




func _ready():
	add_to_group("Attackable")
