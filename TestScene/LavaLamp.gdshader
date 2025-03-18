shader_type spatial;
render_mode unshaded,depth_prepass_alpha;
//render_mode unshaded, world_vertex_coords; // to raymarch in world space

varying vec3 world_camera;
varying vec3 world_position;

uniform float curTime;

uniform float BRIGHTNESS=10.0;
uniform float scale=1.0;
uniform float lightBlockage:hint_range(0.0,1.0);
uniform vec3 glassColor:source_color;

const int MAX_STEPS = 50;
const float MAX_DIST = 1000.0;
const float SURF_DIST = 0.001;

uniform sampler2D colorRamp:repeat_disable;
uniform sampler2D DEPTH_TEXTURE:hint_depth_texture;
uniform sampler2D panColorRamp:repeat_enable;
uniform float transitionSpeed:hint_range(-2.0,2.0);


float smoothUnionSDF(float distA, float distB, float k ) {
  float h = clamp(0.5 + 0.5*(distA-distB)/k, 0., 1.);
  return mix(distA, distB, h) - k*h*(1.-h); 
}

float smoothIntersectSDF(float distA, float distB, float k ) 
{
  float h = clamp(0.5 - 0.5*(distA-distB)/k, 0., 1.);
  return mix(distA, distB, h ) + k*h*(1.-h); 
}
float sdCappedCylinder( vec3 p, float h, float r )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
float sphereSDF(vec3 p,float s) {
    return length(p) - s;
}
float coneSDF( vec3 p, vec2 q )
{
    vec2 w = vec2( length(p.xz),p.y);
	vec2 a = w - q*clamp( dot(w,q)/dot(q,q), 0.0, 1.0);
	vec2 b = w - q*vec2( clamp( w.x/q.x, 0.0, 1.0 ), 1.0);
	float k = sign(q.y);
	float d = min(dot(a,a),dot(b,b));
	float s=max( k*(w.x*q.y-w.y*q.x),k*(w.y-q.y));
	return sqrt(d)*sign(s);
}

float GetDist(vec3 p){
	
	float shape1=sphereSDF(p+vec3(0.0,2.75,0.0)*scale,1.625*scale);
	float shape2=sphereSDF(p+vec3(sin(curTime*0.337),abs(sin(curTime*0.428))*2.0-1.2,sin(curTime*-0.989))*scale,0.5*scale);
	float shape3=sphereSDF(p+vec3(sin(curTime*-0.214),abs(sin(curTime*-0.725))*2.0-1.2,sin(curTime*0.56))*scale,0.75*scale);
	float shape4=sphereSDF(p+vec3(sin(curTime*-0.671),abs(sin(curTime*0.272))*2.0-1.2,sin(curTime*0.773))*scale,1.0*scale);
	float d = 
		smoothIntersectSDF(
		smoothUnionSDF(smoothUnionSDF(smoothUnionSDF(shape1,shape2,0.75*scale),shape3,0.75*scale),shape4,0.75*scale),
		coneSDF(p-vec3(0.0,5.0,0.0)*scale,vec2(2.5,-11.0)*scale)
		,0.05*scale);
	return d;
}
vec3 getNormal(vec3 p){
	
	float d = GetDist(p);
	vec2 e = vec2( 0.01, 0.0);
	vec3 n = d - vec3(
		GetDist(p-e.xyy),
		GetDist(p-e.yxy),
		GetDist(p-e.yyx)
	);
	return normalize(n);
}

float RayMarch(vec3 ro, vec3 rd) {
	float dO = 0.0;
	float dS;
	
	for (int i = 0; i < MAX_STEPS; i++)
	{
		vec3 p = (ro + dO * rd);
		dS = GetDist(p);
		dO += dS;
		
		if (dS < SURF_DIST || dO > MAX_DIST)
			break;
	}
	return dO;
}

void vertex() {
	world_position = VERTEX;
	world_camera = (inverse(MODELVIEW_MATRIX) * vec4(0, 0, 0, 1)).xyz; //object space
	//world_camera = ( CAMERA_MATRIX  * vec4(0, 0, 0, 1)).xyz; //uncomment this to raymarch in world space
}

void fragment() {
	
	float depth=texture(DEPTH_TEXTURE,SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	vec3 ro = world_camera;
	vec3 rd =  normalize(world_position - ro);
	
	vec3 col;
	
	float d = RayMarch(ro, rd);
	vec3 p = ro + rd * d;
	if(d>= MAX_DIST||p.y<-3.0){
		discard;
	}
	
	
	vec3 n = getNormal(p);
	float h=1.0-(p.y) * 0.25;
	float f = dot(rd,n);
	float g= f * h;
	col = texture(colorRamp,vec2(clamp(g*g,0.01,1.0))).rgb*texture(panColorRamp,vec2(curTime*transitionSpeed,0.5)).rgb*lightBlockage*glassColor;
	
	ALBEDO = col*BRIGHTNESS;
	
}