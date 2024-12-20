// By snesmocha
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment(){
    COLOR = vec4(texture(screen_texture, SCREEN_UV).rgb, texture(TEXTURE, UV).a);
}