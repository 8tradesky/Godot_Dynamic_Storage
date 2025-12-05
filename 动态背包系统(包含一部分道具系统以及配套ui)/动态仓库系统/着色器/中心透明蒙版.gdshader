shader_type canvas_item;

// 定义蒙版颜色，可以在编辑器中调整
uniform vec4 mask_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// 控制整体透明度强度
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.5;
// 控制渐变范围
uniform float gradient_radius : hint_range(0.0, 1.0) = 0.6;
// 控制中间是否更透明 (true=中间更透明, false=中间更不透明)
instance uniform bool center_more_transparent = false;
// 控制中间区域的透明度 (当center_more_transparent为true时生效)
uniform float center_alpha : hint_range(0.0, 1.0) = 0.0;
// 控制边缘区域的透明度 (当center_more_transparent为false时生效)
uniform float edge_alpha : hint_range(0.0, 1.0) = 0.5;
// 混合模式：0=正常，1=叠加，2=相乘，3=变亮，4=变暗
uniform int blend_mode : hint_range(0, 4) = 0;

// 混合函数
vec4 blend(vec4 base, vec4 blend, float alpha) {
    vec4 result;
    
    if (blend_mode == 0) {
        // 正常混合
        result = mix(base, blend, alpha);
    } else if (blend_mode == 1) {
        // 叠加混合
        result = vec4(
            (blend.r < 0.5) ? (2.0 * base.r * blend.r) : (1.0 - 2.0 * (1.0 - base.r) * (1.0 - blend.r)),
            (blend.g < 0.5) ? (2.0 * base.g * blend.g) : (1.0 - 2.0 * (1.0 - base.g) * (1.0 - blend.g)),
            (blend.b < 0.5) ? (2.0 * base.b * blend.b) : (1.0 - 2.0 * (1.0 - base.b) * (1.0 - blend.b)),
            base.a
        );
    } else if (blend_mode == 2) {
        // 相乘混合
        result = vec4(base.rgb * blend.rgb, base.a);
    } else if (blend_mode == 3) {
        // 变亮混合
        result = vec4(
            max(base.r, blend.r),
            max(base.g, blend.g),
            max(base.b, blend.b),
            base.a
        );
    } else if (blend_mode == 4) {
        // 变暗混合
        result = vec4(
            min(base.r, blend.r),
            min(base.g, blend.g),
            min(base.b, blend.b),
            base.a
        );
    }
    
    return result;
}

void fragment() {
    // 获取原始纹理颜色
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 计算从中心到当前像素的距离
    vec2 center = vec2(0.5, 0.5);
    float distance_from_center = length(UV - center);
    
    float alpha;
    
    if (center_more_transparent) {
        // 中间更透明，边缘更不透明
        // 使用smoothstep创建从中心到边缘的渐变
        alpha = mix(center_alpha, edge_alpha, smoothstep(0.0, gradient_radius, distance_from_center));
    } else {
        // 中间更不透明，边缘更透明
        // 使用smoothstep创建从边缘到中心的渐变
        alpha = mix(edge_alpha, center_alpha, smoothstep(0.0, gradient_radius, distance_from_center));
    }
    
    // 应用整体透明度强度
    alpha *= alpha_strength;
    
    // 将遮罩颜色与底图颜色混合
    vec4 blended_color = blend(tex_color, mask_color, alpha);
    
    // 设置最终颜色
    COLOR = vec4(blended_color.rgb, tex_color.a * alpha);
}