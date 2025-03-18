extends Label
class_name floatingText
##a floating [Label] which will move and fall in the specified manner[br]
##primarily used by the [statCircle] for when the stat changes

##starting direction the text moves in
var startDirection:Vector2
##direction the text is pulled in
var pullDirection:Vector2
##life of the text in seconds
var lifetime:float
#defines the amount of time currently lived
var _curLife:float=0.
##damping value
var damping:float=0.

func _process(delta):
	_curLife+=delta
	position+=startDirection*delta
	startDirection+=(pullDirection-(startDirection*(damping)))*delta
	pullDirection-=pullDirection*(damping)*delta
	if _curLife>=lifetime:queue_free()

##sets the values for the [floatingText]
func build(startDir:Vector2,pullDir:Vector2,life:float,txt:String,color:Color,damp:float)->void:
	startDirection=startDir
	pullDirection=pullDir
	lifetime=life
	text=txt
	damping=damp
	add_theme_color_override("font_color",color)
