shader_type spatial;

uniform float pyramid_height : hint_range(0.0, 1.0) = 0.5; // Height of the pyramid
uniform vec4 base_color = vec4(1.0, 1.0, 1.0, 1.0);  // Base color for the ceiling
uniform float roughness;  // Roughness value
uniform float metallic;  // Metallic value
uniform sampler2D height_noise;
uniform sampler2D normal_noise;
uniform float height_scale = 0.5;
varying vec2 uv;


void vertex() {
	// Normalize the vertex positions to be between -1 and 1
    uv = VERTEX.xz;

    // Normalize the x and z coordinates relative to the rectangular base size
    float distance_x = abs(uv.x);
    float distance_z = abs(uv.y);

    // Compute the distance to the corner: Use the Euclidean distance formula
	
    float corner_distance = sqrt(pow(distance_x, 2.0) + pow(distance_z, 2.0));
	
	float height = texture(height_noise, uv / 2.0 + 0.5).x;
    // Scale the vertex along the z-axis to form a square-based pyramid
	VERTEX.y += (1.0 - corner_distance) * pyramid_height;
	VERTEX.y -= height * height_scale;
	vec3 normal = vec3(VERTEX.x, VERTEX.y + (height * height_scale) + ((1.0 - corner_distance) * pyramid_height), VERTEX.z);
	NORMAL = normal;
}

void fragment() {
	// Called for every pixel the material is visible on.

	// Set the base color of the ceiling
    ALBEDO = base_color.rgb;

    // Set roughness of the material
    ROUGHNESS = roughness;
	METALLIC = metallic;
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
