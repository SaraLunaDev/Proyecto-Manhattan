shader_type spatial;
render_mode unshaded;
uniform sampler2D iChannel0;
uniform float iTime;
uniform vec3 water_color : source_color = vec3(0.1, 0.4, 0.5);
uniform vec2 water_direction = vec2(1.0, 0.5);
uniform float speed1 = 0.03;
uniform float speed2 = 0.01;

void fragment()
{
    vec2 uv = UV;

    vec2 n64Res = vec2(160.0, 120.0);
    uv = floor(uv * n64Res) / n64Res;

    vec2 dir = water_direction;
    dir = dir * 0.5 + 0.5;

    float time1 = iTime * speed1;
    float time2 = iTime * speed2;

    vec2 uv1 = uv + dir * time1;
    vec2 uv2 = uv - dir.yx * time2;

    vec4 layer1 = texture(iChannel0, uv1);
    vec4 layer2 = texture(iChannel0, uv2);

    vec3 waterPattern = layer1.rgb * layer2.rgb * 2.0;

    vec3 finalColor = water_color + waterPattern * 0.35;

    float highlights = smoothstep(0.4, 0.8, waterPattern.r);
    finalColor += highlights * 0.25;
	
    ALBEDO = finalColor;
}