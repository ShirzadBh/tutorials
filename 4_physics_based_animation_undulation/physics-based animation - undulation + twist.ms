_bone_num = 8
_bone_len = 20
chain = #()
chain_rest = #()
chain_tips = #()
chain_perps = #()
simTips = #()
simVels = #()
simPerps = #()
twistVels = #()
_stiffness = .1
_damping = .7
_twistStiffness = .1
_twistDamping = .7

fn cleanup_scene = 
(
	delete objects 
	
	chain = #()
    chain_rest = #()
    chain_tips = #()
    chain_perps = #()
    simTips = #()
    simVels = #()
    simPerps = #()
    twistVels = #()
	
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
			_root.rotation = eulerAngles -20 0 -15
			_root.pos = [0,0,0]

		)

		at time 20
		(
			_root.rotation = eulerAngles 20 0 15
			_root.pos = [0,0,0]

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
	-- collect the rest pos 
	for item in chain do
	(
		_localRest = item.transform * inverse item.parent.transform
		append chain_rest _localRest
	)
	
	-- collect the rest tip 
	_last_tip = undefined
	for item in chain do
	(
		if item.children.count == 0 then
		(
			-- End bone code
			append chain_tips _last_tip
		)
		else
		(
			-- Normal bone code
			_tip = item.children[1].pos * inverse item.transform
			append chain_tips _tip
			_last_tip = _tip 

		)

	)
	
	-- collect a rest reference vector perpendicular to each bone axis (local space)
	for i = 1 to chain.count do
	(
		_axis = normalize chain_tips[i]
		_perp = cross _axis x_axis
		if length _perp < 0.001 then _perp = cross _axis y_axis
		append chain_perps (normalize _perp)
	)
)

fn initiate_sim_data = 
(
	for i = 1 to chain.count do 
	(
		append simTips (chain_tips[i] * chain[i].transform)
		append simVels [0, 0, 0]
		append simPerps (normalize ((chain_perps[i] * chain[i].transform) - chain[i].transform.pos))
		append twistVels 0.0
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
        -- Directions are opposite.
        -- Pick any axis perpendicular to A.

        local ax = cross a x_axis

        if length ax < 0.001 then
            ax = cross a y_axis

        quat -180 (normalize ax)
    )
    else
    (
        local ax = normalize (cross a b)
        local clampedDot = amin 1.0 (amax -1.0 d)
        local ang = acos clampedDot

        quat -ang ax
    )
)

fn tsSignedAngle a b axis =
(
    -- signed angle (degrees) from a to b around axis
    atan2 (dot axis (cross a b)) (dot a b)
)

fn tsRotateTMAboutPivot tm q = 
	( local p = tm.pos 
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
				print frame 
				
				for i=1 to chain.count do 
				(
					rigidTM = chain_rest[i] * chain[i].parent.transform
					rigidTip = chain_tips[i] * rigidTM

					simVels[i] += (rigidTip - simTips[i]) * _stiffness
					simVels[i] *= _damping
					simTips[i] += simVels[i]
					simTips[i] = chain[i].pos + normalize(simTips[i] - chain[i].pos) * _bone_len
					
					q = tsQuatFromTo (rigidTip - chain[i].pos) (simTips[i] - chain[i].pos) 
					tm = tsRotateTMAboutPivot rigidTM q 
					tm.pos = chain[i].pos
					
					-- twist follow-through around the bone's own axis
					boneAxis = normalize (simTips[i] - chain[i].pos)
					pRigid = normalize ((chain_perps[i] * tm) - tm.pos)
					
					-- carry last frame's twist reference over, projected onto the current bone plane
					sp = simPerps[i] - boneAxis * (dot simPerps[i] boneAxis)
					if length sp < 0.001 then sp = pRigid else sp = normalize sp
					
					theta = tsSignedAngle pRigid sp boneAxis
					twistVels[i] += (0.0 - theta) * _twistStiffness
					twistVels[i] *= _twistDamping
					theta += twistVels[i]
					
					qt = quat -theta boneAxis
					tm = tsRotateTMAboutPivot tm qt
					tm.pos = chain[i].pos
					simPerps[i] = normalize ((chain_perps[i] * tm) - tm.pos)
					
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
