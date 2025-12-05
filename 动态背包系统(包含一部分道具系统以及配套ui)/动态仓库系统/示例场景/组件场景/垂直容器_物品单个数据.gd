extends HBoxContainer

@onready var 文字标签_数据数值: Label = $文字标签_数据数值

func 设置当前文字标签文本(传入文本:String) ->void:
	文字标签_数据数值.set_text(传入文本)
