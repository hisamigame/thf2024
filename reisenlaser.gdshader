shader_type canvas_item;
uniform float v = 0.1;
uniform float t0 = 0.0;
uniform float time = 0.0;
uniform float width = 0.05;
uniform float ampl = 0.3;

float pulse(float x, float thresh, float a){
	if (x < thresh && x > thresh/a){
		return 1.0-(a/(a-1.0)) * (x/thresh -1.0/a);
	}
	else if (x < thresh/a && x > -thresh/a){
		return a * (x/thresh);
	}
	else if (x > -thresh && x < -thresh/a){
		return -1.0-(a/(a-1.0))* (x/thresh +1.0/a);
	}
	else{
		return 0.0;
	}
}

//void vertex(){
//	float offset;
//	//offset = sin(UV.x-v*(time-t0)/(2.0*PI)) * 32.0;
//	offset = 100.0*pulse(UV.x-v*(time-t0), 0.25);
//	VERTEX.y = VERTEX.y - offset;
//}

void fragment(){
	vec4 color = texture(TEXTURE,UV);
	float t3 = (time-t0)*(time-t0)*(time-t0);
	float offset1 = -ampl*t3 * pulse(1.0 - UV.x-v*(time-t0), width, 3.0);
	float offset2 = -ampl/2.0*t3 * pulse(UV.x-0.5, width/1.3, 3.0);
	float offset3 = ampl/1.2*t3 * pulse(-UV.x+0.75, width/2.0, 2.0);
	float offset4 = -ampl/1.2*t3 * pulse(UV.x-0.1, width/0.6, 3.2);
	float offset5 = ampl/1.5*t3 * pulse(-UV.x+0.9, width/0.3, 4.0);
	float offset6 = -ampl/0.7*t3 * pulse(UV.x-0.3, width/0.7, 2.4);
	float offset7 = -ampl/0.7*t3 * pulse(UV.x-0.1, width/0.4, 4.0);
	float offset8 = -ampl/1.3*t3 * pulse(UV.x-0.4, width/0.4, 3.3);
	float offset9 = +ampl/1.3*t3 * pulse(-UV.x+0.6, width/0.6, 2.0);
	COLOR = color + texture(TEXTURE,UV + vec2(0.0,offset1) + vec2(0.0, offset2)+ vec2(0.0, offset3)+ vec2(0.0, offset4)+ vec2(0.0, offset5)+ vec2(0.0, offset6)+ vec2(0.0, offset7)+ vec2(0.0, offset8)+ vec2(0.0, offset9));
}
