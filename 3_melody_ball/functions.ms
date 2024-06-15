-- functions 
fn Solve_and_Animate startFrame endFrame =
(
	animate on 
	(
		for f = startFrame to endFrame do 
		(
			at time f
			(
				_ball.Solve _dt _gravity
				redrawViews() 
			)
		)
	)
)