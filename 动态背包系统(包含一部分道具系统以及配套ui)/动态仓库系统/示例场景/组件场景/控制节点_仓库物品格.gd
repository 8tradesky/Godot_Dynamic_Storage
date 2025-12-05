extends 基类_持有物品的UI

@onready var 图片_仓库物品: TextureRect = $UI框架/UI框架限制边框/图片_仓库物品背景/图片_仓库物品
@onready var 图片按钮_选择: TextureButton = $UI框架/图片按钮_选择
@onready var 高亮动画: AnimationPlayer = $UI框架/高亮动画
@onready var 图片_仓库物品背景: TextureRect = $UI框架/UI框架限制边框/图片_仓库物品背景

var 正常物品背景颜色 := preload("res://动态仓库系统/示例图片/其他图标/白色底图.png")
var 装备物品背景颜色 := preload("res://动态仓库系统/示例图片/其他图标/浅蓝色底图.png")

var 正在高亮 = false

func _ready() -> void:
	取消选择()
	图片按钮_选择.set_visible(true)
	
	动态仓库事件.connect("玩家装备物品",装备本格物品)
	动态仓库事件.connect("玩家卸载物品",卸载本格物品)

func 设置本格物品(传入物品:实体_物品) -> void:
	super(传入物品)
	图片_仓库物品.texture = 传入物品.物品图片
	更新本格背景颜色()

func 获取本格选择按钮() -> TextureButton:
	return 图片按钮_选择
	
func 选择() -> void:
	图片按钮_选择.set_modulate(Color(1.0, 1.0, 1.0, 1.0))

func 取消选择() -> void:
	图片按钮_选择.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
	#去除高亮闪烁()

func 高亮闪烁() -> void:
	高亮动画.play("高亮闪烁")
	正在高亮 = true
	
func 去除高亮闪烁() -> void:
	if 正在高亮:
		高亮动画.play("去除高亮闪烁")
		正在高亮 = false

func 更新本格背景颜色() -> void:
	var 背景图片: Texture
	
	if 动态仓库数据.玩家检测物品是否被装备(本格物品):
		背景图片 = 装备物品背景颜色
	else:
		背景图片 = 正常物品背景颜色
	
	图片_仓库物品背景.set_texture(背景图片)

func 装备本格物品(传入物品:实体_物品) -> void:
	if 传入物品 == 本格物品:
		更新本格背景颜色()

func 卸载本格物品(传入物品:实体_物品) -> void:
	if 传入物品 == 本格物品:
		更新本格背景颜色()
	
	
	
	
