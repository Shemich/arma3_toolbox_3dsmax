/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: 01texture.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                                *
* Author: Soul_Assasin <vorobiev.a.j@gmail.com >,                                                  *
* Author: Soul_Assasin <vorobiev.a.j@gmail.com >,                                                  *
*                                                                                                                     *
* LICENSE:  This  program  is  free  software:  you can redistribute it and/or         *
* modify it under the terms of the  GNU General Public License as published by         *
* the Free Software Foundation, either version 3 of the License,  or  (at your           *
* option) any later version.                                                                                 *
* This program is  distributed in the hope that it will be useful, but WITHOUT        *
* ANY  WARRANTY;   without  even  the  implied  warranty of MERCHANTABILITY or *
* FITNESS FOR A PARTICULAR PURPOSE.   See  the  GNU General Public License for *
* more details.                                                                *
* You should have received a copy of the GNU General Public License along with         *
* this program. If not, see <http://www.gnu.org/licenses/gpl.txt>.                            *
*                                                                                                                     *
*******************************************************************************/

fn BakeAmbient obj sizeX sizeY filePath padding samples spread density darkC lightC=
(
	try (
		renderers.current = mental_ray_renderer()
	)catch(messagebox "The current version of max does not have the mental ray renderer which is required to bake occlusion maps. \t")
	try (
		obj.iNodeBakeProperties.removeAllBakeElements()
		
		ambBake = AmbientOcclusionBakeElement()
		
		ambBake.outputSzX = sizeX
		ambBake.outputSzY = sizeY
		
		ambBake.dark = darkC
		ambBake.bright = lightC
		ambBake.fileType = filePath
		ambBake.fileName = filenameFromPath ambBake.fileType
		ambBake.samples = samples
		ambBake.maxDistance = spread
		ambBake.spread = density
		ambBake.enabled = true
		
		obj.iNodeBakeProperties.addBakeElement ambBake
		obj.INodeBakeProperties.bakeChannel = 1
		obj.iNodeBakeProperties.bakeEnabled = true
		obj.iNodeBakeProperties.nDilations = padding
		
		render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[sizeX,sizeY]
		success = true
	) catch (
		success = false
	)
	return success
)

fn BakeDiffuse obj sizeX sizeY filePath padding=
(
	try (
		obj.iNodeBakeProperties.removeAllBakeElements()
		
		ambBake = diffuseMap()
		
		ambBake.outputSzX = sizeX
		ambBake.outputSzY = sizeY
		ambBake.fileType = filePath
		ambBake.fileName = filenameFromPath ambBake.fileType
		ambBake.filterOn = true
		ambBake.shadowsOn = false
		ambBake.lightingOn = false
		ambBake.enabled = true
		
		obj.iNodeBakeProperties.addBakeElement ambBake
		obj.INodeBakeProperties.bakeChannel = 1
		obj.iNodeBakeProperties.bakeEnabled = true
		obj.iNodeBakeProperties.nDilations = padding
		
		render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[sizeX,sizeY]
		success = true
	) catch (
		success = false
	)
	return success
)

fn PreviewMat obj filePath=
(
	newBitmap = bitmaptexture filename:filePath
	newMat = standard diffusemap:newBitmap
	newMat.showInViewport = true
	obj.material = newMat
)
	
global textureDimsX = 1024
global textureDimsY = 1024

