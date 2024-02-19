shader_type canvas_item;
render_mode unshaded;

uniform float cutoff :  hint_range(0.0,1.0) = 1.0;
uniform sampler2D mask: hint_albedo;
uniform vec4 flash_color : hint_color = vec4(1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment(){
	vec4 color =  texture(TEXTURE,UV);
	color.rgb = mix(color.rgb, flash_color.rgb, flash_modifier);
	float value = texture(mask, UV).r;
	float alpha = step(cutoff, value);
	COLOR = vec4(color.rgb, alpha*color.a);

}