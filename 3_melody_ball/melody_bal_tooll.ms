-- clean the scene 
try 
(
delete objects 
gc()
)
catch()

-- global debug variables 
global grab_point, release_point, frames, trajectory
grab_point = [0, 0, 0]
release_point = [0, 0, 0]
frames = 40
trajectory = #()

-- define physical properties 
_deltaTime = (1.0 / frameRate) * 8
_gravity = [0, 0, -10]


fn simulate _node:undefined _force:[0, 0, 0] anim:false f_num:0 =
(
	
	-- temp array to keep the trajectory in 
	trajectory = #() 
	
	-- initiate physical properties 
	_vel = _force
	_pPos = _node.pos  
	_pos = _node.pos 


	for f = 0 to f_num do 
	(
		_vel += _gravity * _deltaTime 
		_pPos = _pos 
		_pos += _deltaTime * _vel 
		append trajectory _pos 
	)
	
	if not anim then 
	(
		trajectory
	)
	else 
	(
		-- animate the object 
		undo on 
		(
			animate on 
			(
				_currentFrame = (sliderTime as integer / ticksPerFrame)
				ind = 1
				for f = _currentFrame to (_currentFrame + f_num) do 
				(
					at time (f+1)
					(
						_node.pos = trajectory[ind]
					)
					ind += 1
				)
			)
		)
		trajectory
	)
)

-- debug function 
fn debug_line = 
(
    gw.setTransform (matrix3 1)
    gw.Polyline #(grab_point, release_point) false rgb:#(yellow, green) 
	gw.hText  [mouse.pos.x,(gw.getWinSizeY() - mouse.pos.y) - 30, 0]  ("Simulate For: #[" + frames as string + "] Frames") color:green
	gw.hText  [mouse.pos.x,(gw.getWinSizeY() - mouse.pos.y) - 46, 0]  ("Force: " + ((length (grab_point - release_point)) as string)) color:green
	_currentFrame = (sliderTime as integer / ticksPerFrame)
	gw.hText  [mouse.pos.x,(gw.getWinSizeY() - mouse.pos.y) - 62, 0]  ("Range: #[" + (_currentFrame) as string + "] => #[" + (_currentFrame + frames) as string + "]") color:yellow
	gw.setColor #line yellow 
	gw.Polyline trajectory false 
	gw.enlargeUpdateRect #whole
)

-- create test object 
_sphere = Sphere radius:10 wirecolor:gray 


-- define the tool 
tool shoot_me 
(
-- local variables 
local _node, _force
 
-- handlers 

on start do 
(
	if selection.count != 1 then #stop else _node = selection[1]
)

on stop do 
(
unregisterRedrawViewsCallback debug_line
)



on mousePoint clickno do
    (
		if clickno == 1 then 
		(	
			-- assign the start point position 
			grab_point = _node.pos 
		
			registerRedrawViewsCallback debug_line
		) 
		else if clickno == 2 then 
		(
			-- do the shooting here ...
			simulate _node:_node _force:_force anim:true f_num:frames

			#stop
		)
    )
    
on mouseMove clickno do
    (
		-- calculate the force 
		_force = grab_point - release_point 

		-- assign the end point 
		release_point = worldPoint 
		
		-- visualize the trajectory
		simulate _node:_node _force:_force f_num:frames
			
		-- redraw 
		redrawViews()
    )
)


-- select the test node 
select _sphere 
startTool shoot_me 

