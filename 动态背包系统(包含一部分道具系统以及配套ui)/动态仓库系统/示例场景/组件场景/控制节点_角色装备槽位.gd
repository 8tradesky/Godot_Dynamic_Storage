extends 基类_持有物品的UI

@export var 本格装备种类:Array[全局物品种类.枚举_仓库物品种类枚举] = []


var 正常物品背景颜色 := preload("res://动态仓库系统/示例图片/其他图标/白色底图.png")
var 装备物品背景颜色 := preload("res://动态仓库系统/示例图片/其他图标/浅蓝色底图.png")

@onready var 图片_装备槽位背景: TextureRect = $UI框架/边缘容器/图片_装备槽位背景

func _ready() -> void:
	图片_装备槽位背景.set_instance_shader_parameter("center_more_transparent",false)
	动态仓库事件.connect("玩家装备物品",装备本格物品)
	动态仓库事件.connect("玩家卸载物品",卸载本格物品)

func 设置本格物品(传入物品:实体_物品) -> void:
	super(传入物品)
	更新本格背景颜色()

func 更新本格背景颜色() -> void:
	var 背景图片: Texture
	
	if 本格物品 and 动态仓库数据.玩家检测物品是否被装备(本格物品):
		背景图片 = 装备物品背景颜色
		图片_装备槽位背景.set_instance_shader_parameter("center_more_transparent",true)
	else:
		背景图片 = 正常物品背景颜色
		图片_装备槽位背景.set_instance_shader_parameter("center_more_transparent",false)

	
	图片_装备槽位背景.set_texture(背景图片)

func 装备本格物品(传入物品:实体_物品) -> void:
	for 物品种类 in 本格装备种类:
		if 传入物品.物品种类 == 物品种类:
			设置本格物品(传入物品)
			break

func 卸载本格物品(传入物品:实体_物品) -> void:
	if 传入物品 == 本格物品:
		设置本格物品(null)
	