rollout textureRoll "Texture" width:264 height:456
(
	GroupBox grp2 "Global" pos:[8,8] width:248 height:120

	checkbutton size_256 "256" pos:[16,24] width:40 height:24 toolTip:"256 x 256"


	checkbutton size_512 "512" pos:[56,24] width:40 height:24 toolTip:"512 x 512"


	checkbutton size_1024 "1024" pos:[96,24] width:40 height:24 toolTip:"1024 x 1024"


	checkbutton size_2048 "2048" pos:[136,24] width:40 height:24 toolTip:"2048 x 2048"


	checkbutton size_custom "Custom" pos:[176,24] width:72 height:24 toolTip:"Custom size"


	GroupBox grp3 "Custom Size" pos:[16,56] width:232 height:40

	spinner size_w "W" pos:[34,72] width:70 height:16 enabled:false range:[1,10000,4096] type:#integer


	label lbl1 "X" pos:[128,72] width:24 height:16

	spinner size_h "H" pos:[168,72] width:70 height:16 enabled:false range:[1,10000,4096] type:#integer

	GroupBox grp4 "Settings" pos:[16,152] width:232 height:368
	
	slider quality "Quality (Samples)" pos:[24,168] width:216 height:44 type:#integer ticks:1 range:[8,512,8]
	label qualVal "X" pos:[60,217]

	label lbl3 "Low" pos:[30,217] width:24 height:16


	label lbl4 "High" pos:[216,217] width:24 height:16


	slider spread "Distance (0 = infinity)" pos:[24,240] width:216 height:44 range:[0,100,0] type:#float ticks:5
	label spreadVal "X" pos:[60,288]
	label lbl5 "Low" pos:[28,288] width:24 height:16


	label lbl6 "High" pos:[216,288] width:24 height:16
	GroupBox grp5 "Colors" pos:[24,384] width:216 height:128
	colorPicker color_dark "Dark" pos:[32,400] width:200 height:32 color:(color 0 0 0)


	colorPicker color_light "Light" pos:[32,440] width:200 height:32 color:(color 255 255 255)

	edittext save_to_path "Save to: " pos:[16,528] width:192 height:16


	button save_to "..." pos:[216,528] width:32 height:16 toolTip:"Browse"


	checkbutton preview_occ_btn "P" pos:[16,552] width:24 height:24 toolTip:"Preview by applying to the mesh." images:#("armaToolBoxTextures.bmp", undefined, 3, 3, 3, 3, 3)


	button bake_occ_btn "B" pos:[224,552] width:24 height:24 enabled:false images:#("armaToolBox2.bmp", undefined, 10, 8, 8, 8, 8) toolTip:"Bake"

	spinner padding "Padding" pos:[128,104] width:96 height:16 range:[0,50,3] type:#integer


	label lbl17 "px" pos:[232,104] width:16 height:16

	GroupBox grp17 "Ambient Occlusion" pos:[8,136] width:248 height:448

	button preset_black "BW" pos:[176,480] width:24 height:24 images:#("armaToolBoxTextures.bmp", undefined, 3, 1, 1, 1, 1) toolTip:"Black/White"

	button preset_pink "PW" pos:[208,480] width:24 height:24 images:#("armaToolBoxTextures.bmp", undefined, 3, 2, 2, 2, 2) toolTip:"Pink/White"

	GroupBox grp18 "Diffuse Color" pos:[8,592] width:248 height:72
	checkbutton preview_diff_btn "P" pos:[16,632] width:24 height:24 toolTip:"Preview by applying to the mesh." images:#("armaToolBoxTextures.bmp", undefined, 3, 3, 3, 3, 3)

	button bake_diff_btn "B" pos:[224,632] width:24 height:24 images:#("armaToolBox2.bmp", undefined, 10, 8, 8, 8, 8) toolTip:"Bake" enabled:false

	slider density "Spread" pos:[25,312] width:216 height:44 range:[0,10,0.8] type:#float ticks:5
	label lbl7 "Low" pos:[29,360] width:24 height:16
	label lbl8 "High" pos:[217,360] width:24 height:16
	label denseVal "X" pos:[60,360]
	edittext save_to_path_diff "Save to: " pos:[16,608] width:192 height:16
	button save_to_diff "..." pos:[216,608] width:32 height:16 toolTip:"Browse"
	
	on quality changed val do
	(
		qualVal.text = val as string
		newpos = 60.0+(((val as float)-8.0)/504.0)*130.0
		qualVal.pos = [newpos,217]
	)
	on spread changed val do
	(
		spreadVal.text = val as string
		newpos = 60.0+(((val as float))/100.0)*120.0
		spreadVal.pos = [newpos,288]
	)
	on density changed val do
	(
		denseVal.text = val as string
		newpos = 60.0+(((val as float))/10.0)*130.0
		denseVal.pos = [newpos,360]
	)
	on textureRoll open do
	(
		size_1024.checked = true
	)
	on size_custom changed bool do
	(
		size_w.enabled = bool
		size_h.enabled = bool
		local occSizes = #(256,512,1024,2048)
		case bool of
		(
			true:
			(
				for i in occSizes do
				(
					execute ("textureRoll.size_"+(i as string)+".checked = false")
				)
				textureDimsX = size_w.value
				textureDimsY = size_h.value
			)
			false:
				false
		)
	)
	on size_256 changed bool do
	(
		size_w.enabled = false
		size_h.enabled = false
		local occSizes = #("custom",512,1024,2048)
		case bool of
		(
			true:
			(
				for i in occSizes do
				(
					execute ("textureRoll.size_"+(i as string)+".checked = false")
				)
				textureDimsX = 256
				textureDimsY = 256
			)
			false:
				false
		)
	)
	on size_512 changed bool do
	(
		size_w.enabled = false
		size_h.enabled = false
		local occSizes = #("custom",256,1024,2048)
		case bool of
		(
			true:
			(
				for i in occSizes do
				(
					execute ("textureRoll.size_"+(i as string)+".checked = false")
				)
				textureDimsX = 512
				textureDimsY = 512
			)
			false:
				false
		)
	)
	on size_1024 changed bool do
	(
		size_w.enabled = false
		size_h.enabled = false
		local occSizes = #("custom",512,256,2048)
		case bool of
		(
			true:
			(
				for i in occSizes do
				(
					execute ("textureRoll.size_"+(i as string)+".checked = false")
				)
				textureDimsX = 1024
				textureDimsY = 1024
			)
			false:
				false
		)
	)
	on size_2048 changed bool do
	(
		size_w.enabled = false
		size_h.enabled = false
		local occSizes = #("custom",512,1024,256)
		case bool of
		(
			true:
			(
				for i in occSizes do
				(
					execute ("textureRoll.size_"+(i as string)+".checked = false")
				)
				textureDimsX = 2048
				textureDimsY = 2048
			)
			false:
				false
		)
	)
	
	on size_w changed do
	(
		textureDimsX = size_w.value
	)
	on size_h changed do
	(
		textureDimsY = size_h.value
	)
	
	on save_to pressed do
	(
		if selection.count == 1 then
		(
			filePath = getSaveFileName  caption:"Save As..." filename:(selection[1].name+"_ao_"+(textureDimsX as string)+"x"+(textureDimsY as string)+".tga")
			if filePath != undefined do
			(
				save_to_path.text = filePath
				bake_occ_btn.enabled = true
			)
		) else (
			messageBox("Only one object at a time may be baked.")
		)
	)
	on save_to_diff pressed do
	(
		if selection.count == 1 then
		(
			filePath = getSaveFileName  caption:"Save As..." filename:(selection[1].name+"_diff_"+(textureDimsX as string)+"x"+(textureDimsY as string)+".tga")
			if filePath != undefined do
			(
				save_to_path_diff.text = filePath
				bake_diff_btn.enabled = true
			)
		) else (
			messageBox("Only one object at a time may be baked.")
		)
	)
	on bake_occ_btn pressed do
	(
		
		if selection.count == 1 and save_to_path.text != "" then
		(
			textureBaked = (BakeAmbient selection[1] textureDimsX textureDimsY save_to_path.text padding.value quality.value spread.value density.value color_dark.color color_light.color)
			if (textureBaked == true and preview_occ_btn.checked == true) do (PreviewMat selection[1] save_to_path.text)
		) else (
			messageBox("You have to select one object before trying to bake it.")
		)
	)
	on bake_diff_btn pressed do
	(
		
		if selection.count == 1 and save_to_path_diff.text != "" then
		(
			textureBaked = (BakeDiffuse selection[1] textureDimsX textureDimsY save_to_path_diff.text padding.value)
			if (textureBaked == true and preview_diff_btn.checked == true) do (PreviewMat selection[1] save_to_path_diff.text)
		) else (
			messageBox("You have to select one object before trying to bake it.")
		)
	)
	on preset_black pressed do
	(
		color_dark.color = (color 0 0 0)
		color_light.color = (color 255 255 255)
	)
	on preset_pink pressed do 
	(
		color_dark.color = (color 255 0 255)
		color_light.color = (color 255 255 255)
	)
)
