extends 基类_持有物品的UI
@onready var 装备按钮: Button = $水平容器_右键菜单/装备按钮
@onready var 取消按钮: Button = $水平容器_右键菜单/取消按钮

var 仓库物品节点:Control:
	set = 设置仓库物品节点,get = 获取仓库物品节点


func 获取装备按钮() -> Button:
	return 装备按钮
	
	
func 获取取消按钮() -> Button:
	return 取消按钮
	
	
func 获取仓库物品节点() -> Control:
	return 仓库物品节点

func 卸载装备更新文本() -> void:
	if 动态仓库数据.玩家检测物品是否被装备(本格物品):
		获取装备按钮().text = "卸载"
	else:
		获取装备按钮().text = "装备"

func 设置仓库物品节点(传入节点:基类_持有物品的UI) -> void:
	仓库物品节点 = 传入节点
	
	if 传入节点:
		设置本格物品(传入节点.获取本格物品())
		卸载装备更新文本()
		
	else:
		设置本格物品(null)
