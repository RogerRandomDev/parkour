extends VBoxContainer


@export var AbilityListed:String="Primary"


var label:Label=Label.new()
var delayLeft:ProgressBar=ProgressBar.new()
func _ready():
	delayLeft.show_percentage=false
	add_child(label)
	add_child(delayLeft)

func updateTo(data,ability:AbilityResource)->void:
	if !data.size():return
	label.text=data.Name
	#updats the text to add an @ if the ability is currently castable
	ability._inheritedRoot.get_node("Statistics").getStatistic("Energy").connect("changeENERGY",
		func(by,rem,maxVal):
			label.text=data.Name+ ("@" if ability._inheritedRoot.get_node("Statistics").getStatistic("Energy").attemptCast(data.Cost) else ""))
	#updates the delay progress bar
	ability.connect(AbilityListed+"DelayUpdated",
	func(max_val,cur_val):
		delayLeft.max_value=max_val
		delayLeft.value=max_val-cur_val
		delayLeft.modulate=(Color(1,1,1,1) if max_val-cur_val>=max_val else Color(0.5,0.5,0.5,1))
	)
	
	
