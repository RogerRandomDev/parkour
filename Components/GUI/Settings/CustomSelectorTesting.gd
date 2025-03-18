@tool
extends PanelContainer
class_name CustomSelector


@export var valueNames:PackedStringArray:
	set(v):
		valueNames=v
		valueIndices.resize(v.size())
	get:return valueNames
@export var valueIndices:PackedInt32Array:
	set(v):
		if len(valueNames)==len(v):valueIndices=v
	get:return valueIndices

@export var require_restart:bool=false


signal item_selected(index:int,value:int)

var selected:int=0:
	set(v):
		selected=v
		emit_signal("item_selected",v,valueIndices[v])
		displayText.text=valueNames[v]
		position_bar.material.set_shader_parameter("current_value",selected)
	get:return selected

#region selector nodes
var holder=HBoxContainer.new()

var lButton=TextureButton.new()
var displayText=Label.new()
var rButton=TextureButton.new()
var position_bar=ColorRect.new()
#endregion




func _init():
	
	add_child(holder)
	
	holder.add_child(lButton)
	holder.add_child(displayText)
	holder.add_child(rButton)
	displayText.add_child(position_bar)
	
	displayText.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	displayText.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	displayText.vertical_alignment=VERTICAL_ALIGNMENT_TOP
	lButton.theme_type_variation="SelectorLeft"
	rButton.theme_type_variation="SelectorRight"
	lButton.custom_minimum_size.x=24
	rButton.custom_minimum_size.x=24
	lButton.texture_normal=load("res://Components/GUI/Settings/GuiTreeArrowLeft.svg")
	rButton.texture_normal=load("res://Components/GUI/Settings/GuiTreeArrowRight.svg")
	lButton.stretch_mode=TextureButton.STRETCH_KEEP_CENTERED
	rButton.stretch_mode=TextureButton.STRETCH_KEEP_CENTERED
	lButton.pressed.connect(func():
		grab_focus()
		select_value(max(selected-1,0)))
	rButton.pressed.connect(func():
		grab_focus()
		select_value(min(selected+1,len(valueNames)-1)))
	var mat=ShaderMaterial.new()
	mat.shader=load("res://Components/GUI/Settings/SelectorBar.gdshader")
	
	position_bar.material=mat
	
	
	rButton.focus_mode=Control.FOCUS_NONE
	lButton.focus_mode=Control.FOCUS_NONE
	



func _ready():
	
	
	await get_tree().process_frame
	position_bar.material.set_shader_parameter("max_value",valueNames.size())
	
	custom_minimum_size.y=31
	
	if require_restart:
		var restart_label=Label.new()
		restart_label.text="*Requires restart to apply"
		displayText.add_child(restart_label)
		restart_label.position.y=14
		restart_label.position.x-=displayText.size.x
		restart_label.theme_type_variation="restart_label"
		
	
	displayText.force_update_transform()
	position_bar.size.x=displayText.size.x
	position_bar.size.y=4
	position_bar.position.y=displayText.size.y-1
	select_value(1)
	


func _input(event):
	if !has_focus():return
	if Input.is_action_just_pressed("left")||Input.is_action_just_pressed("ui_left"):
		select_value(max(0,selected-1))
	if Input.is_action_just_pressed("right")||Input.is_action_just_pressed("ui_right"):
		select_value(min(len(valueNames)-1,selected+1))
func select_value(index:int)->void:
	selected=index


func select_by_true_value(value:int)->void:
	for val in len(valueIndices):
		if valueIndices[val]==value:
			select_value(val)
			break
	
