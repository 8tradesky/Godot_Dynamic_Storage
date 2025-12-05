extends 基类_持有物品的UI
@onready var 文字标签_物品名称: Label = $边缘容器_物品信息栏/水平容器_物品信息栏/垂直容器_物品名称和类型/文字标签_物品名称
@onready var 文字标签_物品类型: Label = $边缘容器_物品信息栏/水平容器_物品信息栏/垂直容器_物品名称和类型/文字标签_物品类型
@onready var 垂直容器_攻击力数据: HBoxContainer = $边缘容器_物品信息栏/水平容器_物品信息栏/垂直容器_主要属性数据/垂直容器_攻击力数据
@onready var 垂直容器_防御力数据: HBoxContainer = $边缘容器_物品信息栏/水平容器_物品信息栏/垂直容器_主要属性数据/垂直容器_防御力数据
@onready var 垂直容器_速度数据: HBoxContainer = $边缘容器_物品信息栏/水平容器_物品信息栏/垂直容器_主要属性数据/垂直容器_速度数据
@onready var 垂直容器_等级数据: HBoxContainer = $边缘容器_物品信息栏/水平容器_物品信息栏/垂直容器_特殊属性数据/垂直容器_等级数据
@onready var 垂直容器_金钱数据: HBoxContainer = $边缘容器_物品信息栏/水平容器_物品信息栏/垂直容器_特殊属性数据/垂直容器_金钱数据
@onready var 富文本_物品描述: RichTextLabel = $边缘容器_物品信息栏/水平容器_物品信息栏/富文本_物品描述


func _ready() -> void:
	文字标签_物品名称.set_text("未选中物品,选中物品查看其信息")
	文字标签_物品类型.set_text("未知类型")
	
	垂直容器_攻击力数据.set_visible(false)
	垂直容器_防御力数据.set_visible(false)
	垂直容器_速度数据.set_visible(false)
	垂直容器_等级数据.set_visible(false)
	垂直容器_金钱数据.set_visible(false)
	富文本_物品描述.set_visible(false)


func 设置本格物品(传入物品:实体_物品) -> void:
	super(传入物品)
	
	文字标签_物品名称.set_text(传入物品.物品名称)
	文字标签_物品类型.set_text("("+全局物品种类.枚举_仓库物品种类枚举.keys()[传入物品.物品种类]+")")
	
	垂直容器_攻击力数据.设置当前文字标签文本(str(传入物品.攻击力))
	垂直容器_攻击力数据.set_visible(true)
	
	垂直容器_防御力数据.设置当前文字标签文本(str(传入物品.防御力))
	垂直容器_防御力数据.set_visible(true)
	
	if 传入物品.速度 != 0:
		垂直容器_速度数据.设置当前文字标签文本(str(传入物品.速度))
		垂直容器_速度数据.set_visible(true)
	else:
		垂直容器_速度数据.set_visible(false)
	
	
	垂直容器_等级数据.设置当前文字标签文本("等级"+str(传入物品.等级))
	垂直容器_等级数据.set_visible(true)
	
	垂直容器_金钱数据.设置当前文字标签文本(str(传入物品.价格))
	垂直容器_金钱数据.set_visible(true)
	
	富文本_物品描述.set_text(传入物品.描述)
	富文本_物品描述.set_visible(true)
	
	
