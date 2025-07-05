extends Node2D

@onready var cloud_secret: AnimatedSprite2D = $Node2D3/CloudSecret
@onready var cloud_secret_2: AnimatedSprite2D = $Node2D3/CloudSecret2
@onready var cloud_secret_3: AnimatedSprite2D = $Node2D3/CloudSecret3

func reset_all_secret_clouds() -> void:
	cloud_secret.reset_cloud()
	cloud_secret_2.reset_cloud()
	cloud_secret_3.reset_cloud()
