shader_type canvas_item;
uniform float offset;
uniform vec2 direction = vec2(1.0, 1.0);

void vertex() {
	UV  = UV + direction * offset * TIME;
}