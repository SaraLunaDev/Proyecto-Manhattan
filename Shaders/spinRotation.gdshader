shader_type spatial;

uniform vec3 color = vec3(0.0);
const float lim = 0.0;
const float speed = 2.5;
uniform float alpha = 0.5;
uniform vec3 emission : source_color = vec3(0.1, 0.4, 0.5);
uniform vec3 spin_color : source_color = vec3(0.1, 0.4, 0.5);

void fragment() {
	ALBEDO = spin_color;
	EMISSION = emission;
	
	float angle = TIME * speed;
	float x = cos(angle)*(UV.x-0.5) + sin(angle)*(UV.y-0.5);
	float y = -sin(angle)*(UV.x-0.5) + cos(angle)*(UV.y-0.5);
	
	float dist = sqrt(pow(x, 2) + pow(y, 2));
	if(dist < 0.5){
		ALPHA = 0.25 - (((pow(x, 2)/dist) - pow(y, 2)/2.0) * 5.0);
		ALPHA /= 2.0;
		if(ALPHA < lim){
			ALPHA = lim;
		};
		ALPHA += 0.15 * alpha;
	}else{ ALPHA = 0.0; }
	
	
}
