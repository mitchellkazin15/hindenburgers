// NOTE: Shader automatically converted from Godot Engine 4.6.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform float cell_size : hint_range(0.1, 10.0) = 2.0;
uniform float rotation_strength : hint_range(0.0, 1.0) = 1.0;

vec2 hash22(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)),
	        dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453);
}

vec4 sample_cell(sampler2D tex, vec2 uv, vec2 cell) {
	vec2 r = hash22(cell);
	float a = r.x * 6.2831853 * rotation_strength;
	mat2 rot = mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)));
	// Rotate around the cell center so the offset stays inside a tile.
	vec2 centered = uv - (cell + 0.5);
	return texture(tex, rot * centered + r);
}

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV / cell_size;
	
	vec2 cell = floor(base_uv);
	vec2 f = fract(base_uv);

	vec4 c00 = sample_cell(texture_albedo, base_uv, cell);
	vec4 c10 = sample_cell(texture_albedo, base_uv, cell + vec2(1.0, 0.0));
	vec4 c01 = sample_cell(texture_albedo, base_uv, cell + vec2(0.0, 1.0));
	vec4 c11 = sample_cell(texture_albedo, base_uv, cell + vec2(1.0, 1.0));

	vec4 mixed = mix(mix(c00, c10, f.x), mix(c01, c11, f.x), f.y);
	ALBEDO = mixed.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
}
