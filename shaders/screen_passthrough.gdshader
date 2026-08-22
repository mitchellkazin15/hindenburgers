shader_type canvas_item;

uniform sampler2D source;

void fragment() {
	// Force opaque. The history SubViewports use CLEAR_MODE_NEVER, so any alpha
	// below 1 in the source would turn them into additive accumulators that
	// saturate to white over a few frames.
	COLOR = vec4(texture(source, UV).rgb, 1.0);
}
