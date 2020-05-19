extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500

var velocity = Vector2.ZERO

# 游戏建议在全屏模式下运行，窗口模式总会有一些bug

# 每一个physics frame都会调用一次
# delta更多的用处是让角色的移动更加接近于现实时间，因为它于帧相连
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	# 这里x轴和y轴移动一次都是一个像素
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# 这里就是把向量标准化，让他们的值都是一，避免斜线移动的时候有着根号二的速度，不协调
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		# velocity = input_vector* MAX_SPEED
		#velocity += input_vector * ACCELERATION * delta
		# clamped函数就是返回MAX_SPEED * delta作为最大值
		# 更准确的说是调整velocity保证它不会超过MAX_SPEED
		#velocity = velocity.clamped(MAX_SPEED)
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		print(velocity)
	else:
		# 让速度慢慢趋近于0，并且每次减少的量为Friction * delta
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# 这里的delte相当于给速度做个限制，比如游戏是60帧的话，delta就会使接近1/60
	# 这样让角色的运动更接近于实际运动时间
	# 让对象沿着这个vector移动，知道撞到东西
	#move_and_collide(velocity * delta)
	
	# 让物体能够沿着墙滑动，而不是直接装上去
	# 需要注意的是这个函数自己处理了delta，因此参数直接放进去velocity
	# 函数返回了物体碰撞到障碍后变化后的速度向量
	velocity =  move_and_slide(velocity)

