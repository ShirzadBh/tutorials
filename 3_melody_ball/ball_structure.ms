-- define the ball struct 
struct Ball
(
	geo = Sphere(),    -- the mesh assigned to the structure 
	pos = [0, 0, 0],   -- current position of the ball 
	pPos = [0, 0, 0],  -- prevrious position of the ball 
	vel = [0, 0, 0],   -- current velocity of the ball 
	
	
	-- Physics solver - requires the gravity and delta-time 
	fn Solve _dt _gravity = 
	(
		-- add gravity to the velocity 
		vel += _gravity * _dt 
		
		-- assign the current pos to the preveius pos 
		pPos = pos 
		
		-- apply the calculated pos using velocity to the pos of the ball
		pos += _dt * vel 
		
		-- update the position of the ball to the geo
		geo.pos = pos
	),
	
	-- Predict - calculates the trajectory of the ball using given direction 
	fn Predict _vec f_num  =
	(
		-- temp array to keep the trajectory in 
		_trej = #() 
		
		new_vel = vel
		new_pPos = pPos  
		new_pos = pos 
		
		-- adjust the new vel 
		new_vel = -(new_vel - 2 * (dot new_vel _vec) * _vec) 

		for f = 0 to f_num do 
		(
			new_vel += _gravity * _dt 
			new_pPos = new_pos 
			new_pos += _dt * new_vel 
			append _trej new_pos 
		)
		
		_trej
	),
	
	-- Shooting method - requires the direction
	fn Shoot _vec = 
	(
		vel = (vel - 2 * (dot vel _vec) * _vec) 
	),
	
	-- Delete the ball - acts as the destructure 
	fn Del = 
	(
		-- Delete the mesh assigned to it
		delete geo 
	)
)
