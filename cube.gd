extends Node3D

var block = preload("res://models/block.tscn")
var blockMap = [] 
var blocks = [] 

func _ready() -> void:
	for i in range(3):
		blockMap.append([])
		for j in range(3):
			blockMap[i].append([0, 0, 0])
	
	# 初始化时应用最低渲染比例
	get_tree().root.scaling_3d_scale = dynamic_scale
	reset_cube()

func reset_cube() -> void:
	if is_rotating: return
	for b in blocks: b.queue_free()
	blocks.clear()
	for layer in range(-1, 2):
		for line in range(-1, 2):
			for row in range(-1, 2):
				var instance = block.instantiate()
				var name_str = str(layer + 1) + str(line + 1) + str(row + 1)
				instance.name = name_str
				blockMap[layer + 1][line + 1][row + 1] = name_str
				add_child(instance)
				instance.position = Vector3(line, layer, row)
				instance.start_up([layer + 1, line + 1, row + 1])
				blocks.append(instance)

func scramble(steps: int = 20, duration: float = 0.05) -> void:
	var move_keys = ["R", "L", "U", "D", "F", "B", "M", "E", "S"]
	for i in range(steps):
		var key = move_keys[randi() % move_keys.size()]
		var dir = [1, -1][randi() % 2]
		var move = move_map[key]
		var layers = move[1].duplicate()
		await rotateCube(layers, move[0], move[2] * dir, duration)

# --- Benchmark 模式 ---
func run_benchmark() -> void:
	print_debug("开始 Benchmark: 512 步测试...")
	var start_time = Time.get_ticks_msec()
	
	# 正常执行动画，且允许动态分辨率在后台调节
	await scramble(512, 0.05) 
	
	var end_time = Time.get_ticks_msec()
	var duration_sec = (end_time - start_time) / 1000.0
	print_debug("Benchmark 完成! 耗时: %.2f 秒. 最终渲染系数: %.2f" % [duration_sec, dynamic_scale])

# --- 动态超分逻辑 ---
var dynamic_scale = 0.25 # 从最低比例开始

func _process(_delta):
	# 每秒检查一次负载并调整分辨率
	if Engine.get_frames_drawn() % 60 == 0:
		_adjust_dynamic_scaling()

func _adjust_dynamic_scaling():
	var fps = Engine.get_frames_per_second()
	var root = get_tree().root
	
	if fps < 58: 
		dynamic_scale = clamp(dynamic_scale - 0.05, 0.25, 1.0)
	elif fps > 61 and dynamic_scale < 1.0: 
		dynamic_scale = clamp(dynamic_scale + 0.02, 0.25, 1.0)
	
	if not is_equal_approx(root.scaling_3d_scale, dynamic_scale):
		root.scaling_3d_scale = dynamic_scale

var move_map = {
	"R": [0, [1], -1], "L": [0, [-1]      ,  1], "U": [1, [1]        , -1], "D": [1, [-1]      ,  1],
	"F": [2, [1], -1], "B": [2, [-1]      ,  1], "M": [0, [0]        ,  1], "E": [1, [0]       ,  1],
	"S": [2, [0], -1], "X": [0, [-1, 0, 1], -1], "Y": [1, [-1, 0,  1], -1], "Z": [2, [-1, 0, 1], -1]
}

func _input(event):
	if is_rotating: return
	var is_double = Input.is_action_pressed("Shift")
	var is_ccw = Input.is_action_pressed("‘") 
	var dir_multiplier = -1 if is_ccw else 1
	for action in move_map.keys():
		if event.is_action_pressed(action):
			var move = move_map[action]
			var layers = move[1].duplicate()
			if is_double and action in ["R", "L", "U", "D", "F", "B"]:
				if 0 not in layers: layers.append(0)
			rotateCube(layers, move[0], move[2] * dir_multiplier)
			break

var is_rotating = false
func rotateCube(layers: Array, axis_index: int, dir: int, duration: float = 0.2) -> void:
	var centerBall = get_node_or_null("centerBall")
	if not centerBall: return
	is_rotating = true
	centerBall.rotation = Vector3.ZERO
	var slice_blocks = []
	for b in blocks:
		var pos = b.position 
		var val = 0.0
		match axis_index:
			0: val = pos.x
			1: val = pos.y
			2: val = pos.z
		for target_val in layers:
			if is_equal_approx(val, target_val):
				slice_blocks.append(b)
				break
	for b in slice_blocks: b.reparent(centerBall)
	var tween = create_tween()
	var target_rotation = Vector3.ZERO
	var angle = deg_to_rad(90 * dir)
	match axis_index:
		0: target_rotation.x = angle
		1: target_rotation.y = angle
		2: target_rotation.z = angle
	tween.tween_property(centerBall, "rotation", target_rotation, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	for b in slice_blocks: b.reparent(self)
	is_rotating = false
