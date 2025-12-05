extends Control

#region 物品节点相关变量
const 每页面物品数量 : int = 20

var 位置更新重试次数 = 0
const 最大重试次数 = 3

#@onready var _拖动物品格: 拖动物品格 = $控制节点_拖动物品格


@onready var 滚动容器_仓库: ScrollContainer = $边缘控制_主要界面/垂直容器_主要界面/控制节点_仓库物品/水平容器_仓库/垂直容器_物品仓库主体/滚动容器_仓库
@onready var 垂直容器_显示的仓库网格: HBoxContainer = $边缘控制_主要界面/垂直容器_主要界面/控制节点_仓库物品/水平容器_仓库/垂直容器_物品仓库主体/滚动容器_仓库/垂直容器_显示的仓库网格
@onready var 左箭头图片按钮: TextureButton = $边缘控制_主要界面/垂直容器_主要界面/控制节点_仓库物品/水平容器_仓库/垂直容器_物品仓库主体/种类切换左箭头/左箭头图片按钮
@onready var 右箭头图片按钮: TextureButton = $边缘控制_主要界面/垂直容器_主要界面/控制节点_仓库物品/水平容器_仓库/垂直容器_物品仓库主体/种类切换右箭头/右箭头图片按钮

var _网格模板 = preload("res://动态仓库系统/示例场景/组件场景/网格容器_物品仓库.tscn")
var _网格物品模板 = preload("res://动态仓库系统/示例场景/组件场景/控制节点_仓库物品格_网格调整.tscn")

var _当前滚动条页码: = 1
var _总滚动条页码: = 1
var _页码尺寸 : = 482
var _正在滚动 :bool = false
#endregion

#region 物品分类相关变量
@onready var 网格容器_种类图片标签: GridContainer = $边缘控制_主要界面/垂直容器_主要界面/控制节点_仓库物品/水平容器_仓库/水平容器_物品种类标签/中心容器_种类图片标签/网格容器_种类图片标签
@onready var 文字标签_动态文字标签: = $"边缘控制_主要界面/垂直容器_主要界面/控制节点_仓库物品/水平容器_仓库/水平容器_物品种类标签/控制节点_动态文字标签父类/文字标签_物品动态"

var 仓库种类图片标签模板 = preload("res://动态仓库系统/示例场景/组件场景/水平容器_仓库种类图片标签.tscn")

var 字典_物品分类对应页码 := {}
var 字典_物品分类对应图片标签 := {}
var 字典_页码对应物品分类 := {}

var 当前激活物品分类:Control
@onready var 文字标签复位计时器: Timer = $边缘控制_主要界面/垂直容器_主要界面/控制节点_仓库物品/水平容器_仓库/水平容器_物品种类标签/控制节点_动态文字标签父类/文字标签复位计时器

#endregion

#region 物品信息
@onready var 控制节点_物品信息: Control = $边缘控制_主要界面/垂直容器_主要界面/控制节点_物品信息列/控制节点_物品信息
@onready var 控制节点_右键菜单容器: Control = $控制节点_右键菜单容器
@onready var 控制节点_右键菜单: Control = $控制节点_右键菜单容器/控制节点_右键菜单

#endregion

func _ready() -> void:
	_事件绑定()
	_重载()
	

func _事件绑定() -> void:
	文字标签复位计时器.timeout.connect(文字标签计时器超时回调)
	左箭头图片按钮.pressed.connect(_左箭头图片按钮_按下)
	右箭头图片按钮.pressed.connect(_右箭头图片按钮_按下)
	控制节点_右键菜单.获取装备按钮().pressed.connect(_右键菜单装备_按下)
	控制节点_右键菜单.获取取消按钮().pressed.connect(_右键菜单取消_按下)
	动态仓库事件.玩家获得物品.connect(_当玩家获得物品)

func _当玩家获得物品(_传入物品:实体_物品) -> void:
	_重载()
	
func _重载() -> void:
	_重载物品()
	await  get_tree().process_frame
	_重载种类标签()
	await  get_tree().process_frame
	_更新导航显示()
	

func _重载种类标签() -> void:
	# 清理默认节点中自带的测试子节点
	for 子节点 in 网格容器_种类图片标签.get_children():
		网格容器_种类图片标签.remove_child(子节点)
	
	for 标签名称 in 动态仓库数据.物品种类标签:
		var 仓库种类图片标签 = 仓库种类图片标签模板.instantiate()
		仓库种类图片标签.set_name(标签名称.标签名称)
		网格容器_种类图片标签.add_child(仓库种类图片标签,true)
		
		if 动态仓库数据.根据标签名称统计库存物品数量(标签名称) > 0:
			var 本次处理按钮:TextureButton = 仓库种类图片标签.获取种类图片标签按钮()
			本次处理按钮.mouse_entered.connect(_种类图片标签按钮_鼠标进入.bind(仓库种类图片标签))
			本次处理按钮.mouse_exited.connect(_种类图片标签按钮_鼠标退出.bind(仓库种类图片标签))
			本次处理按钮.pressed.connect(_种类图片标签按钮_按下.bind(字典_物品分类对应页码[标签名称]))
		
		仓库种类图片标签.set("_标签种类",标签名称)
		字典_物品分类对应图片标签[标签名称] = 仓库种类图片标签

