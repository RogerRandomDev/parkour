extends Node
class_name StatisticNode
##base node for handling Statistics[br]
##I.E. [EnergyNode] or [HealthNode][br]
##is handled by [StatisticsManagerNode]


##increases the root collision layer by [annotation layerVal] amount.
##allows you to designate a layer for a specific attribute
func attributeCollision(layerVal:int):
	get_parent().get_parent().set_collision_layer(get_parent().get_parent().get_collision_layer()+layerVal)
