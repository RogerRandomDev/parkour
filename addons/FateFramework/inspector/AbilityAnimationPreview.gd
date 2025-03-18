@tool
extends VBoxContainer

var viewMesh
var viewParticles
var viewCamera
var viewOrigin
var activeResource
var activeTween:Tween
func _ready():
	
	viewMesh=$SubViewportContainer/SubViewport/Mesh
	viewParticles=$SubViewportContainer/SubViewport/Particles
	viewCamera=$SubViewportContainer/SubViewport/Origin/Camera3D
	viewOrigin=$SubViewportContainer/SubViewport/Origin
	$HSlider.value=95
func _input(event):
	var mPos=get_local_mouse_position()
	
	if(
		not Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or 
		not event is InputEventMouseMotion or 
		mPos.x<0 or mPos.y<0 or mPos.x>size.x or mPos.y>size.y
		):return
	viewOrigin.rotation.y+=event.relative.x*0.01
	viewOrigin.rotation.x=clamp(viewOrigin.rotation.x+event.relative.y*0.01,-PI/2,PI/2)

func _process(delta):
	var m=max($SubViewportContainer.size.x,$SubViewportContainer.size.y)
	$SubViewportContainer.size=Vector2(m,m)
	size=Vector2(m,m)
	custom_minimum_size=Vector2(m-64,m+48)

func _on_h_slider_value_changed(value):
	viewCamera.position.z=100-value

func _setResource(resource:AbilityEffectResource):
	activeResource=resource
	_loadAnim()

func _loadAnim():
	if activeResource.get("AbilityMesh"):
		viewMesh.mesh=activeResource.AbilityMesh
		activeTween=activeResource.loadAnimation(viewMesh,viewOrigin,true)
	else:
		viewParticles.process_material=activeResource.AbilityParticles
		viewParticles.draw_pass_1=activeResource.ParticlesMesh
		viewParticles.lifetime=activeResource.Lifetime
		viewParticles.explosiveness=activeResource.Explosiveness
		viewParticles.amount=activeResource.particleAmount
		activeTween=activeResource.loadAnimation(viewParticles,viewOrigin,true)
	activeTween.tween_interval(1.)
	activeTween.connect('finished',func():_loadAnim())
