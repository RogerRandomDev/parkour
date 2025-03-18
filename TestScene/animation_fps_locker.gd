extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var anim:Animation=load('res://walkingAnim.tres')
	var track_count:int=anim.get_track_count()
	var skip_by=0
	for i in track_count:
		var key_count=anim.track_get_key_count(i)
		anim.track_set_interpolation_type(i,Animation.INTERPOLATION_NEAREST)
		skip_by=0
		for j in key_count:
			var rounded=floor(anim.track_get_key_time(i,j-skip_by)*12)
			if abs(anim.track_get_key_time(i,j-skip_by)*12-rounded)>0.05:
				anim.track_remove_key(i,j-skip_by)
				skip_by+=1
	ResourceSaver.save(anim)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
