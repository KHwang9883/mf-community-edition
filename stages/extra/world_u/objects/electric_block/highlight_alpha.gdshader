shader_type canvas_item;
render_mode unshaded;

// The color that flashes when highlighting the sprite
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Used to control the time between flashes
uniform float frequency : hint_range(0.0, 25.0) = 0.35;

// Speed of each flash
uniform float highlight_speed : hint_range(0.0, 25.0) = 6.0;

// How much area each flash covers (width)
uniform float highlight_width : hint_range(0.0, 50.0) = 15.0;

varying vec4 v_vertex_color;

void vertex() {
    v_vertex_color = COLOR;
}

void fragment() {
    vec4 input_color = texture(TEXTURE, UV);
    float width = 0.001 * frequency * highlight_width / 2.0;

    // Control the movement of the highlight
    float value = max(0.0, floor(sin(frequency * ((-UV.x - UV.y) + TIME * highlight_speed)) + width));

    // New color blending while considering alpha transparency
	vec3 computed_color = abs(value) < 0.0001 ? v_vertex_color.rgb * input_color.rgb : input_color.rgb;
    vec3 new_color = mix(computed_color, highlight_color.rgb, value * highlight_color.a);

    // Set the final color
    COLOR = vec4(new_color, input_color.a);
}
