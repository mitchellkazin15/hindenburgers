shader_type spatial;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
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

void fragment() {
	vec2 uv = UV / cell_size;
	vec2 cell = floor(uv);
	vec2 f = fract(uv);

	vec4 c00 = sample_cell(albedo_tex, uv, cell);
	vec4 c10 = sample_cell(albedo_tex, uv, cell + vec2(1.0, 0.0));
	vec4 c01 = sample_cell(albedo_tex, uv, cell + vec2(0.0, 1.0));
	vec4 c11 = sample_cell(albedo_tex, uv, cell + vec2(1.0, 1.0));

	vec4 mixed = mix(mix(c00, c10, f.x), mix(c01, c11, f.x), f.y);
	ALBEDO = mixed.rgb;
}