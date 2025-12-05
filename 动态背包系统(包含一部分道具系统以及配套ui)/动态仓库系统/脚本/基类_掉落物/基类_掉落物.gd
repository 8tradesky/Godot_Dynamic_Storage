extends Area2D
class_name 基类_掉落物

@onready var 精灵图_掉落物: Sprite2D = $精灵图_掉落物
@export var 持有的物品 :实体_物品:
	get = 获取该掉落物持有的物品,
	set = 设置该掉落物持有的物品


func 获取该掉落物持有的物品() -> 实体_物品:
	return 持有的物品

func 设置该掉落物持有的物品(传入物品:实体_物品) -> void:
	持有的物品 = 传入物品
	重载()

func 重载() -> void:
	if 持有的物品 and 精灵图_掉落物:
		精灵图_掉落物.set_texture(持有的物品.物品图片)

func 被捡起() -> void:
	queue_free()


func _当玩家捡起道具(body: Node2D) -> void:
	if body.玩家实体:
		# 此处判断是否为主机捡起
		# if body.is_multiplayer_authority():
		动态仓库数据.获得物品(持有的物品)
		被捡起()
