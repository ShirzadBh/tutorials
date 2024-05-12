showTrej = false 
try(unregisterRedrawViewsCallback visualizer)catch()

-- Trajectory visualizer
fn visualizer =
(
	gw.setColor #line yellow   

	-- draw the polyline 
	gw.polyline trej false
	for p in trej do 
	(
		gw.Marker p #smallHollowBox color:orange    
	)
	gw.enlargeUpdateRect #whole  
)

registerRedrawViewsCallback visualizer

