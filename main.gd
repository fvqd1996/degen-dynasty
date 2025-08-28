extends Node2D

var money = 1000.0
var price = 100.0
var coins = 0
var combo = 0
var last_action = ""
var price_history = []  # ADD THIS
var max_history_points = 50  # ADD THIS

func _ready():
	create_ui()
	update_labels()
	
	# SET THE VIBE
	RenderingServer.set_default_clear_color(Color(0.1, 0.05, 0.15))  # DARK PURPLE BACKGROUND
	
	# SPAWN RANDOM EVENTS
	var timer = Timer.new()
	timer.wait_time = randf_range(2, 5)
	timer.timeout.connect(_on_random_event)
	timer.autostart = true
	add_child(timer)
	
	# Create a background
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.05, 0.15)  # Dark purple
	bg.size = get_viewport().size
	bg.position = Vector2(0, 0)
	add_child(bg)
	move_child(bg, 0)  # Put it behind everything

func _on_random_event():
	var events = [
		{"text": "MARKET PUMP!!! 🚀", "effect": randf_range(1.5, 2.0)},
		{"text": "WHALE ALERT! 🐋", "effect": randf_range(0.8, 1.2)},
		{"text": "CHINA BANS CRYPTO! 💥", "effect": randf_range(0.3, 0.7)},
		{"text": "ELON TWEETED! 😱", "effect": randf_range(0.1, 3.0)},
		{"text": "RUG PULL INCOMING! 💀", "effect": randf_range(0.1, 0.5)}
	]
	var event = events[randi() % events.size()]
	create_notification(event.text)
	price *= event.effect  # More dramatic price swings
	
	# Show it on screen instead of console!
	create_notification(event.text)
	
	# Make it affect the game
	price *= randf_range(0.8, 1.2)

func create_ui():
	# Money - TOP LEFT
	var money_label = Label.new()
	money_label.name = "MoneyLabel"
	money_label.position = Vector2(50, 50)  # TOP LEFT
	money_label.add_theme_font_size_override("font_size", 48)
	add_child(money_label)
	
	# Price - CENTER but HIGHER
	var price_label = Label.new()
	price_label.name = "PriceLabel"
	price_label.position = Vector2(400, 200)  # MOVED UP
	price_label.add_theme_font_size_override("font_size", 72)  # BIGGER
	add_child(price_label)
	
	# MAKE IT LOOK DOPE - Don't use 'var' again!
	money_label.add_theme_color_override("font_color", Color(0, 1, 0))
	money_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	money_label.add_theme_constant_override("shadow_offset_x", 3)
	money_label.add_theme_constant_override("shadow_offset_y", 3)
	
	price_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	price_label.add_theme_constant_override("shadow_offset_x", 4)
	price_label.add_theme_constant_override("shadow_offset_y", 4)
	
	# MAKE THE BUTTONS THICC
	if has_node("BuyButton"):
		$BuyButton.add_theme_font_size_override("font_size", 24)
		$BuyButton.custom_minimum_size = Vector2(150, 80)
	if has_node("SellButton"):
		$SellButton.add_theme_font_size_override("font_size", 24)  
		$SellButton.custom_minimum_size = Vector2(150, 80)
		
	# Create a background panel for the price
	var panel = Panel.new()
	panel.position = Vector2(300, 150)
	panel.size = Vector2(400, 150)
	panel.modulate = Color(0, 0, 0, 0.7)  # Semi-transparent black
	add_child(panel)	
	
	# Net worth display
	var net_worth_label = Label.new()
	net_worth_label.name = "NetWorthLabel"
	net_worth_label.position = Vector2(50, 150)
	net_worth_label.add_theme_font_size_override("font_size", 36)
	add_child(net_worth_label)
	
	print("UI Created!")

func _process(delta):
	# PRICE GOES ABSOLUTELY MENTAL
	var volatility = randf_range(0.95, 1.05)  # 5% swings per frame!
	price *= volatility
	
	# Recovery mechanism
	if price <= 1:
		price = randf_range(1, 5)  # Small chance to bounce back
	
	price = clamp(price, 1, 9999)
	
	price_history.append(price)
	if price_history.size() > max_history_points:
		price_history.pop_front() 
		
	if Engine.get_frames_drawn() % 10 == 0:  # Update every 10 frames
		draw_chart()
	
	update_labels()
	
	# FLASH THE PRICE WITH COCAINE ENERGY
	if has_node("NetWorthLabel"):
		var net_worth = money + (coins * price)  # Added TAB/4 spaces
		$NetWorthLabel.text = "Net Worth: $" + str(int(net_worth))
		
		# Status based on wealth
		if net_worth > 100000:
			$NetWorthLabel.text += "\n🏎️ LAMBO STATUS"
		elif net_worth > 50000:
			$NetWorthLabel.text += "\n🏠 PENTHOUSE VIBES"
		elif net_worth > 10000:
			$NetWorthLabel.text += "\n📈 WINNING"
		elif net_worth > 500:
			$NetWorthLabel.text += "\n😅 SURVIVING"  
		else:
			$NetWorthLabel.text += "\n📦 REKT"

func _on_buy_button_pressed():
	if money >= price:
		money -= price
		coins += 1
		
		# COMBO SYSTEM
		if last_action == "sell":
			combo += 1
			print("COMBO x" + str(combo) + "!!!")
		last_action = "buy"
		
		# EXPLOSION OF DOPAMINE
		if has_node("MoneyLabel"):
			flash_label($MoneyLabel, Color(1, 0, 0))  # RED = SPENT
			
		# RANDOM MULTIPLIER SOMETIMES
		if randf() < 0.1:  # 10% chance
			coins += randi_range(1, 5)
			print("🎰 BONUS COINS!!!")
			
		update_labels()
		screen_shake()

