_bone_num = 8
_bone_len = 20
chain = #()
chain_rest = #()
chain_tips = #()
simTips = #()
simVels = #()
_stiffness = .1
_damping = .7

fn cleanup_scene = 
(
	delete objects 
	
	chain = #()
	chain_rest = #()
	chain_tips = #()
	simTips = #()
	simVels = #()
	
	gc()
	clearListener()
)

fn setup_scene =
(
	n = _bone_num
	len = _bone_len

	_last_bone = undefined
	_root = undefined 
	for i = 0 to n-1 do
	(
		_bone = BoneSys.createBone [i*len,0,0] [(i+1)*len,0,0] [0,0,1]
	
		if _root == undefined then (_root = _bone) else (append chain _bone)

		if _last_bone != undefined then (_bone.parent = _last_bone)

		_last_bone = _bone
	)
	
	animate on
	(
		at time 10
		(
			_root.rotation = eulerAngles 0 0 -15
			_root.pos = [0,10,0]
		)

		at time 20
		(
			_root.rotation = eulerAngles 0 0 15
			_root.pos = [0,-10,0]
		)
		
		at time 30
		(
			_root.rotation = eulerAngles 0 0 0
			_root.pos = [0,0,0]
		)
	)
)

fn initiate_data = 
(
	-- collect the rest pose (local transform relative to parent)
	for item in chain do
	(
		_localRest = item.transform * inverse item.parent.transform
		append chain_rest _localRest
	)
	
	-- collect the rest tip (bone tip position in the bone's own space)
	_last_tip = undefined
	for item in chain do
	(
		if item.children.count == 0 then
		(
			-- end bone: reuse the previous bone's tip offset
			append chain_tips _last_tip
		)
		else
		(
			_tip = item.children[1].pos * inverse item.transform
			append chain_tips _tip
			_last_tip = _tip 
		)
	)
)

fn initiate_sim_data = 
(
	for i = 1 to chain.count do 
	(
		append simTips (chain_tips[i] * chain[i].transform)
		append simVels [0, 0, 0]
	)
)

fn tsQuatFromTo a b =
(
	-- Rotation quaternion that takes direction A onto direction B
	-- Both directions are in world space.
	a = normalize a
	b = normalize b

	local d = dot a b

	if d > 0.99999 then
	(
		quat 0 0 0 1
	)
	else if d < -0.99999 then
	(
		-- Directions are opposite: pick any axis perpendicular to A.
		local ax = cross a x_axis
		if length ax < 0.001 then ax = cross a y_axis
		quat -180 (normalize ax)
	)
	else
	(
		local ax = normalize (cross a b)
		local ang = acos (amin 1.0 (amax -1.0 d))
		quat -ang ax
	)
)

fn tsRotateTMAboutPivot tm q = 
(
	local p = tm.pos 
	tm * (transMatrix -p) * (q as matrix3) * (transMatrix p) 
)

fn simulate frames:100 = 
(
	animate on
	(
		for frame=1 to frames do 
		(
			at time frame
			(
				for i=1 to chain.count do 
				(
					-- where the bone would be if it rigidly followed its parent
					rigidTM = chain_rest[i] * chain[i].parent.transform
					rigidTip = chain_tips[i] * rigidTM

					-- spring-damper integration (per frame)
					simVels[i] += (rigidTip - simTips[i]) * _stiffness
					simVels[i] *= _damping
					simTips[i] += simVels[i]

					-- length constraint: bone rotates, never stretches
					simTips[i] = chain[i].pos + normalize(simTips[i] - chain[i].pos) * _bone_len
					
					-- aim the bone at its simulated tip and key it
					q = tsQuatFromTo (rigidTip - chain[i].pos) (simTips[i] - chain[i].pos) 
					tm = tsRotateTMAboutPivot rigidTM q 
					tm.pos = chain[i].pos
					
					chain[i].transform = tm
				)
			)
		)
	)
)

cleanup_scene() 
setup_scene()
at time 0
(
	initiate_data()
	initiate_sim_data()
)
simulate frames:100
