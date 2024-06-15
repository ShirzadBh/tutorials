-- clean the scene 
try 
(
delete objects 
gc()
)
catch()

-- global debug variables 
global _start, _end, frames, _trej
_start = [0, 0, 0]
_end = [0, 0, 0]
frames = 40
_trej = #()

-- define physical properties 
_dt = 1.0 / frameRate
_gravity = [0, 0, -100]


fn simulate _node:undefined _force:[0, 0, 0] anim:false f_num:0 =
(
	
	-- temp array to keep the trajectory in 
	_trej = #() 
	
	-- initiate physical properties 
	new_vel = _force
	new_pPos = _node.pos  
	new_pos = _node.pos 


	for f = 0 to f_num do 
	(
		new_vel += _gravity * _dt 
		new_pPos = new_pos 
		new_pos += _dt * new_vel 
		append _trej new_pos 
	)
	
	if not anim then 
	(
		_trej
	)
	else 
	(
		-- animate the object 
		_trej
	)
)

-- debug function 
fn debug_line = 
(
    gw.setTransform (matrix3 1)
    gw.Polyline #(_start, _end) false rgb:#(yellow, green) 
	gw.hText  [mouse.pos.x,(gw.getWinSizeY() - mouse.pos.y) - 30, 0]  ("Simulate For: #[" + frames as string + "] Frames") color:green
	gw.hText  [mouse.pos.x,(gw.getWinSizeY() - mouse.pos.y) - 46, 0]  ("Force: " + ((length (_start - _end)) as string)) color:green
	_currentFrame = (sliderTime as integer / ticksPerFrame)
	gw.hText  [mouse.pos.x,(gw.getWinSizeY() - mouse.pos.y) - 62, 0]  ("Range: #[" + (_currentFrame) as string + "] => #[" + (_currentFrame + frames) as string + "]") color:yellow
	gw.setColor #line yellow 
	gw.Polyline _trej false 
	gw.enlargeUpdateRect #whole
)

-- create test object 
_sphere = Sphere radius:10 wirecolor:gray 


-- define the tool 
tool shoot_me 
(
-- local variables 
local _node, start_point, end_point 
 
-- methods 


-- handlers 

on start do 
(
if selection.count != 1 then #stop 
)

on stop do 
(
unregisterRedrawViewsCallback debug_line
)



on mousePoint clickno do
    (
	if clickno == 1 then 
	(	
		_node = selection[1]
		print clickno
		print "Start to Pull"
	
		-- assign the start point position 
		_start = worldPoint 
		_start = _node.pos 
	
		registerRedrawViewsCallback debug_line
	) 
	else if clickno > 1 then 
	(
	-- do the shooting here ...
	print ("Start Pos: " + _start as string)
	print ("End Pos: " + _end as string)
		

	
	-- and end the tool
	unregisterRedrawViewsCallback debug_line
	#stop
	)
    )
    
on mouseMove clickno do
    (
    	print "Pulling"
		-- calculate the force 
		_vel = _start - _end 
    	simulate _node:_node _force:_vel f_num:frames

	-- assign the end point 
	_end = worldPoint 
    
		
	-- redraw 
	redrawViews()
    )
)


-- select the test node 
select _sphere 
startTool shoot_me 

