extends Area2D

var current_weapon: Node2D = null

func _ready():
	# Conecta o sinal de área entrou
	area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	# Verifica se a área que entrou é uma arma e se não temos arma atual
	if area.is_in_group("weapon") and current_weapon == null:
		current_weapon = area
		area.pickup(self)

func _input(event):
	# Solta a arma quando clicamos com botão direito
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if current_weapon:
			current_weapon.drop()
			current_weapon = null
	
	# Atira quando clicamos com botão esquerdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_weapon:
			current_weapon.shoot()

func _process(delta):
	# Faz a mão seguir o mouse
	global_position = get_global_mouse_position()
