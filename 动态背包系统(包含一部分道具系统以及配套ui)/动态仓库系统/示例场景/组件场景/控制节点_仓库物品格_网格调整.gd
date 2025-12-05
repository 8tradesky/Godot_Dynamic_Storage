extends Control

@onready var 控制节点_仓库物品格: Control = $垂直容器_仓库物品格/控制节点_仓库物品格

func 获取物品节点() -> Node:
	return 控制节点_仓库物品格
