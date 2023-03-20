shader_type spatial;

uniform sampler2D heightMap;
uniform sampler2D normalMap;
uniform sampler2D boundariesTexture;

uniform sampler2D oceanGradientColor;
uniform float reliefFactor : hint_range(0, 1) = 0.0;
//uniform highp float heightMin = -11034.0;
uniform highp float heightMin = -8848.0;
uniform highp float heightMax = 8848.0;
uniform highp float seaLevel : hint_range(-8848, 8848.0) = 0.0;

float map(float value, float min1, float max1, float min2, float max2) {
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void vertex() {
	vec3 tex = texture(heightMap, UV).rgb;
	float height = (tex.r + tex.g + tex.b) / 3.0;
	VERTEX += (NORMAL * height) * reliefFactor;
}

void fragment() {
	vec4 bounds = texture(boundariesTexture, UV);
	
	vec3 tex = texture(heightMap, UV).rgb;
	float height = (tex.r + tex.g + tex.b) / 3.0;
	
	//float heightMin = -10894.0;
	//highp float heightMetres = heightMin + ((heightMax - heightMin) * height);
	highp float heightMetres = map(height, 0.0, 1.0, heightMin, heightMax);
	
	if (heightMetres < seaLevel)
	{
		float s = (seaLevel - heightMetres) / (heightMax - heightMin);
		ROUGHNESS = 0.30;
		vec3 o = texture(oceanGradientColor, vec2(s, 0.5)).rgb;
		NORMAL_MAP_DEPTH = height/4.0;
		tex = o;
	}
	else
	{
		NORMAL_MAP_DEPTH = 1.0;
		tex = vec3(height);
	}
	
	tex *= mix(vec3(1.0), bounds.rgb, bounds.a);
	
	ALBEDO = tex;
	NORMAL_MAP = texture(normalMap, UV).rgb;
}
