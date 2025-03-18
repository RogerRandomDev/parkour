extends Node
class_name CoyoteTimerNode
@export var maxCoyoteTime:float=0.25
var currentCoyoteTime:float=0.0

#updates current coyoteTime
func _physics_process(delta):
	currentCoyoteTime+=delta
	if get_parent().is_on_floor():currentCoyoteTime=0.;

#returns when you haven't been off a ledge for longer than maxCoyoteTime
func canJump():return currentCoyoteTime<=maxCoyoteTime
