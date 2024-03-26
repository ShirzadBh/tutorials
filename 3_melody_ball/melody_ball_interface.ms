try(DestroyDialog melodyBall)catch()

-- define the ball struct 
global Ball

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

-- define the custom attribute handeling keys 
attrib = attributes "KeyAttribute"
(
parameters main rollout:params
	(
		param1 type:#boolean ui:keyParam default:10 animateable:True
	)
rollout params "Key Attribute"
	(
		checkbox keyParam "Key" type:#boolean
	)
)

rollout melodyBall "Scene Initiation" width:168 height:272
(
	global ball
	
	button 'init_btn' "Initiate The Melody Ball" width:164 height:24 align:#center
	
	on init_btn pressed do 
	(
		-- create the ball 
		ball = Ball()
		
		-- add the custom attribute to it 
		CustAttributes.add ball.geo attrib #Unique 

		-- disable the button
		init_btn.enabled=false
	)
)

createDialog melodyBall
