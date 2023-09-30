shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture: filter_nearest, repeat_disable;
uniform vec4 outline_color : source_color = vec4(1);
uniform float outline_width: hint_range(1.0, 3.0, 1.0) = 1.0;

void fragment()
{
    vec2 texel_size = vec2(
        outline_width/ float(VIEWPORT_SIZE.x),
        outline_width/ float(VIEWPORT_SIZE.y)
    );

	float n = 0.0;
	n += texture( screen_texture, SCREEN_UV+vec2( -texel_size.x, 0.0 ) ).a;
	n += texture( screen_texture, SCREEN_UV+vec2( texel_size.x, 0.0 ) ).a;
	n += texture( screen_texture, SCREEN_UV+vec2( 0.0, -texel_size.y ) ).a;
	n += texture( screen_texture, SCREEN_UV+vec2( 0.0, texel_size.y ) ).a;

	ALBEDO = outline_color.rgb;
    ALPHA = float(texture(screen_texture, SCREEN_UV).a < 0.01 && n > 0.0);
}
