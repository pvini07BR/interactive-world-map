shader_type spatial;

uniform float reliefHeight = 0.05;

uniform sampler2D earthTexture;
uniform sampler2D heightMap;

vec2 pointToUV(vec3 p)
{
	p = normalize(p);
	
	return vec2(p.x, p.y);
}

void vertex()
{
	vec4 height = texture(heightMap, UV);
	VERTEX += (height.xyz * NORMAL) * reliefHeight;
}

void fragment()
{
	ALBEDO = texture(earthTexture, UV).xyz;
}