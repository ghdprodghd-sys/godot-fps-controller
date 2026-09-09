extends DirectionalLight3D

# Ciclo dia/noite
@export var cycle_duration: float = 120.0  # Duração total do ciclo em segundos
@export var day_start: float = 0.25  # Quando o dia começa (0-1)
@export var night_start: float = 0.75  # Quando a noite começa (0-1)

# Cores
@export var day_color: Color = Color.WHITE
@export var night_color: Color = Color(0.3, 0.3, 0.5)  # Azul escuro
@export var sunrise_color: Color = Color.ORANGE
@export var sunset_color: Color = Color.ORANGE_RED

# Posição
var time_of_day: float = 0.0

func _ready() -> void:
	# Verificar se já existe um Environment
	if environment == null:
		var new_env = Environment.new()
		environment = new_env

func _process(delta: float) -> void:
	# Atualizar tempo do dia
	time_of_day += delta / cycle_duration
	if time_of_day >= 1.0:
		time_of_day = 0.0
	
	# Atualizar posição da luz (rotação)
	var angle = time_of_day * TAU - PI / 2
	rotation.x = angle
	
	# Ajustar intensidade baseado na hora do dia
	update_light_intensity()
	
	# Ajustar cor
	update_light_color()

func update_light_intensity() -> void:
	"""Ajusta intensidade baseado na hora do dia"""
	var intensity = 1.0
	
	# Transição suave ao amanhecer
	if time_of_day < day_start:
		var transition = time_of_day / day_start
		intensity = lerp(0.2, 1.0, transition)
	# Transição suave ao entardecer
	elif time_of_day >= night_start:
		var transition = (time_of_day - night_start) / (1.0 - night_start)
		intensity = lerp(1.0, 0.2, transition)
	
	light_energy = intensity

func update_light_color() -> void:
	"""Muda a cor da luz ao longo do dia"""
	var color = day_color
	
	# Amanhecer (cores quentes)
	if time_of_day < day_start:
		var t = time_of_day / day_start
		color = sunrise_color.lerp(day_color, t)
	# Entardecer (cores quentes)
	elif time_of_day >= night_start - 0.1 and time_of_day < night_start:
		var t = (time_of_day - (night_start - 0.1)) / 0.1
		color = day_color.lerp(sunset_color, t)
	# Noite (azul)
	elif time_of_day >= night_start:
		color = night_color
	
	light_color = color

# Função para pular para hora específica
func set_time_of_day(new_time: float) -> void:
	"""Define a hora do dia (0.0 = amanhecer, 0.5 = meio da noite)"""
	time_of_day = clamp(new_time, 0.0, 1.0)

# Função para pausar/retomar o ciclo
func set_cycle_paused(paused: bool) -> void:
	"""Pausa ou retoma o ciclo dia/noite"""
	set_physics_process(!paused)
