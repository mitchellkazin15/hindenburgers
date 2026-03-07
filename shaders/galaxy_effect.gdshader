shader_type canvas_item;

uniform sampler2D star_texture : repeat_enable, filter_linear;
uniform vec4 star_color: source_color;
uniform float star_threshold = 0.95;
uniform vec2 star_velocity;
uniform float twinkle_amplitude = 0.02;
uniform float twinkle_freq;

uniform sampler2D galaxy_texture : repeat_enable, filter_linear;
uniform vec4 galaxy_color: source_color;
uniform vec2 galaxy_velocity;

void fragment() {
	vec4 star_sample = texture(star_texture, UV + star_velocity * TIME);
	COLOR = star_color * star_sample * 100000.0 * step(star_threshold + twinkle_amplitude * sin(TIME * twinkle_freq / TAU), star_sample.r);
	COLOR += galaxy_color * texture(galaxy_texture, UV + galaxy_velocity * TIME);
}
