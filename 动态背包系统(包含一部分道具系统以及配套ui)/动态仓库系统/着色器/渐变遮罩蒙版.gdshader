shader_type canvas_item;

// 渐变设置
uniform int gradient_type : hint_range(0, 1) = 0; // 0=两色, 1=三色
uniform vec4 color1 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 color3 : source_color = vec4(0.0, 0.0, 1.0, 1.0);

// 渐变方向 (0=垂直, 1=水平, 2=左下到右上, 3=左上到右下)
uniform int gradient_direction : hint_range(0, 3) = 0;

// 全局透明度控制
uniform float global_alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // 获取原始纹理颜色
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 计算渐变权重
    float weight = 0.0;
    
    if (gradient_direction == 0) {
        // 垂直渐变
        weight = UV.y;
    } else if (gradient_direction == 1) {
        // 水平渐变
        weight = UV.x;
    } else if (gradient_direction == 2) {
        // 左下到右上渐变
        weight = (UV.x + UV.y) * 0.5;
    } else {
        // 左上到右下渐变
        weight = (UV.x + (1.0 - UV.y)) * 0.5;
    }
    
    // 根据渐变类型混合颜色
    vec4 gradient_color;
    if (gradient_type == 0) {
        // 两色渐变
        gradient_color = mix(color1, color2, weight);
    } else {
        // 三色渐变
        if (weight < 0.5) {
            gradient_color = mix(color1, color2, weight * 2.0);
        } else {
            gradient_color = mix(color2, color3, (weight - 0.5) * 2.0);
        }
    }
    
    // 结合渐变颜色和原始纹理的透明度，应用全局透明度
    COLOR = vec4(gradient_color.rgb, tex_color.a * global_alpha);
}