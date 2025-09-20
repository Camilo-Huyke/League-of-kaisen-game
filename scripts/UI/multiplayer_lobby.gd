extends Control
class_name Multiplayer_lobby

@onready var host:Button = $VBoxContainer/Host
@onready var join:Button = $VBoxContainer/Join

func _ready() -> void:
	ServerManager.register_UI(self, $VBoxContainer/LineEdit)
