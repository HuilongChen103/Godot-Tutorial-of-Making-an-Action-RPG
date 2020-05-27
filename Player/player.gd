extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500

# 状态机的状态
enum{
	MOVE, 	# 默认值为0
	ROLL,	# 默认值为1
	ATTACK	# 默认值为2
}

var state = MOVE
var velocity = Vector2.ZERO

# 这个节点在准备好之后会加载AnimationPlayer，和下面的_ready()函数效果一样
onready var animationPlayer = $AnimationPlayer

onready var animationTree = $AnimationTree

# playback放的是AnimationNodeState，存放的是AnimationPlayer里面的不同animation
onready var animationState = $AnimationTree.get("parameters/playback")

# _ready()函数会在这个node准备好之后调用，如果它有子节点，则会在子节点的
# _ready()函数调用完毕后调用
func _ready():
	# 这个$表示选择子节点的内容 绿色表示这个一个path to node
#	animationPlayer = $AnimationPlayer
	animationTree.active = true

# 游戏建议在全屏模式下运行，窗口模式总会有一些bug

# 每一个physics frame都会调用一次
# delta更多的用处是让角色的移动更加接近于现实时间，因为它于帧相连
func _physics_process(delta):
	# 等同于switch
	match state:
		MOVE: move_state(delta)
		ATTACK: attack_state(delta)
		ROLL: pass


func move_state(delta):
	var input_vector = Vector2.ZERO
	# 这里x轴和y轴移动一次都是一个像素
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# 这里就是把向量标准化，让他们的值都是一，避免斜线移动的时候有着根号二的速度，不协调
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		# 设置blend_position的位置用于动画树播放动画
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		# 把attack放在这里是因为攻击有方向，并且要根据input_vector来判断方向
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
	else:
		# 让速度慢慢趋近于0，并且每次减少的量为Friction * delta
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	# 这里的delte相当于给速度做个限制，比如游戏是60帧的话，delta就会使接近1/60
	# 这样让角色的运动更接近于实际运动时间
	# 让对象沿着这个vector移动，知道撞到东西
	#move_and_collide(velocity * delta)
	
	# 让物体能够沿着墙滑动，而不是直接装上去
	# 需要注意的是这个函数自己处理了delta，因此参数直接放进去velocity
	# 函数返回了物体碰撞到障碍后变化后的速度向量
	velocity =  move_and_slide(velocity)
	
	# 判断如果刚刚按下了attack攻击键，就切换状态
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func attack_animation_finished():
	state = MOVE
