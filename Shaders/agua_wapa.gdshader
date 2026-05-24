// Joseada historica de codigo es este shader, no entiendo una mierda pero funca.
// Metele los siguientes parametros para que vaya bien:
// COLOR1: #96fbc7
// COLOR2: #f7ffae
// COLOR3: #ffb3cb
// COLOR4: #d8bfd8
// metallic: 0.0
// roughness: 0.0
// scale: 4.0
// speed: 0.1 (se puede jugar con ella por si marea)
// distorsion: 3.635
// wave heigh: 0.0
// wave speed: 2.0
// wave frequency: 0.0
// Ademas de esto crea un segundo directional light que solo afecte a la layer 2
// (dentro de Light3D > Cull Mask > solo activo el botÃ³n 2)
// luego selecciona la mesh del suelo y en GeometryInstance3D > Global Illumination > Botones activos 1 y 2

shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back;
uniform vec4 color_1 : source_color = vec4(0.05, 0.25, 0.70, 1.0);
uniform vec4 color_2 : source_color = vec4(0.08, 0.45, 0.90, 1.0);
uniform vec4 color_3 : source_color = vec4(0.15, 0.60, 0.95, 1.0);
uniform vec4 color_4 : source_color = vec4(0.85, 0.95, 1.0, 1.0);
uniform float metallic = 0.5;
uniform float roughness = 0.5;
uniform float scale = 5.0;
uniform float speed = 0.25;
uniform float distortion = 0.2;
uniform float wave_height = 0.15;
uniform float wave_speed = 1.5;
uniform float wave_frequency = 1.2;

float random(vec2 st) {
    return fract(
        sin(dot(st.xy, vec2(12.9898, 78.233)))
        * 43758.5453123
    );
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x)
        + (c - a) * u.y * (1.0 - u.x)
        + (d - b) * u.x * u.y;
}

void vertex() {
    vec3 world_pos =
        (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    float wave =
        sin(world_pos.x * wave_frequency + TIME * wave_speed)
        *
        cos(world_pos.z * wave_frequency + TIME * wave_speed);

    VERTEX.y += wave * wave_height;
}

void fragment() {

    vec2 uv = UV * scale;
    vec2 flow_a = vec2(
        TIME * speed,
        TIME * speed * 0.7
    );

    vec2 flow_b = vec2(
        -TIME * speed * 0.6,
        TIME * speed * 0.4
    );

    float distort_x = noise(uv * 2.0 + flow_a);
    float distort_y = noise(uv * 2.0 + flow_b);

    vec2 distorted_uv = uv;

    distorted_uv += vec2(
        distort_x - 0.5,
        distort_y - 0.5
    ) * distortion;

    float pattern =
        sin(distorted_uv.x * 1.7)
        + cos(distorted_uv.y * 1.3)
        + sin((distorted_uv.x + distorted_uv.y) * 0.8);

    pattern = pattern / 3.0;
    pattern = pattern * 0.5 + 0.5;

    vec3 water_color;
    if (pattern < 0.25) {
        water_color = color_1.rgb;
    }
    else if (pattern < 0.5) {
        water_color = color_2.rgb;
    }
    else if (pattern < 0.75) {
        water_color = color_3.rgb;
    }
    else {
        water_color = color_4.rgb;
    }

    float shine = smoothstep(
        0.75,
        1.0,
        sin(
            (distorted_uv.x + distorted_uv.y)
            * 4.0
            + TIME * 2.0
        ) * 0.5 + 0.5
    );

    water_color += shine * 0.04;

    ALBEDO = water_color;
    METALLIC = metallic;
    ROUGHNESS = roughness;
}