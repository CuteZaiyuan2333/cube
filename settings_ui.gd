extends Window

@onready var cube: Node3D = get_node("/root/Node3D")
@onready var label_mode: Label = %LabelMode
@onready var line_graph: Line2D = %Line
@onready var graph_container: Control = %GraphContainer

func _ready():
	close_requested.connect(_on_close_requested)
	_initialize_settings()

func _on_close_requested():
	hide()

func _initialize_settings():
	var root = get_tree().root
	
	# 使用整数索引以避开部分 Godot 版本未定义常量的报错 (4.3+ 才支持 MetalFX/FSR2)
	# 0: Bilinear, 1: FSR1, 2: FSR2, 3: MetalFX
	if OS.get_name() in ["macOS", "iOS"]:
		root.scaling_3d_mode = 3 as Viewport.Scaling3DMode
		label_mode.text = "Native Apple"
	else:
		root.scaling_3d_mode = 2 as Viewport.Scaling3DMode
		label_mode.text = "Standard"
		
	# 2. 初始化窗口模式选项
	var window_mode = DisplayServer.window_get_mode()
	var option_window = %OptionWindow
	match window_mode:
		DisplayServer.WINDOW_MODE_WINDOWED: option_window.selected = 0
		DisplayServer.WINDOW_MODE_FULLSCREEN: option_window.selected = 1
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN: option_window.selected = 2

func _on_window_mode_selected(index: int):
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_benchmark_pressed():
	if cube and cube.has_method("run_benchmark"):
		# 开始记录数据并清空旧曲线
		line_graph.clear_points()
		_is_tracking_benchmark = true
		_benchmark_data.clear()
		
		# 运行测试
		await cube.run_benchmark()
		
		_is_tracking_benchmark = false

var _is_tracking_benchmark = false
var _benchmark_data = []

func _process(_delta):
	if _is_tracking_benchmark:
		# 记录当前超分系数
		var current_scale = get_tree().root.scaling_3d_scale
		_benchmark_data.append(current_scale)
		_update_graph()

func _update_graph():
	if _benchmark_data.size() < 2: return
	
	line_graph.clear_points()
	var size = graph_container.size
	var max_points = 200 # 限制显示点数
	
	var data_to_show = _benchmark_data
	if _benchmark_data.size() > max_points:
		data_to_show = _benchmark_data.slice(-max_points)
		
	for i in range(data_to_show.size()):
		var x = float(i) / (data_to_show.size() - 1) * size.x
		# 比例 0.25-1.0 映射到 Y 坐标 (底部是 0.25, 顶部是 1.0)
		# 注意：Y 轴 0 在顶部
		var normalized_y = (data_to_show[i] - 0.25) / (1.0 - 0.25)
		var y = size.y * (1.0 - normalized_y)
		line_graph.add_point(Vector2(x, y))
