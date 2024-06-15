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
    gw.enlargeUpdateRect #whole  
)



-- create test object 
_sphere = Sphere radius:10 wirecolor:gray 

-- global debug variables 
global _start, _end 

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

on mousePoint clickno do
    (
	if clickno == 1 then 
	(	
		print clickno
		print "Start to Pull"
	
		-- assign the start point position 
		_start = worldPoint 
	
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

