shader_type spatial;

uniform float height_scale;
uniform sampler2D noise;
uniform sampler2D normalmap;
uniform vec3 albedo;

varying vec2 tex_position;

void vertex() {
	VERTEX.y += (cos(VERTEX.x / 100.0) * sin(VERTEX.z / 100.0) * 10.0) - ( cos(VERTEX.x / 70.0) * sin(VERTEX.z / 70.0) * 8.0);
	float height = texture(noise, UV).x;
	tex_position = VERTEX.xz / 2.0 + 0.5;
	VERTEX.y += height;
	VERTEX.y *= height_scale;
}

void fragment() {
	float noise_map = texture(noise, UV).r;
	ALBEDO = albedo;
	ALBEDO *= vec3(noise_map) * 0.5;
	METALLIC = -0.2;
  	ROUGHNESS = 0.9;
	NORMAL_MAP = texture(normalmap, tex_position).xyz;
}
