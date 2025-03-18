extends Node
class_name StatisticsManagerNode
##Manager node for [StatisticNode]
##handles adding removing and getting statistics


#adds the provided statistic to the
#current statistics if one with the
#matching name doesn't yet exist
##adds the [annotation statistic] and applies the [annotation statisticName] if it doesn't already exist
func addStatistic(statisticName:String,statistic:Node):
	if get_node_or_null(statisticName):return
	statistic.name=statisticName
	add_child(statistic)

#removes statistic with matching name
#it defers the removal so you can reference
#the contained data immediately after calling it
##removes the [annotation statistic] with the matching [annotation statisticName][br]
##returns the removed [annotation statistic]
func removeStatistic(statisticName:String)->Node:
	var statistic:Node=get_node_or_null(statisticName)
	if statistic:statistic.queue_free.call_deferred()
	return statistic

#returns the statistic with the corresponding name
##returns the [annotation statistic] with the matching [annotation statisticName]
func getStatistic(statisticName:String)->Node:
	var statistic:Node=get_node_or_null(statisticName)
	return statistic


##applies the change to the relevant statistic
func inflictModifier(statisticName:String,modifierElement:String,modifierValue:int)->void:
	
	var stat=getStatistic(statisticName)
	if !stat:return
	stat.changeBy(modifierValue)


##runs the method of the given name on all the statistics
##returns an array of the returned values
func attemptRunAll(funcName:String,nodeCalled:Node)->Array:
	var returnedValues:Array=[]
	for stat in get_children():
		if stat.has_method(funcName):returnedValues.push_back(stat.call(funcName,nodeCalled))
	
	return returnedValues

##runs on all available section managers to check for any responses.
##returns an array of any responses.
func runFullExternalCheck(checkName:String,nodeCalled:Node,endOn)->Array:
	var responses:Array=[]
	var abi=get_parent().get_node_or_null("Abilities")
	var wep=get_parent().get_node_or_null("Weapons")
	var sta=get_parent().get_node_or_null("States")
	if abi:responses.append_array(abi.attemptRunAll(checkName,nodeCalled))
	if responses.any(func(a):return a==endOn):return responses
	if wep:responses.append_array(wep.attemptRunAll(checkName,nodeCalled))
	if responses.any(func(a):return a==endOn):return responses
	if sta:responses.append_array(sta.attemptRunAll(checkName,nodeCalled))
	if responses.any(func(a):return a==endOn):return responses
	return responses
