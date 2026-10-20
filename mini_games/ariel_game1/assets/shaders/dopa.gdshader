
shader_type canvas_item;
render_mode unshaded, blend_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform vec2 screen_size = vec2(1920.0, 1080.0);
uniform vec2 hit_center = vec2(0.5, 0.5);

uniform float effect_amount : hint_range(0.0, 1.5) = 0.0;
uniform float wave_progress : hint_range(0.0, 1.0) = 0.0;
uniform float effect_time = 0.0;

// 各演出の強さ
uniform float chromatic_strength = 0.012;
uniform float glitch_strength = 0.018;
uniform float wave_strength = 0.035;
uniform float pixel_strength = 0.65;
uniform float flash_strength = 0.75;
uniform float scanline_strength = 0.10;

// フラッシュの色
uniform vec4 flash_color : source_color = vec4(1.0, 0.95, 1.0, 1.0);

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float e = clamp(effect_amount, 0.0, 1.5);

    // 画面解像度に合わせてピクセル化
    float pixel_size = 1.0 + pixel_strength * e * 18.0;
    vec2 pixel_uv = floor(uv * screen_size / pixel_size)
                  * pixel_size / screen_size;

    // ヒット地点から広がる衝撃波
    vec2 radial = uv - hit_center;
    float dist = length(radial);
    vec2 direction = radial / max(dist, 0.0001);

    float radius = wave_progress * 1.15;
    float ring_dist = dist - radius;
    float ring = exp(
        -pow(ring_dist / 0.018, 2.0)
    );
    ring *= sin(wave_progress * 3.14159);

    vec2 wave_uv = pixel_uv
        - direction * ring * wave_strength * e;

    // 横方向のグリッチ
    float row = floor(uv.y * screen_size.y / 5.0);
    float row_noise = hash21(vec2(row, floor(effect_time * 50.0)));

    float glitch_band = step(0.90, row_noise);
    float glitch_offset = (
        hash21(vec2(row, floor(effect_time * 90.0))) - 0.5
    ) * glitch_strength * e * glitch_band;

    wave_uv.x += glitch_offset;

    // RGBチャンネルをずらす
    float chroma = chromatic_strength * e
                 * (1.0 + ring * 1.5);

    vec2 chroma_offset = direction * chroma;

    float r = texture(
        screen_texture, wave_uv + chroma_offset
    ).r;

    vec4 original = texture(screen_texture, wave_uv);

    float b = texture(
        screen_texture, wave_uv - chroma_offset
    ).b;

    vec3 color = vec3(r, original.g, b);

    // CRT風の走査線
    float scan = 0.5 + 0.5 * sin(uv.y * screen_size.y * 3.14159);
    color *= 1.0 - scanline_strength * e * scan;

    // 衝撃波のリングを発光色で重ねる
    color += vec3(0.25, 0.65, 1.0) * ring * e * 0.45;

    // ヒット直後に強く、急速に減衰するフラッシュ
    float flash = pow(clamp(e, 0.0, 1.0), 4.0)
                * flash_strength;

    color = mix(color, flash_color.rgb, clamp(flash, 0.0, 1.0));

    // 最終出力
    COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}
