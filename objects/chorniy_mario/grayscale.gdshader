shader_type canvas_item;

uniform float offset = 0.0;
varying vec4 v_vertex_color;

void vertex() {
	v_vertex_color = COLOR;
}

void fragment() {
	COLOR = v_vertex_color * texture(TEXTURE, UV);
	float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0 + offset;
	COLOR.rgb = vec3(avg);
}