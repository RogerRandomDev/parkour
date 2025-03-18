extends Node
class_name HoldingManagerNode


var activeHeld:Node;

#disasbles all states by default
func _ready():
	for held in get_children():
		setHeldProcess(held,false)




#sets the active state if available
func setactiveHeld(held:String)->Node:
	var newHeld=get_node_or_null(held)
	if(newHeld==null):return
	
	if(activeHeld!=null):setHeldProcess(activeHeld,false)
	setHeldProcess(newHeld,true)
	activeHeld=newHeld
	return newHeld

func updateHeldResource(held:String,resource:Resource)->Node:
	var node=get_node_or_null(held)
	if(node==null):return
	node.setItemResource(resource)
	return node



#changes process mode for any states
func setHeldProcess(state:Node,process:bool):
	state.set_physics_process(process)
	state.set_process_input(process)
	state.set_physics_process_internal(process)
	if(process):state.onTrigger()

#returns relevant state
func getHeld(held:String):
	return get_node_or_null(held);
