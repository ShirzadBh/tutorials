-- clean up the scene 
fn clean_up =  (
	delete objects    -- remove all the objects 
	gc()              -- free the grabage collector
	clearListener()   -- clear up the listener
)

-- define the ball struct 
struct Ball
(
	geo = Sphere(),
	pPos = [0, 0, 0],
	vel = [0, 0, 0],
	
	-- update function for the ball at each frame
	fn update_me _dt _gravity = 
	(
		-- add gravity to the velocity 
		vel += _gravity * _dt 
		
		-- assign the current pos to the preveius pos 
		pPos = geo.pos 
		
		-- apply the calculated pos using velocity to the pos of the ball
		geo.pos += _dt * vel 
	),
	
	-- add bounce point 
	fn bounce _vec _bounciness:1 = 
	(
		-- normalize the vector (we just want its directon)
		_vec = normalize _vec
		
		-- calculate the reflection vector and apply it to the velocity
		vel = (vel - 2 * (dot vel _vec) * _vec) * _bounciness
	)
)

-- clear the scene 
clean_up() 

-- create the ball 
ball = Ball() 

-- define physical properties 
_dt = 1.0 / frameRate
_gravity = [0, 0, -10]

-- a for loop to calculate the frames 
for f = 0 to 500 do 
(
	ball.update_me _dt _gravity
	if f == 250 then (ball.bounce [0, 0, 1] _bounciness:1)
	redrawViews() 
)