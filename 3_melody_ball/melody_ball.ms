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
	vel = [0, 0, 0]
)



-- clear the scene 
clean_up() 

