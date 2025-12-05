extends Control
class_name 基类_持有物品的UI

var 本格物品 : 实体_物品:
	get = 获取本格物品,
	set = 设置本格物品

func 获取本格物品() -> 实体_物品:
	return 本格物品
	
func 设置本格物品(传入物品:实体_物品) -> void:
	本格物品 = 传入物品
