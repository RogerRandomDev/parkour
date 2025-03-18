@tool
extends EditorInspectorPlugin


func _can_handle(object):
	#return object is AbilityEffectResource
	print(object)
	return false

const AnimationPreview=preload("res://addons/FateFramework/inspector/PreviewAnimation.tscn")
var activePreview=null

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if(name != 'AbilityMeshAnimations'):return
	activePreview=AnimationPreview.instantiate()
	add_custom_control(activePreview)
	activePreview._setResource.call_deferred(object)
