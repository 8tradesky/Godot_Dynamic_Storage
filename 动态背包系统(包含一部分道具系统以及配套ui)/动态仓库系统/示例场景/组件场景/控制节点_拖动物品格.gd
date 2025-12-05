extends 基类_持有物品的UI
class_name 拖动物品格

@onready var 图片_仓库物品: TextureRect = $UI框架/UI框架限制边框/图片_拖动物品格背景/图片_仓库物品


signal 选择物品(物品:实体_物品)
signal 放下物品(物品:实体_物品)

var 正在跟随鼠标 :bool = false
var 选中的槽位 :基类_持有物品的UI = null

func 设置拖动物品格可见性(可见:bool) -> void:
	set_visible(可见)

func _ready() -> void:
	重置至初始状态()

func _process(_delta: float) -> void:
	if 正在跟随鼠标:
		var 鼠标位置 = get_global_mouse_position()
		var 最终位置 = 鼠标位置 - get_rect().size/2
		set_global_position(最终位置)
		# 寻找鼠标下的槽位()

func 设置本格物品(传入物品:实体_物品) -> void:
	super(传入物品)
	图片_仓库物品.set_texture(传入物品.物品图片)

func 重置至初始状态() -> void:
	if 本格物品:
		设置本格物品(null)
	设置拖动物品格可见性(false)
	正在跟随鼠标 = false
	set_global_position(Vector2.ZERO-get_rect().size)

func 选择并拾取物品(传入物品:基类_持有物品的UI) -> void:
	设置本格物品(传入物品.获取本格物品())
	设置拖动物品格可见性(true)
	正在跟随鼠标 = true
	选择物品.emit(传入物品.获取本格物品())
	
func 放下并给与本身物品() -> 实体_物品:
	放下物品.emit(本格物品)
	重置至初始状态()
	return 本格物品

func _寻找鼠标下的槽位(传入槽位:基类_持有物品的UI) -> void:
	选中的槽位 = 传入槽位
	

func 寻找鼠标下的槽位() -> void:
	var 拖动物品矩形 = get_global_rect()
	
