extends Control

@onready var SettingNodes=$Inputs/ScrollContainer/Vcontainer

var setting_values={}


# Called when the node enters the scene tree for the first time.
func _ready():
	add_labels_to_settings()
	await get_tree().process_frame
	$Inputs/ScrollContainer.size.x+=14
	
	
	#region run initializer functions
	var method_list=get_method_list()
	for method in method_list:
		if method.name.contains("initialize_"):
			call(method.name)
	#endregion
	$Inputs/ScrollContainer/Vcontainer/WindowMode.grab_focus()
	$AnimationPlayer.play("settings_animation")
	
	apply_settings()
	
	$RestartNeeded.hide()

##applies all setting changes and stores them
func apply_settings()->void:
	var method_list=get_method_list()
	for method in method_list:
		if method.name.contains("apply_")&&method.name!="apply_settings":
			call(method.name)

##adds labels to the settings by using their node name
##also updates scroll container to recenter the settings
func add_labels_to_settings()->void:
	var max_x:int=0
	var max_setting_x:int=0
	for setting in SettingNodes.get_children():
		if setting.is_in_group("dont_label"):continue
		var setting_label=Label.new()
		var hold=Control.new()
		#region generate label and attach
		setting_label.theme_type_variation="SettingLabel"
		setting_label.text=setting.name.capitalize()
		hold.add_child(setting_label)
		setting.add_child(hold)
		setting.move_child(hold,0)
		setting_label.force_update_transform()
		#endregion
		setting.focus_entered.connect(func():setting_label.theme_type_variation="SettingLabelFocus")
		setting.focus_exited.connect(func():setting_label.theme_type_variation="SettingLabel")
		
		max_x=max(max_x,setting_label.size.x)
		max_setting_x=max(max_setting_x,setting.size.x)
		
			
	
	
	for setting in SettingNodes.get_children():
		#region make label sections centered
		if setting.is_in_group("dont_label"):
			var held_by=Control.new()
			held_by.custom_minimum_size.y=setting.size.y
			SettingNodes.add_child(held_by)
			SettingNodes.move_child(held_by,SettingNodes.get_children().find(setting))
			setting.reparent(held_by)
			setting.position.x+=18
			continue
		#endregion
		
		setting.get_child(0).get_child(0).position.x-=max_x+18
	$Inputs/ScrollContainer.custom_minimum_size.x+=max_x



#region Shadow Quality

func _on_shadow_quality_item_selected(index,value)->void:
	setting_values.shadow_quality=value
	$RestartNeeded.show()

func initialize_shadow_quality_setting()->void:
	var shadow_res=ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/size")
	SettingNodes.get_node("ShadowQuality").select_by_true_value(shadow_res)

func apply_shadow_quality()->void:
	if setting_values.get("shadow_quality")==null:return
	ProjectSettings.set_setting(
		"rendering/lights_and_shadows/directional_shadow/size",
		setting_values.shadow_quality
		)


#endregion


#region Window Mode

func _on_window_mode_item_selected(index,value):
	var window_mode=value
	setting_values.window_mode=window_mode

func initialize_window_mode()->void:
	var window_mode=ProjectSettings.get_setting("display/window/size/mode")
	SettingNodes.get_node("WindowMode").select_by_true_value(window_mode)

func apply_window_mode()->void:
	if setting_values.get("window_mode")==null:return
	ProjectSettings.set_setting("display/window/size/mode",setting_values.window_mode)
	DisplayServer.window_set_mode(setting_values.window_mode)
	#setting the size when undoing fullscreen to the base resolution
	if setting_values.window_mode==0:
		DisplayServer.window_set_size(Vector2i(1152,648))

#endregion


#region VSync Mode

func _on_v_sync_item_selected(index,value):
	setting_values.vsync_mode=value
	

func initialize_vsync_mode()->void:
	var index=ProjectSettings.get_setting("display/window/vsync/vsync_mode")
	DisplayServer.window_set_vsync_mode(index)
	SettingNodes.get_node("VSync").select_by_true_value(index)

func apply_vsync_mode()->void:
	if setting_values.get("vsync_mode")==null:return
	var mode=setting_values.vsync_mode
	ProjectSettings.set_setting("display/window/vsync/vsync_mode",mode)
	DisplayServer.window_set_vsync_mode(mode)

#endregion


#region MSAA Mode
func _on_msaa_item_selected(index,value):
	setting_values.msaa_mode=value

func initialize_msaa_mode()->void:
	SettingNodes.get_node("MSAA").select_by_true_value(ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d"))

func apply_msaa_mode()->void:
	if setting_values.get("msaa_mode")==null:return
	var value=setting_values.msaa_mode
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",value)
	RenderingServer.viewport_set_msaa_3d(get_tree().root.get_viewport_rid(),value)

#endregion

func save_data()->void:ProjectSettings.save_custom("override.cfg")








