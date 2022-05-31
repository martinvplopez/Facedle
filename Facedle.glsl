#ifdef GL_ES
precision mediump float;
#endif


#define PI 3.14159265359
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float circle(in vec2 st,in vec2 pos, in float r){
    float d=length(st-pos);
    float c=smoothstep(r,r-.005,d);
    return c;
}

float rect(in vec2 pos,in vec2 scale){
    scale= vec2(.5)-scale*.5;
    vec2 shaper=vec2(step(scale.x, pos.x), step(scale.y, pos.y));
    shaper*= vec2(step(scale.x,1.0-pos.x), step(scale.y,1.0-pos.y));
    return shaper.x*shaper.y;

}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

void main(){
    // Coordinates normalization and centering
	vec2 st = gl_FragCoord.xy/u_resolution.x;
    st-=.5;
    st.x*=u_resolution.x/u_resolution.y;
    // Translation animation
    float c;

    /*vec2 translate = vec2(cos(u_time*u_time*2.2),sin(u_time*u_time*2.2));
    st += translate*0.05;
    if(u_time<5.){
        c= circle(st,vec2(.0, .0), .4-u_time/40.);
    }else{
        c= circle(st,vec2(.0, .0), .4);
    }
    c -= circle(st,vec2(-.15, .2), .1);
    float tRightEye=sin(u_time*3.)/10.;
    c -= circle(st,vec2(.15, .2), .1);
    c -= circle(st,vec2(.0, -.175), .2);
    vec2 pos=vec2(st.x+0.35,st.y+0.3);*/

    vec2 translate = vec2(0.6*cos(u_time*u_time*10.),0.6*sin(u_time*u_time*10.)); // variar la amplitud de la señal para controlar desenfoque
    st += translate*0.05;
    c= circle(st,vec2(.0, .0), .4);
    st = rotate2d( sin(u_time)*PI*2.) * st;
    c -= circle(st,vec2(-.15, .2), .1);
   // float tRightEye=sin(u_time*3.)/10.;
    //c -= circle(st,vec2(.15, .2), .1);
    c -= circle(st,vec2(.0, -.175), .2);
    vec2 pos=vec2(st.x+0.35,st.y+0.3);
    c-=rect(pos, vec2(sin(u_time)-0.7,0.1));
	gl_FragColor = vec4(vec3(c), 1.0);
}
