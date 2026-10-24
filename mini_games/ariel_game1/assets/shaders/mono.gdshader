shader_type canvas_item;

// --- 追加された変数 ---
uniform float intensity : hint_range(0.0, 1.0) = 1.0; // 0.0で無効、1.0で最大

uniform bool dithering = true;
uniform int dithering_size = 10;
uniform int resolution_scale = 2;
uniform float threshold = 60.0;
uniform vec4 white: source_color = vec4(1,1,1,1);
uniform vec4 black: source_color = vec4(0,0,0,1);

int dithering_pattern(ivec2 fragcoord) {
	const int pattern[] = {
		-4, +0, -3, +1,
		+2, -2, +3, -1,
		-3, +1, -4, +0,
		+3, -1, +2, -2
	};
	int x = fragcoord.x % 4;
	int y = fragcoord.y % 4;
	return pattern[y * 4 + x] * dithering_size;
}

void fragment() {
	// 元の画面の色を保持
	vec4 original_col = texture(TEXTURE, UV);
	
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	
	// intensityに合わせて解像度スケールを調整（0.0のときは1.0になるように）
	float current_scale = mix(1.0, float(resolution_scale), intensity);
	
	vec2 low_res_pixel = floor(UV * tex_size / current_scale);
	vec2 sampled_uv = (low_res_pixel * current_scale) / tex_size;
	
	vec3 color = texture(TEXTURE, sampled_uv).rgb;
	ivec3 c = ivec3(round(color * 255.0));

	if (dithering) {
		// intensityに合わせてディザリングの適用度も変える
		int d_pattern = dithering_pattern(ivec2(low_res_pixel));
		c += int(float(d_pattern) * intensity);
	}

	float avg = float(c.x + c.y + c.z) / 3.0;
	
	// 1-bit化した色を決定
	vec4 bit_col = (avg < threshold) ? black : white;

	// 元の色と1-bit化した色をintensityで混ぜる
	COLOR = mix(original_col, bit_col, intensity);
}