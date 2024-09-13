shader_type spatial;

uniform float height_scale;
uniform sampler2D noise;
uniform sampler2D normalmap;
uniform vec3 albedo;

varying vec2 tex_position;

void vertex() {
	VERTEX.y += cos(VERTEX.x / 10.0) * sin(VERTEX.z / 10.0) - 1.0;
	float height = texture(noise, UV).x;
	tex_position = VERTEX.xz / 2.0 + 0.5;
	VERTEX.y += height;
	VERTEX.y *= height_scale;
}

void fragment() {
	float noise_map = texture(noise, UV).r;
	ALBEDO = albedo;
	ALBEDO *= vec3(noise_map);
	METALLIC = -0.2;
  	ROUGHNESS = 0.9;
	NORMAL_MAP = texture(normalmap, tex_position).xyz;
}

