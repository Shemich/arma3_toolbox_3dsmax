plugin light ArmAthreeLights

name:"Three Lights"

(

local master

tool create

(

on mousePoint click do

(

if click == 1 then -- create key, back & fill lights at mousedown

(

coordsys grid

(

master = ArmAlightMaster pos:gridPoint

master.dummy.boxsize = [10,10,10]

in master

(

local targObj=targetobject pos:gridPoint

master.key = targetspot pos:gridPoint name:"key" \

target:targObj multiplier:1.84 rgb:(color 255 240 184)

master.fill = targetspot pos:gridPoint name:"back" \

target:targObj multiplier:0.84 rgb:(color 154 184 219)

master.back = targetspot pos:gridPoint name:"fill" \

target:targObj multiplier:0.77 rgb:(color 254 238 233)


)

)

addPluginRollouts master

)

if click == 3 then

(

select master

master = undefined

#stop

)

)

on mouseMove click do

(

if click == 2 then -- drag out & round on x-y plane

(

-- place the key on the grid then set the spread and the

-- 'on set spread' handler will

-- move the lights to the correct heights

master.key.pos = worldPoint

master.spread = distance master.key master.key.target

)

else if click == 3 then -- drag up to elevate lights

master.height = gridDist.z

)

on mouseAbort click do

(

if master != undefined then

(

if master.fill != undefined then delete master.fill

if master.back != undefined then delete master.back

if master.key != undefined then delete master.key

delete master

)

)

)

)

