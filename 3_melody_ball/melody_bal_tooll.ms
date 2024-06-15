-- clean the scene 
try 
(
delete objects 
gc()
)
catch()

-- debug function 
fn debug_line = 
(
    gw.setTransform (matrix3 1)
    gw.Polyline #(_start, _end) false rgb:#(red, yellow) 
	gw.hText  [mouse.pos.x,(gw.getWinSizeY() - mouse.pos.y) - 30, 0]  ("Simulate For: #[" + frames as string + "] Frames") color:green
	gw.hText  [mouse.pos.x,(gw.getWinSizeY() - mouse.pos.y) - 46, 0]  ("Force: " + ((length (_start - _end)) as string)) color:green
	_currentFrame = (sliderTime as integer / ticksPerFrame)
	gw.hText  [mouse.pos.x,(gw.getWinSizeY() - mouse.pos.y) - 62, 0]  ("Range: #[" + (_currentFrame) as string + "] => #[" + (_currentFrame + frames) as string + "]") color:yellow
    gw.enlargeUpdateRect #whole
)

30 - 46
16 + 46
-- create test object 
_sphere = Sphere radius:10 wirecolor:gray 

-- global debug variables 
global _start, _end, frames
_start = [0, 0, 0]
_end = [0, 0, 0]


-- define the tool 
tool shoot_me 
(
-- local variables 
local _node, start_point, end_point 
 
-- methods 


-- handlers 

on start do 
(
frames = 20
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
    
	-- assign the end point 
	_end = worldPoint 
    
	-- redraw 
	redrawViews()
    )
)


-- select the test node 
select _sphere 
startTool shoot_me 

