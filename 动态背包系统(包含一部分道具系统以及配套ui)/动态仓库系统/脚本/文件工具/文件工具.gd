extends Object
class_name 文件工具

static  func 获取路径下的文件名(文件路径:String,扩展名:String = "all") -> Array:
	var 内容数组 :=[]
	var 文件目录 = DirAccess.open(文件路径)
	if 文件目录:
		文件目录.list_dir_begin()
		var 文件名称 = 文件目录.get_next()
		while 文件名称 != "":
			if not 文件目录.current_is_dir() and (扩展名 == "all" or 扩展名 == 文件名称.get_extension()):
				内容数组.append(文件名称)
			文件名称 = 文件目录.get_next()
	else:
		print("尝试访问路径时出错。")
	return 内容数组
	
	
static func 加载路径下的文件资源(文件路径:String) -> Array:
	var 资源组 := []
	
	for 文件名称 in 获取路径下的文件名(文件路径,"tres"):
		资源组.append(load(文件路径 + "/" + 文件名称))
	return 资源组
