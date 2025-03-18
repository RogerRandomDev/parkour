@tool
extends ColorRect
class_name statCircle
##a circle for handling the stats to display

##a label to hold the text for the circle
@export var textContents:Label

##sets the color for the progress itself
@export var valueColor:Color:
	set(v):
		valueColor=v
		if(material):material.set_shader_parameter("valueColor",valueColor)
	get:return valueColor
##sets the color for the back of the progress
@export var backColor:Color:
	set(v):
		backColor=v
		if(material):material.set_shader_parameter("backColor",backColor)
	get:return backColor
##sets the color of the inner circle of the progress circle
@export var innerColor:Color:
	set(v):
		innerColor=v
		if(material):material.set_shader_parameter("innerColor",innerColor)
	get:return innerColor
##adjusts the thickness of the circle
@export_range(0.,0.5) var circleThickness:float:
	set(v):
		circleThickness=v
		if(material):updateDimensions()
	get:return circleThickness
##dictates whether or not to have [floatingText] when changing values
@export var drawFloatingText:bool=false
##the [Color] for the [floatingText] when decreasing the [annotation value]
@export var decreasingTextColor:Color
##max value of the circle
var max_value:float=100:
	set(v):
		max_value=v
		if(material):material.set_shader_parameter("maxValue",v)
		
	get:return max_value
##current value of the circle
var value:float=100:
	set(v):
		value=v
		if(material):material.set_shader_parameter("value",v)
		
	get:return value
##percent of the value accounted for in the line of the stat circle
@export_range(0.,1.) var linePercentage:float=0.5
##sets the halfSize of the circle in the shader
@export var circleSize:Vector2:
	set(v):
		circleSize=v
		if(material):updateDimensions()
	get:return circleSize
#the last value of value
var _lastValue:float=0.


func _init():
	var mat=ShaderMaterial.new()
	mat.shader=load("res://addons/FateFramework/GUI/statCircle/statCircle.gdshader")
	mat.setup_local_to_scene()
	material=mat
	material.set_shader_parameter("maxValue",max_value)
	material.set_shader_parameter("value",value)
	
func _ready():
	updateDimensions()
	updateText()
#updates last value to move towards the current value
func _process(delta):
	material.set_shader_parameter("lastValue",_lastValue)
	_lastValue=max(_lastValue-delta*max_value*0.25,value)


##sets the [annotation max value] for the circle and calls [method updateText]
func setMax(max:int):
	max_value=max
	updateText()

##updates the text for the circle
func updateText():
	if !textContents:return
	textContents.text="%s\n%s"%[value,max_value]


##updates current values and then calls [method updateText]
func updateValues(current:int=value,max:int=max_value,changedBy:int=0):
#	if(drawFloatingText&&changedBy<0):
#		var floatingChange:floatingText=floatingText.new()
#		floatingChange.build(
#			Vector2(randf_range(-32,32),randf_range(-32,0)),
#			Vector2.DOWN*64,
#			1.0,
#			str(abs(changedBy)),
#			decreasingTextColor,
#			0.75
#		)
#		floatingChange.position=Vector2(0,0.5).rotated(-getValueAngle())*custom_minimum_size.x+custom_minimum_size/2
#		add_child(floatingChange)
	max_value=max
	value=current
	updateText()

##returns the angle from vertical to where the [annotation Value] is cutting at
func getValueAngle()->float:
	return (value/max_value)*PI*2-PI

##updates size data in the shader to map the values correctly
func updateDimensions():
	var dimMax:float=max(size.x,size.y)
	var dimMin:float=min(size.x,size.y)
	material.set_shader_parameter("lengthOfLine",(size.x-circleSize.x/2)/size.x)
	material.set_shader_parameter("lineAccountsPercentage",linePercentage)
	material.set_shader_parameter("halfSize",circleSize/2)
	material.set_shader_parameter("circleThickness",dimMin * circleThickness)
