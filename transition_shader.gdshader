shader_type canvas_item;
render_mode unshaded;

uniform float cutoff :  hint_range(0.0,1.0) = 1.0;
uniform sampler2D mask: hint_albedo;


void fragment(){
	vec4 color =  texture(TEXTURE,UV);
	float value = texture(mask, UV).r;
	float alpha = step(cutoff, value);
	COLOR = vec4(color.rgb, color.a*alpha);

}