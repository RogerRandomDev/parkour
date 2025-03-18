@tool
extends ShaderMaterial
class_name FateMaterial

func _init():
	shader=load("res://addons/FateFramework/Environment/fateMaterial.gdshader")
	var mat=ShaderMaterial.new()
	mat.shader=load("res://addons/FateFramework/Environment/shadowMat.gdshader")
	next_pass=mat