func _on_sell_button_pressed():
	if coins > 0:
		var sell_price = price * (1.0 + (combo * 0.1))  # COMBO MULTIPLIER
		money += sell_price
		coins -= 1
		
		if last_action == "buy":
			combo += 1
		last_action = "sell"
		
		# MONEY EXPLOSION
		if has_node("MoneyLabel"):
			flash_label($MoneyLabel, Color(0, 1, 0))  # GREEN = PROFIT
			
		update_labels()
		screen_shake()

func flash_label(label, color):
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(label, "scale", Vector2(2, 2), 0.1)
	tween.tween_property(label, "modulate", color, 0.1)
	tween.chain()
	tween.tween_property(label, "scale", Vector2(1, 1), 0.1)
	tween.tween_property(label, "modulate", Color.WHITE, 0.1)

func screen_shake():
	var tween = create_tween()
	var original_pos = position
	for i in range(5):
		tween.tween_property(self, "position", original_pos + Vector2(randf_range(-10, 10), randf_range(-10, 10)), 0.02)
	tween.tween_property(self, "position", original_pos, 0.02)

func update_labels():
	if has_node("MoneyLabel"):
		$MoneyLabel.text = "$" + str(int(money))
		# Color based on wealth
		if money > 5000:
			$MoneyLabel.modulate = Color(0, 1, 0)  # Rich = Green
		elif money > 1000:
			$MoneyLabel.modulate = Color(1, 1, 0)  # OK = Yellow
		else:
			$MoneyLabel.modulate = Color(1, 0, 0)  # Poor = Red
			
	if has_node("PriceLabel"):
		$PriceLabel.text = "COIN: $" + str(int(price))

func spawn_money_particle(pos, going_up):
	var label = Label.new()
	label.text = "$$$" if going_up else "💸"
	label.position = pos
	label.add_theme_font_size_override("font_size", 32)
	add_child(label)
	
	var tween = create_tween()
	var end_pos = pos + Vector2(randf_range(-100, 100), -200 if going_up else 200)
	tween.tween_property(label, "position", end_pos, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_callback(label.queue_free)

func create_notification(text: String):
	var notif = Label.new()
	notif.text = text
	notif.add_theme_font_size_override("font_size", 36)
	notif.position = Vector2(400, 300)  # Center screen
	notif.modulate = Color(1, 1, 0)  # Yellow
	
	# Style it
	notif.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	notif.add_theme_constant_override("shadow_offset_x", 4)
	notif.add_theme_constant_override("shadow_offset_y", 4)
	
	add_child(notif)
	
	# Animate it
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(notif, "position:y", 100, 1.0)
	tween.tween_property(notif, "modulate:a", 0, 1.0).set_delay(0.5)
	tween.chain()
	tween.tween_callback(notif.queue_free)

func draw_chart():
	if price_history.size() < 2:
		return  # Need at least 2 points to draw a line
	
	# Create/update the chart node
	if not has_node("Chart"):
		var chart = Node2D.new()
		chart.name = "Chart"
		chart.position = Vector2(700, 100)  # Top right
		add_child(chart)
	
	var chart = $Chart
	
	# Clear previous drawing
	for child in chart.get_children():
		child.queue_free()
	
	# Chart dimensions
	var chart_width = 300
	var chart_height = 200
	
	# Draw background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5)
	bg.size = Vector2(chart_width, chart_height)
	chart.add_child(bg)
	
	# Find min/max for scaling
	var min_price = price_history.min()
	var max_price = price_history.max()
	var price_range = max_price - min_price
	if price_range < 10:
		price_range = 10
		min_price = max(0, min_price - 5)  # Show some space below
	
	# Grid lines
	for i in range(5):
		var grid_line = Line2D.new()
		grid_line.add_point(Vector2(0, i * chart_height / 4))
		grid_line.add_point(Vector2(chart_width, i * chart_height / 4))
		grid_line.default_color = Color(1, 1, 1, 0.1)
		grid_line.width = 1
		chart.add_child(grid_line)
	
	# Draw the line
	var line = Line2D.new()
	line.width = 3.0
	if price > price_history[-2]:
		line.default_color = Color(0, 1, 0)  # Green when going up
	else:
		line.default_color = Color(1, 0, 0)  # Red when going down
	
	# Add points to the line
	for i in range(price_history.size()):
		var x = (i / float(price_history.size() - 1)) * chart_width
		var y = chart_height - ((price_history[i] - min_price) / price_range) * chart_height
		line.add_point(Vector2(x, y))
	
	chart.add_child(line)
	
	# Add price labels
	var high_label = Label.new()
	high_label.text = "$" + str(int(max_price))
	high_label.position = Vector2(chart_width + 5, 0)
	high_label.add_theme_font_size_override("font_size", 16)
	chart.add_child(high_label)
	
	var low_label = Label.new()
	low_label.text = "$" + str(int(min_price))
	low_label.position = Vector2(chart_width + 5, chart_height - 20)
	low_label.add_theme_font_size_override("font_size", 16)
	chart.add_child(low_label)
	
	# Add title
	var title = Label.new()
	title.text = "Price History"
	title.position = Vector2(0, -30)
	title.add_theme_font_size_override("font_size", 20)
	chart.add_child(title)

	# Current price indicator
	var current_price_label = Label.new()
	current_price_label.text = "Now: $" + str(int(price))
	current_price_label.position = Vector2(chart_width/2 - 30, -50)
	current_price_label.add_theme_font_size_override("font_size", 24)
	current_price_label.modulate = line.default_color
	chart.add_child(current_price_label)
