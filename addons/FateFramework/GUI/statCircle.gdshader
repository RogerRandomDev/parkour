shader_type canvas_item;

uniform vec3 backColor:source_color;
uniform vec3 valueColor:source_color;
uniform vec3 lastValueColor:source_color=vec3(1.);


uniform int maxValue=100;
uniform int value=50;
uniform int lastValue=50;
uniform float lengthOfLine:hint_range(0.,1.)=0.75;
uniform float lineAccountsPercentage:hint_range(0.,1.)=0.5;

uniform float circleThickness=32.;
uniform int borderThickness=4;


uniform vec2 halfSize=vec2(48.,48.);

varying float curStraightVal;
varying float lastStraightVal;
varying float angle;
varying float lastAngle;
varying vec2 corner;


void vertex(){
	if(VERTEX_ID==0){
		corner.xy=VERTEX.xy;
	}
	int workingValue=maxValue-value;
	curStraightVal=1.-(float(workingValue)/(float(maxValue)*lineAccountsPercentage));
	lastStraightVal=1.-(float(maxValue-lastValue)/(float(maxValue)*lineAccountsPercentage));
	angle=((float(workingValue)-(float(maxValue)*lineAccountsPercentage))/(float(maxValue)))*PI*2. /(1.-lineAccountsPercentage);
	lastAngle=((float(maxValue-lastValue)-(float(maxValue)*lineAccountsPercentage))/float(maxValue))*PI*2. /(1.-lineAccountsPercentage);
	corner.x=max(corner.x,VERTEX.x);
	corner.y=max(corner.y,VERTEX.y);
}
void fragment() {
	vec2 trueUV=(FRAGCOORD.xy-corner.xy);
	
	float dist=distance(SCREEN_UV.xy-halfSize+corner.xy,vec2(0.));
	
	float curAngle=atan(SCREEN_UV.x-halfSize.x+corner.x,SCREEN_UV.y-halfSize.y+corner.y)+PI;
	
	bool straightLine=(
		SCREEN_UV.y+corner.y<halfSize.y-circleThickness&&
		SCREEN_UV.y+corner.y>halfSize.y-halfSize.x&&
		UV.x>1.-lengthOfLine);
	
	float straightValue=(UV.x-(1.-lengthOfLine))/lengthOfLine;
	
	
	
	COLOR.rgba=vec4(
		(straightLine?
			(straightValue<curStraightVal?valueColor:(straightValue<lastStraightVal?lastValueColor:backColor)):
			(angle>curAngle?(lastAngle>curAngle?backColor:lastValueColor):valueColor)),
		float(dist<halfSize.x*1.&&dist>circleThickness||straightLine)
		);
	COLOR.rgb*=float(dist<halfSize.x-float(borderThickness)&&dist<halfSize.x-float(borderThickness)||
		SCREEN_UV.y+corner.y<halfSize.y-circleThickness-float(borderThickness)&&
		SCREEN_UV.y+corner.y>halfSize.y-halfSize.x+float(borderThickness)&&
		UV.x>1.-(lengthOfLine+float(borderThickness)*SCREEN_PIXEL_SIZE.x)&&
		UV.x<1.-float(borderThickness)*SCREEN_PIXEL_SIZE.x*4.);
}