func _重载物品() -> void:
	#region 处理仓库物品
	var 当前处理页码 = 0
	# 清理默认节点中自带的测试子节点
	for 子节点 in 垂直容器_显示的仓库网格.get_children():
		垂直容器_显示的仓库网格.remove_child(子节点)

	for 标签名称 in 动态仓库数据.物品种类标签:
		var 种类起始页码 = 当前处理页码
		var 本种类物品总数 = 0
		
		if 动态仓库数据.根据标签名称统计库存物品数量(标签名称) > 0:
			var 分类类型数组 = 标签名称.包含的物品种类
			var 当前网格
			
			for 具体物品种类 in 分类类型数组:
				for 物品 in 动态仓库数据.根据类别获取库存物品(具体物品种类):
					if not 物品:
						continue
					
					var 本页是否被填满 :bool = (本种类物品总数%每页面物品数量) == 0 
					# 这边要把物品总数移到定义之后,是为了防止刚刚到达总数时就创建额外物品网格
					# 那样的话会导致网格内缺一个物品
					本种类物品总数 += 1
					
					if not 当前网格 or (当前网格 and 本页是否被填满):
						
						当前网格 = _网格模板.instantiate()
						当前网格.set_name(标签名称.标签名称)
						垂直容器_显示的仓库网格.add_child(当前网格,true)
						当前处理页码 += 1
						# 清理默认节点中自带的测试子节点
						for 子节点 in 当前网格.get_children():
							当前网格.remove_child(子节点)
					
					var 当前物品 = _网格物品模板.instantiate()
					当前物品.set_name(物品.物品名称)
					当前网格.add_child(当前物品,true)
					
					var 当前网格物品节点 = 当前物品.获取物品节点()
					当前网格物品节点.设置本格物品(物品)
					var 当前网格物品按钮:TextureButton = 当前网格物品节点.获取本格选择按钮()
					当前网格物品按钮.mouse_entered.connect(_网格物品节点_鼠标进入.bind(当前网格物品节点))
					当前网格物品按钮.mouse_exited.connect(_网格物品节点_鼠标退出.bind(当前网格物品节点))
					当前网格物品按钮.pressed.connect(_网格物品节点_按下.bind(当前网格物品节点))
			# 在处理下一层级的物品种类前,保存当前物品种类的起始页码到映射字典 
			字典_物品分类对应页码[标签名称] = 种类起始页码 + 1
			
			# 将当前分类完的页码分配给标签名称,用于页码转换时的物品分类标签的UI显示转换
			var 此物品种类分配页码 = 当前处理页码 - 种类起始页码
			while 此物品种类分配页码 > 0:
				字典_页码对应物品分类[此物品种类分配页码 + 种类起始页码] = 标签名称
				此物品种类分配页码 -= 1
	#endregion
	
	
	#region 滚动条设置
	_当前滚动条页码 = 1
	_总滚动条页码 = 垂直容器_显示的仓库网格.get_child_count()
	await get_tree().process_frame
	#if _总滚动条页码 > 0:
		#_页码尺寸 = 垂直容器_显示的仓库网格.get_size().x / _总滚动条页码
	#
	滚动容器_仓库.set_h_scroll(0)
	#endregion
	

#region 物品网格翻动动画
func 翻到指定页码(页码:int) -> void:
	页码 = clampi(页码,1,_总滚动条页码)
	if 页码 == _当前滚动条页码:
		return
	
	var 到达位置 :float = 0
	#var 是否往前 := 页码 > _当前滚动条页码
	
	var UI动画 = get_tree().create_tween()
	到达位置 = _页码尺寸 * (页码 - 1)
	_正在滚动 = true
	UI动画.tween_callback(正在播放滚动动画.bind(true))
	UI动画.tween_property(滚动容器_仓库,"scroll_horizontal",到达位置,0.4)
	UI动画.tween_callback(正在播放滚动动画.bind(false)).set_delay(0.2)
	#滚动容器_仓库.set_h_scroll(int(到达位置))
	_当前滚动条页码 = 页码
	_更新导航显示()


func 正在播放滚动动画(是否滚动:bool) -> void:
	左箭头图片按钮.set_disabled(是否滚动)
	右箭头图片按钮.set_disabled(是否滚动)
	if not 是否滚动:
		_正在滚动 = false
#endregion

