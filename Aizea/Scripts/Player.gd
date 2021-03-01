# El nodo Player hereda de KinematicBody2D, que este hereda de physics2D y este de Node 2D etc etc
# Godot utiliza un patron de diseño de tipo arbol de manera que todo el mundo hereda de alguien
extends KinematicBody2D

# La principal diferencia con python reside que si tu una variable no la vas a cambiar entonces asignala
# como constante esto ayuda a mejorar los tiempos de ejecucion
const ACCELERATION = 1000
const MAX_SPEED = 120
const FRICTION = 1000

# De cara a tener un codigo mejor a la hora de declarar una variable poner : seguido de su tipo esto 
# agiliza el tiempo de ejecucion y ademas permite ordenar las variables por tipos
var velocity : Vector2 = Vector2.ZERO

var collision : KinematicCollision2D 

onready var anim := $PlayerAnim
onready var anim_shadow := $PlayerAnim/ShadowAnim

# No es obligatorio pero poned los inputs y outputs de las funciones para tener un mejor codigo
# El metodo _physics_process se ejecuta en cada frame del juego, delta es el tiempo que ha pasado
# entre frame y frame y el _ de delante indica que es un metodo privado, en godot no existe la 
# encapsulacion pero la nomenclatura con _ sirve como una recomendacion 
func _physics_process(delta) -> void:
	var input_vector = Vector2.ZERO
	
	# El metodo get_action_strength sirve para tener 0 o 1 dependiendo de si esta presionado
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	# Cabe destacar que en godot arriba es negativo y abajo es positivo para facilitar el trabajo con 
	# joysticks que por razones que no comprendo funcionan asi
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# Se normaliza debido que entonces moverse en diagonal haria que fueses mas rapido
	input_vector = input_vector.normalized()
	
	# Esto se encarga de hacer las animaciones 1
	if Input.is_action_pressed("ui_right") and input_vector.y >= 0:
		anim.flip_h = false
		anim.set_animation("RunFront")
		
	elif Input.is_action_pressed("ui_left") and input_vector.y >= 0:
		anim.flip_h = true
		anim.set_animation("RunFront")
		
	elif input_vector.y < 0 and Input.is_action_pressed("ui_right"):
		anim.flip_h = true
		anim.set_animation("RunBack")
		
	elif input_vector.y < 0 and Input.is_action_pressed("ui_left"):
		anim.flip_h = false
		anim.set_animation("RunBack")
		
	elif input_vector.y > 0:
		anim.set_animation("RunFront")
		
	elif input_vector.y < 0:
		anim.set_animation("RunBack")
		if anim.get_animation() == "RunFront":
			anim.set_animation("IdleFront")
			
		elif anim.get_animation() == "RunBack":
			anim.set_animation("IdleBack")
			

	
	#walking sound
	var strm = $Running.stream as AudioStreamOGGVorbis
	strm.set_loop(false)
	
	if Input.is_action_just_pressed("ui_right"):
		$Running.play()
	elif Input.is_action_just_pressed("ui_left"):
		$Running.play()
	elif Input.is_action_just_pressed("ui_up"):
		$Running.play()
	elif Input.is_action_just_pressed("ui_down"):
		$Running.play()
	
	if Input.is_action_just_released("ui_right"):
		$Running.stop()
	elif Input.is_action_just_released("ui_left"):
		$Running.play()
	elif Input.is_action_just_released("ui_up"):
		$Running.play()
	elif Input.is_action_just_released("ui_down"):
		$Running.play()
		
		
	# Acceleracion y freno
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	

	
	# Move and colide mueve al personaje y deveulve un colider que es un objeto que sirve para saber
	# Contra que te has chocado y bastantes mas cosas
	collision = move_and_collide(velocity * delta)
