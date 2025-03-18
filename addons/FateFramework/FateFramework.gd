@tool
extends EditorPlugin

# Replace this value with a PascalCase autoload name, as per the GDScript style guide.

var p
func _enter_tree():
	# The autoload can be a scene or script file.
	add_autoload_singleton("Fate", "res://addons/FateFramework/tools.gd")
	add_autoload_singleton("SpecialRender", "res://addons/FateFramework/specialRendering.gd")
	p=preload("res://addons/FateFramework/inspector/AbilityAnimationInspector.gd").new()
	add_inspector_plugin(p)


func _exit_tree():
	remove_autoload_singleton("Fate")
	remove_autoload_singleton("SpecialRender")
	remove_inspector_plugin(p)
