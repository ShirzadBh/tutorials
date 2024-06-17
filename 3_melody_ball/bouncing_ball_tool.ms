
-- clean up the scene 
unregisterRedrawViewsCallback debug 

-- global parameters and variables 
global grab_point, release_point, frames, trajectory, _deltaTime, _gravity 

grab_point = [0, 0, 0]       -- position where we start grabbing (for simplicity, I'll assign it to the node position)
release_point = [0, 0, 10]    -- position where we release the mouse to shoot the node 
frames = 40                -- number of frames we want to simulate
trajectory = #()             -- an array of positions to debug the trajectory of the node 

-- physical parameters 
_deltaTime = (1.0 / frameRate) * 8     -- fraction of the second we want to simulate each frame 
_gravity = [0, 0, -10.0]               -- the force of gravity that the node will follow 



-- the debugger (trajectory previewer)
fn debug = 
(
	gw.setTransform (Matrix3 1)

	-- display the grab and release point as a line 
	gw.Polyline #(grab_point, release_point) false rgb:#(yellow, green)

	-- display a text showing the number of frames we want to simulate for 
	gw.hText [mouse.pos.x, (gw.getWinSizeY() - mouse.pos.y) - 30, 0] ("Simulate for: #[" + frames as string + "]") color:green

	-- display the amount of the force we're applying 
	gw.hText [mouse.pos.x, (gw.getWinSizeY() - mouse.pos.y) - 46, 0] ("Force: #[" + (length (grab_point - release_point) as string) + "]") color:green

	-- set polyline color 
	gw.setColor #line yellow

	-- display the trajectory 
	gw.polyline trajectory false 

	gw.enlargeUpdateRect #whole
)


-- simulation function 
fn simulate _node:undefined _force:[0, 0, 0] anim:false f_num:0 = 
(
	-- temp array for the simulation results 
	_trej = #()

	-- initiate the physical properties 
	_vel = _force 
	_pPos = _node.pos 
	_pos = _node.pos

	-- simulate the results 
	for f = 0 to f_num do 
	(
		_vel += _gravity * _deltaTime
		_pPos = _pos
		_pos += _deltaTime * _vel
		append _trej _pos
	)
	
	if not anim then 
	(
		_trej
	) 
	else 
	(
		-- animate the object 
		undo on 
		(
			animate on 
			(
				-- get the current frame as integer 
				_currentFrame = (sliderTime as integer / ticksPerFrame)
				ind = 1
				for f = _currentFrame to (_currentFrame + f_num) do 
				(
					at time (f+1)
					(
						_node.pos = _trej[ind]
					)
					ind += 1
				)
			)
		)
		_trej
	)
)

-- trajectory = simulate _node:selection[1] _force:[-20, 8, 20] anim:true f_num:40



-- define the tool 
tool Shooter 
(
	-- local variables 
	local _node, _force
	
	-- tool handlers 
	on start do 
	(
		if selection.count != 1 then #stop else _node = selection[1]
	)
	
	on stop do 
	(
		unregisterRedrawViewsCallback debug 
	)
	
	on mousePoint clickno do 
	(
		if clickno == 1 then 
		(
			-- perform the grabbing action 
			grab_point = _node.pos
			
			-- register the debug 
			registerRedrawViewsCallback debug
		)
		else if clickno == 2 then 
		(
			-- perform the shooting action
			simulate _node:_node _force:_force anim:true f_num:frames 
			
			-- and stop the tool 
			#stop
		)
	)
	
	on mouseMove clickno do 
	(
		-- calculate the force 
		_force = grab_point - release_point 
		
		-- assign the release point 
		release_point = worldPoint 
		
		-- visualize the trajectory 
		trajectory = simulate _node:_node _force:_force anim:false f_num:frames
		
		-- redraw viewport 
		redrawViews()
	)
)


-- run the tool 
startTool Shooter 











