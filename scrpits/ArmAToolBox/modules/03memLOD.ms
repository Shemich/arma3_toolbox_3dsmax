/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: 03Memory.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                                *
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
function MemoryRefresh tv =
(
	failedFill = false
	try (tvops.initTreeView tv pLabelEdit:false  pCheckBoxes:false pFullRowSel:false pAllowDrop:false pScrollable:true  pShowLines:true)catch(messageBox "Init Error")
	try (	
			tv.nodes.clear()	
			theRoot = tv.Nodes.add "Memory Points"
			if (layermanager.getlayerfromname "Memory") != undefined do
			(
				memLayer = layermanager.getlayerfromname "Memory"
				memLayer.nodes &theNodes
				for i in theNodes do
				(
					newNode = theRoot.Nodes.add i.name
					newNode.tag = dotNetMXSValue c
				)
			)
			tv.ExpandAll()
	)catch(failedFill = true)
	
)

fn getMemNodes tv=
(
	tv.nodes.clear()	
	theRoot = tv.Nodes.add "Memory Points"
	if (layermanager.getlayerfromname "Memory") != undefined do
	(
		memLayer = layermanager.getlayerfromname "Memory"
		memLayer.nodes &theNodes
		for i in theNodes do
		(
			newNode = theRoot.Nodes.add i.name
			newNode.tag = dotNetMXSValue c
		)
	)
)