#region 按钮相关
func _显示动态文字标签(物品种类标签:Node) -> void:
	if not 物品种类标签:
		if not 当前激活物品分类:
			return
		
		物品种类标签 = 当前激活物品分类
		
	var 按钮 = 物品种类标签.获取种类图片标签按钮()
	
	var 图片中心全局X坐标 = 按钮.get_global_position().x + 按钮.get_rect().size.x / 2
	var 标签X尺寸的一半 = 文字标签_动态文字标签.get_rect().size.x / 2
	var 标签位置 = Vector2(图片中心全局X坐标 - 标签X尺寸的一半,文字标签_动态文字标签.get_global_position().y)
	
	await  get_tree().process_frame
	文字标签_动态文字标签.set_global_position(标签位置,true)
	文字标签_动态文字标签.set_text(物品种类标签._标签种类.标签名称)
	物品种类标签.高亮(true)

func _更新导航显示() -> void:
	if _当前滚动条页码 == 1:
		左箭头图片按钮.set_visible(false)
	else:
		左箭头图片按钮.set_visible(true)
	if _当前滚动条页码 == _总滚动条页码 or _总滚动条页码 == 0:
		右箭头图片按钮.set_visible(false)
	else:
		右箭头图片按钮.set_visible(true)
		
	_设置当前激活物品标签()
	

func _设置当前激活物品标签() -> void:
	var 标签名称 = 字典_页码对应物品分类[_当前滚动条页码]
	var 图片标签节点 = 字典_物品分类对应图片标签.get(标签名称)
	if not 图片标签节点:
		return
	
	if 当前激活物品分类 and 图片标签节点 != 当前激活物品分类:
		当前激活物品分类.设置是否激活(false)
	
	图片标签节点.设置是否激活(true)
	当前激活物品分类 = 图片标签节点
	
	
	_显示动态文字标签(图片标签节点)

func _左箭头图片按钮_按下() -> void:
	翻到指定页码(_当前滚动条页码 - 1)

func _右箭头图片按钮_按下() -> void:
	翻到指定页码(_当前滚动条页码 + 1)

func _种类图片标签按钮_按下(传入页码:int) -> void:
	翻到指定页码(传入页码)
	
func _网格物品节点_按下(网格物品节点:基类_持有物品的UI) -> void:
	if _正在滚动:return
	网格物品节点.高亮闪烁()
	设置右键菜单位置并显示(网格物品节点)


func _右键菜单装备_按下() -> void:
	if 控制节点_右键菜单.获取仓库物品节点():
		var 所须处理物品:实体_物品 = 控制节点_右键菜单.获取仓库物品节点().获取本格物品()
		
		if 动态仓库数据.玩家检测物品是否被装备(所须处理物品):
			动态仓库数据.卸下物品(所须处理物品)
		else:
			动态仓库数据.装备物品(所须处理物品)
		控制节点_右键菜单.卸载装备更新文本()

func _右键菜单取消_按下() -> void:
	复位右键菜单并隐藏()
	控制节点_右键菜单.获取仓库物品节点().去除高亮闪烁()
	控制节点_右键菜单容器.visible = false

func _种类图片标签按钮_鼠标进入(种类图片标签按钮: Node) -> void:
	文字标签复位计时器.stop()
	_显示动态文字标签(种类图片标签按钮)

func _种类图片标签按钮_鼠标退出(种类图片标签按钮: Node) -> void:
	if 种类图片标签按钮:
		种类图片标签按钮.去除高亮()
	文字标签复位计时器.stop()
	文字标签复位计时器.start()
	
func _网格物品节点_鼠标进入(网格物品节点:基类_持有物品的UI) -> void:
	if _正在滚动: return
	网格物品节点.选择()
	显示物品信息(网格物品节点.获取本格物品())

func _网格物品节点_鼠标退出(网格物品节点:基类_持有物品的UI) -> void:
	if _正在滚动: return
	网格物品节点.取消选择()

func 文字标签计时器超时回调() -> void:
	_显示动态文字标签(当前激活物品分类)
#endregion


#region 物品信息
func 显示物品信息(传入物品:实体_物品) -> void:
	控制节点_物品信息.设置本格物品(传入物品)
	控制节点_物品信息.set_visible(true)
	
func 设置右键菜单位置并显示(传入物品:基类_持有物品的UI) -> void:
	# 可以在某全局中设置,是否键鼠的变量,用于分别定位
	# if 是否键鼠 :
	#	var 
	if 控制节点_右键菜单.获取仓库物品节点():
		控制节点_右键菜单.获取仓库物品节点().去除高亮闪烁()
	
	var 鼠标位置 = get_global_mouse_position()
	控制节点_右键菜单容器.global_position = 鼠标位置
	控制节点_右键菜单.设置仓库物品节点(传入物品)
	控制节点_右键菜单容器.set_visible(true)

func 复位右键菜单并隐藏() -> void:
	控制节点_右键菜单容器.global_position = Vector2.ZERO
	控制节点_右键菜单容器.set_visible(false)
#endregion
