extends Node


var setting_values:Dictionary={}


func set_setting(setting_name:String,setting_value)->void:
	setting_values[setting_name]=setting_value



func get_setting(setting_name:String):
	return setting_values[setting_name]
