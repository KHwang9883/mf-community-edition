shader_type canvas_item;

uniform float wave_amplitude = 0.0;
uniform float wave_frequency = 0.0;
uniform float wave_speed = 1.0;
varying vec4 v_vertex_color;

void vertex() {
	v_vertex_color = COLOR;
}

float calculate_diff(float uv, float amp, float freq, float spd){
	float diff_x = amp * sin((freq * uv) + (TIME * spd));
	return diff_x;
}

vec2 calculate_move(vec2 dir, float spd){
	vec2 move = dir * TIME;
	return move;
}

void fragment(){
	
	float wav_x = calculate_diff(UV.y, wave_amplitude, wave_frequency, wave_speed);
	
	if ( int( UV.y * 1.0 ) % 2 == 0)
	{
		wav_x = -wav_x;
	}
	
	vec4 textube = texture(TEXTURE, vec2(UV.x + wav_x, UV.y));

	COLOR = v_vertex_color * textube;
}