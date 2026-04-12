shader_type canvas_item;

uniform vec4 water_color : source_color;
uniform vec4 deep_water_color : source_color;
uniform sampler2D surface_noise_texture : repeat_enable, filter_linear;
uniform sampler2D depth_noise_texture : repeat_enable, filter_linear;
uniform float surface_x_frequency = 1.0;
uniform float surface_y_frequency = 1.0;
uniform float surface_x_amplitude = 1.0;
uniform float surface_y_amplitude = 1.0;
uniform float depth_x_frequency = 1.0;
uniform float depth_y_frequency = 1.0;
uniform float depth_x_amplitude = 1.0;
uniform float depth_y_amplitude = 1.0;
uniform float surface_distortion = 1.5;
uniform float depth_distortion = 1.5;


void fragment() {
    vec2 texel_size = SCREEN_PIXEL_SIZE; // The size of one texel

	vec2 surface_sample_pos = vec2(UV.x + surface_x_amplitude * sin(surface_x_frequency * TIME / PI), UV.y + surface_y_amplitude * sin(surface_y_frequency * TIME / PI));

	vec2 depth_sample_pos = vec2(UV.x + depth_x_amplitude * sin(depth_x_frequency * TIME / PI), UV.y + depth_y_amplitude * sin(depth_y_frequency * TIME / PI));

	float surface_x_grad = texture(surface_noise_texture, surface_sample_pos + vec2(texel_size.x, 0.0)).r -
					texture(surface_noise_texture, surface_sample_pos - vec2(texel_size.x, 0.0)).r;
	float surface_y_grad = texture(surface_noise_texture, surface_sample_pos + vec2(0.0, texel_size.x)).r -
					texture(surface_noise_texture, surface_sample_pos - vec2(0.0, texel_size.x)).r;
	vec2 surface_grad = vec2(surface_x_grad, surface_y_grad);

	float depth_x_grad = texture(depth_noise_texture, depth_sample_pos + vec2(texel_size.x, 0.0)).r -
					texture(depth_noise_texture, depth_sample_pos - vec2(texel_size.x, 0.0)).r;
	float depth_y_grad = texture(depth_noise_texture, depth_sample_pos + vec2(0.0, texel_size.x)).r -
					texture(depth_noise_texture, depth_sample_pos - vec2(0.0, texel_size.x)).r;
	vec2 depth_grad = vec2(depth_x_grad, depth_y_grad);

	vec4 surface_noise = texture(surface_noise_texture, surface_sample_pos + surface_distortion * depth_grad);
	vec4 depth_noise = texture(depth_noise_texture, depth_sample_pos + depth_distortion * depth_grad);
	COLOR = surface_noise.r * water_color + depth_noise.r * deep_water_color;
}
