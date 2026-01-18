extends CharacterBody3D
class_name Player

#Components
@onready var camera: Camera3D = $Camera3D
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@export var animation_player: AnimationPlayer
@export var model: Node3D

#Properties
var direction: Vector3 = Vector3()
var current_health: int

#Stats
@export var speed: float 
@export var max_health: int
