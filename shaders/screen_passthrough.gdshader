shader_type canvas_item;

uniform sampler2D source;

void fragment() {
    COLOR = texture(source, UV);
}