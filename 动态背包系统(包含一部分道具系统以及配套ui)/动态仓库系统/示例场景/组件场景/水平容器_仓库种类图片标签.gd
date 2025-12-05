extends VBoxContainer

@export var 激活时颜色: = Color(1.0, 1.0, 1.0, 1.0)
@export var 失活时颜色: = Color(1.0, 1.0, 1.0, 0.3)
@export var 已被激活:bool = false


@onready var 图标按钮: TextureButton = $中心容器_图标/图标按钮

var _标签种类 :标签种类:
	set(传入种类):
		_标签种类 = 传入种类
		图标按钮.set_texture_normal(_标签种类.标签图标)
	get: return _标签种类
	

func 获取种类图片标签按钮() -> Node:
	return 图标按钮


func 高亮(强制高亮:bool = false) -> void:
	if  强制高亮 or 已被激活:
		set_modulate(激活时颜色)
		
func 去除高亮(强制去除高亮: bool = false) -> void:
	if 强制去除高亮 or not 已被激活:
		set_modulate(失活时颜色)

func 设置是否激活(设置激活:bool = true) -> void:
	已被激活 = 设置激活
	高亮() if 设置激活 else 去除高亮()
	