rollout MemoryRoll "Memory LOD" width:264 height:552
(
	groupBox grp7 "Tools" pos:[8,8] width:248 height:48
	groupBox grp8 "View" pos:[8,64] width:248 height:72
	button add_point "A" pos:[16,24] width:24 height:24 toolTip:"Add Point" images:#("armaToolBoxMem.bmp", undefined, 4, 1, 1, 1, 1)
	
	button add_axis "X" pos:[48,24] width:24 height:24 toolTip:"Use two points to define an axis." images:#("armaToolBoxMem.bmp", undefined, 4, 2, 2, 2, 2)
	groupBox grp9 "Points" pos:[16,80] width:72 height:48
	groupBox grp10 "Geometry" pos:[96,80] width:72 height:48
	checkButton freeze_m "F" pos:[24,96] width:24 height:24 highlightColor:(color 255 0 0) toolTip:"Freeze all memory points." images:#("armaToolBoxMem.bmp", undefined, 4, 3, 3, 3, 3)
	checkButton hide_m "H" pos:[56,96] width:24 height:24 highlightColor:(color 255 0 0) toolTip:"Hide all memory points." images:#("armaToolBoxMem.bmp", undefined, 4, 4, 4, 4, 4)
	checkButton freeze_g "F" pos:[104,96] width:24 height:24 highlightColor:(color 255 0 0) toolTip:"Freeze all geometry." images:#("armaToolBoxMem.bmp", undefined, 4, 3, 3, 3, 3)
	checkButton hide_g "H" pos:[136,96] width:24 height:24 highlightColor:(color 255 0 0) toolTip:"Hide all geometry." images:#("armaToolBoxMem.bmp", undefined, 4, 4, 4, 4, 4)
	groupBox grp11 "Points" pos:[8,144] width:248 height:400
	dotNetControl memtv "TreeView" pos:[16,160] width:232 height:344
	button refresh_tv "R" pos:[16,512] width:24 height:24 toolTip:"Refresh list." images:#("armaToolBox2.bmp", undefined, 10, 10, 10, 10, 10)
	button export_mem "E" pos:[224,512] width:24 height:24 toolTip:"Export Memory LOD." images:#("armaToolBoxSnsTools.bmp", undefined, 4, 1, 1, 1, 1)
	
	on add_axis pressed do
	(
		try (destroyDialog axisRoll)catch()
		
		rollout axisRoll "2-Point Axis" width:160 height:208
		(
			fn point_filt obj = classof obj == point
			fn geo_filt obj = superclassof obj == GeometryClass
				
			fn assignAxis points1 points2 part=
			(
				Tape_align=tape pos:(points1.pos) target:(targetobject pos:(points2.pos))
					
				animate off in coordsys local 

				select part
			
				ResetXForm part
				ResetTransform part
				ResetScale part 
				ResetPivot part

				part.pivot=Tape_align.pos   
				model_source_pos=part.pos
				pivot_rotate_angle= inverse (Tape_align.transform.rotation)
				part.rotation *= pivot_rotate_angle
				part.objectoffsetrot *= pivot_rotate_angle
				part.objectoffsetpos *= pivot_rotate_angle
				part.pos=model_source_pos
				part.pivot=(points1.pos+points2.pos)/2
				
				delete Tape_align
				points1.name = points2.name = (part.name+"_axis")
				convertToPoly(part)
			)
			
			groupBox grp1 "Axis" pos:[8,8] width:144 height:96
			pickButton pickPoint1 "Point 1" pos:[16,24] width:128 height:32 toolTip:"Pick the first point." filter:point_filt
			pickButton pickPoint2 "Point 2" pos:[16,64] width:128 height:32 toolTip:"Pick the second point." filter:point_filt
			groupBox aw "Part" pos:[8,112] width:144 height:56
			pickButton pickPart "Part" pos:[16,128] width:128 height:32 toolTip:"Pick the object." filter:geo_filt
			button assign "Apply" pos:[129,176] width:24 height:24 toolTip:"Assign the axis to the part." images:#(((getDir #scripts) + "\\ArmAToolBox\\armaToolBox2.bmp"), undefined, 10, 8, 8, 8, 8)
			
			on assign pressed do
			(
				if (pickPoint1.object != undefined and pickPoint2.object != undefined and pickPart.object != undefined) then
				(
					assignAxis pickPoint1.object pickPoint2.object pickPart.object
				) else (
					messageBox("Some selections are missing.")
				)
			)
			
			on pickPoint1 picked obj do
			(
				if obj != undefined do
					pickPoint1.text = obj.name
			)
			on pickPoint2 picked obj do
			(
				if obj != undefined do
					pickPoint2.text = obj.name
			)
			on pickPart picked obj do
			(
				if obj != undefined do
					pickPart.text = obj.name
			)
		)
		createDialog axisRoll

	)
	
	on MemoryRoll open do
	(
		if (layermanager.getlayerfromname "Memory") == undefined do (layermanager.newLayerFromName "Memory")
		MemoryRefresh memtv
	)
	
	on export_mem pressed do
	(
		if (layermanager.getlayerfromname "Memory") != undefined then
		(
			local fileName = getSaveFileName caption:"Save Memory Location File" filename:"untitled.mlf" types:"Memory Location File (*.mlf)|*.mlf"
			if fileName != undefined then
			(
				memLayer = layermanager.getlayerfromname "Memory"
				memLayer.nodes &theNodes
				fs = createFile fileName
				num = 1
				for i in theNodes do
				(
					if num == theNodes.count then
					(
						format "% : %,%,%" i.name i.pos.x i.pos.y i.pos.z to:fs
					) else (
						format "% : %,%,%\n" i.name i.pos.x i.pos.y i.pos.z to:fs
						num+=1
					)
				)
				close fs
			) else (
				false
			)
		) else (
			messageBox("No memory LOD layer present in scene.")
		)
	)
	
	on refresh_tv pressed do
	(
		MemoryRefresh memtv
	)
	
	on freeze_g changed bool do
	(
		for geo in $* where SuperclassOf geo == GeometryClass do
		(
			geo.isFrozen = bool
			geo.xray = bool
			for i in $* where classOf i == point do
			(
				i.drawontop= bool
			)
		)
	)
	on hide_g changed bool do
	(
		for geo in $* where SuperclassOf geo == GeometryClass do
		(
			geo.isHidden = bool
			
		)
	)
	on freeze_m changed bool do
	(
		for geo in $* where classOf geo == point do
		(
			geo.isFrozen = bool
		)
	)
	on hide_m changed bool do
	(
		for geo in $* where classOf geo == point do
		(
			geo.isHidden= bool
		)
	)
	
	on memtv NodeMouseDoubleClick arg do
	(
		try(
			execute ("select (for obj in objects where obj.name == \""+memtv.SelectedNode.text+"\" collect obj)")
		) catch ()
	)
	
	tool createMemPoint
	(
		on mousePoint clickno do
		(
			if (layermanager.getlayerfromname "Memory") == undefined do (layermanager.newLayerFromName "Memory")
			memLayer = layermanager.getlayerfromname "Memory"
			if clickno > 1 do
			(
				newpoint = point pos:worldPoint size:10 centermarker:true constantscreensize:true cross:false wirecolor:(color 255 0 0) name:(uniqueName "memPoint")
				completeRedraw()
			)
			memLayer.addnode newpoint
			MemoryRefresh memtv
		)
	)
	
	on add_point pressed do
	(
		startTool createMemPoint
	)
)
