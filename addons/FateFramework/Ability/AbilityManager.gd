extends Node
class_name AbilityManagerNode
##manages swapping and handling the abilities and the [AbilityResource]


##detects when the current ability set is changed
##primarily used for updating gui info
signal ActiveAbilityChanged(changedTo:AbilityResource)

##updates the time for the abilities, keeps them properly synced
signal AbilityTimeUpdate(_delta:float)

##emitted to tell the active ability to trigger
signal AbilityTriggered(type:int)



##list of the abilities for the given character
@export var AbilityList:Array[Resource]

func _ready():
	await get_tree().process_frame
	for ability in AbilityList:
		ability._inheritedRoot=get_parent()
		ActiveAbilityChanged.connect(ability.updateActive)
		AbilityTriggered.connect(ability.checkTrigger)
		AbilityTimeUpdate.connect(ability._process)
		ability._initialize_signals()
		ability.load_structure_root(get_parent(),get_parent().abilityOrigin)
	
	ActiveAbilityChanged.emit(AbilityList[0])


func _process(delta):
	AbilityTimeUpdate.emit(delta)
