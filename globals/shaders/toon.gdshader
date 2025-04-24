shader_type spatial;

uniform sampler2D color_ramp;
uniform vec3 color: source_color;

void light() {
	float diffuse_intensity = dot(NORMAL, LIGHT) > 0.5 ? 1.0 : 0.0;
	DIFFUSE_LIGHT = diffuse_intensity == 0.0 ? color / 2.0 : color;

	float specular_intensity = dot(NORMAL, LIGHT) > 0.990 ? 1.0 : 0.0;
	SPECULAR_LIGHT = color * 2.0 * specular_intensity;

	float rim_dot_product = 1.0 - dot(VIEW, NORMAL);
	float rim_intensity = pow(smoothstep(0.0, 2.0, rim_dot_product) * 2.0, 4);
	DIFFUSE_LIGHT += rim_intensity;

	float dotnl = dot(NORMAL, LIGHT);
	float sample_position = max((dotnl + 1.0) / 2.01, 0.01);
	vec4 ramp_light = texture(color_ramp, vec2(sample_position, 0.0));
	vec3 diffuse_light = ramp_light.rgb * clamp(LIGHT_COLOR * ATTENUATION, vec3(0,0,0), vec3(1,1,1));
	DIFFUSE_LIGHT = max(diffuse_light, DIFFUSE_LIGHT);
}