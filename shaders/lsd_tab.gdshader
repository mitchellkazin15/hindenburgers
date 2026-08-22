shader_type spatial;

uniform sampler2D fractal_noise_texture : repeat_enable, filter_linear;
uniform float fractal_chromatic_shift_strength = 0.0;

void fragment() {
	vec3 noise_sample = texture(fractal_noise_texture, UV).rgb;
	float luminance = dot(noise_sample, vec3(0.299, 0.587, 0.114));

	vec3 shift_color;
	shift_color.r = fractal_chromatic_shift_strength * clamp(1.0 - 2.0 * luminance, 0.0, 1.0);
	shift_color.g = fractal_chromatic_shift_strength * clamp(1.0 - abs(2.0 * luminance - 1.0), 0.0, 1.0);
	shift_color.b = fractal_chromatic_shift_strength * clamp(2.0 * luminance - 1.0, 0.0, 1.0);
	ALBEDO.rgb = shift_color;
}
