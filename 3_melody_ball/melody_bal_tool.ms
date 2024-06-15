-- clean the scene 
try 
(
delete objects 
gc()
)
catch()

-- create test object 
_node = Sphere radius:10 wirecolor:gray 


-- define the tool 
tool shoot_me 
(
-- local variables 
local start_point, end_point 

-- methods 

-- handlers 
on mousePoint clickno do
    (
	if clickno == 1 then 
	(	
		print clickno
		print "Start to Pull"
	) 
	else if clickno > 1 then 
	(
	-- do the shooting here ...
	
	
	-- and end the tool
	#stop
	)
    )
    
on mouseMove clickno do
    (
    	print "Pulling"
	print clickno
    )

)

startTool shoot_me 

