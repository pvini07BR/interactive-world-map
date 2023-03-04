shader_type spatial;

uniform float reliefHeight = 0.05;

uniform sampler2D earthTexture;
uniform sampler2D heightMap;

vec2 pointOnSphereToUV(vec3 p)
{
	p = normalize(p);
	
	float longitude = atan(p.x, -p.z);
	float latitude = asin(p.y);
	
	float u = (longitude / PI + 1.0) / 2.0;
	float v = latitude / PI + 0.5;
	
	return vec2(u, v);
}

void vertex()
{
	vec4 height = texture(heightMap, pointOnSphereToUV(VERTEX));
	VERTEX += (height.xyz * NORMAL) * reliefHeight;
}

void fragment()
{
	ALBEDO = texture(earthTexture, UV).xyz;
}