extends CanvasLayer

@onready var cube: Node3D = get_node("/root/Node3D")
@onready var settings_window: Window = $SettingsWindow
@onready var menu_bar: MenuBar = $MenuBar

func _ready():
	if OS.get_name() == "macOS":
		menu_bar.hide()
		call_deferred("_setup_native_menu")
	
	var edit_popup = $MenuBar/Edit.get_popup()
	edit_popup.id_pressed.connect(_on_edit_menu_id_pressed)

func _setup_native_menu():
	var menu_id = "_custom_edit_menu"
	DisplayServer.global_menu_clear(menu_id)
	DisplayServer.global_menu_add_submenu_item("_main", "Edit", menu_id)
	DisplayServer.global_menu_add_item(menu_id, "打乱魔方", Callable(self, "_on_scramble"))
	DisplayServer.global_menu_add_item(menu_id, "还原魔方", Callable(self, "_on_reset"))
	DisplayServer.global_menu_add_item(menu_id, "性能基准测试 (Benchmark)", Callable(self, "_on_benchmark"))
	DisplayServer.global_menu_add_separator(menu_id)
	DisplayServer.global_menu_add_item(menu_id, "画质设置...", Callable(self, "_on_show_settings"))

func _on_edit_menu_id_pressed(id: int):
	match id:
		0: _on_scramble()
		1: _on_reset()
		2: _on_benchmark()
		3: _on_show_settings()

func _on_scramble(_tag = null):
	cube.scramble(20)

func _on_reset(_tag = null):
	cube.reset_cube()

func _on_benchmark(_tag = null):
	cube.run_benchmark()

func _on_show_settings(_tag = null):
	settings_window.show()
	settings_window.grab_focus()
