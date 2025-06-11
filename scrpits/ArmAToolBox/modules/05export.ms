/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: 05Export.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                                *
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
function cutPolies obj=
(
	irregPolies = #()
	for i = 1 to obj.numfaces do
	(
		faceVertArray = polyop.getFaceDeg obj i
		if faceVertArray > 4 do append irregPolies i
	)
	-- format "%" irregPolies
	if irregPolies.count > 0 do
	(
		faceVertArray1 = polyop.getFaceVerts obj irregPolies[1]
		polyop.createedge obj faceVertArray1[2] faceVertArray1[4]
		cutPolies obj
	)
)

rollout exportRoll "Export" width:264 height:128
(
	GroupBox grp1 "Pre-export" pos:[8,8] width:112 height:112

	button reset_xform_btn "Reset  X-Form" pos:[16,24] width:96 height:24 toolTip:"Rest X-Form of selection."

	
	button reset_piv "Reset  Pivots" pos:[16,56] width:96 height:24 toolTip:"Rest Pivots of selection."

	button collapse_obj "Collapse Objects" pos:[16,88] width:96 height:24 toolTip:"Turn the selection into Editable Polies."

	GroupBox grp2 "3ds Export" pos:[128,8] width:128 height:112

	button export_to "Export 3ds" pos:[136,24] width:112 height:88 toolTip:"Export selection to 3ds format."
	groupBox grp3 "p3d Export" pos:[8,128] width:248 height:64
	button p3d_export "Export p3d file. Must be only tris and quads." pos:[16,144] width:232 height:40
	
	on p3d_export pressed do
	(
		try (
			destroyDialog p3dExpRoll
		) catch ()
		function LODsaddChildren theNode theLayer = 
		(
			newNode = theNode.Nodes.add theLayer.name
			newNode.tag = dotNetMXSValue c
		)

		function LODsfillInNodesTreeView tv =
		(
			tv.nodes.clear()	
			theRoot = tv.Nodes.add "LOD"
			--theRoot.Checked = true
			for i = 0 to LayerManager.count-1 do 
			(
				currLayer = LayerManager.getLayer i
				LODsaddChildren theRoot currLayer 
			)
		)

		function LODsOutlinerRefresh tv =
		(
			try (tvops.initTreeView tv pLabelEdit:false  pCheckBoxes:false pFullRowSel:false pAllowDrop:false pScrollable:true  pShowLines:true)catch("Init Error")
			try 
			(	
				LODsfillInNodesTreeView tv
				tv.ExpandAll()
			)catch("Fill Error")
		)
		
		global listOfLods = #( \
			#("Resolution",0),\
			#("View Gunner",1.0e3),\
			#("View Pilot",1.1e3),\
			#("View Cargo",1.2e3),\
			#("Shadow Volume 0",1.0e4),\
			#("Shadow Volume 10",1.001e4),\
			#("Geometry",1.0e13),\
			#("Memory",1.0e15),\
			#("Land Contact",2.0e15),\
			#("Roadway",3.0e15),\
			#("Paths",4.0e15),\
			#("HitPoints",5.0e15),\
			#("View Geometry",6.0e15),\
			#("Fire Geometry",7.0e15),\
			#("View Cargo Geometry",8.0e15),\
			#("View Cargo Fire Geometry",9.0e15),\
			#("View Commander",1.0e16),\
			#("View Commander Geometry",1.1e16),\
			#("View Commander Fire Geometry",1.2e16),\
			#("View Pilot Geometry",1.3e16),\
			#("View Pilot Fire Geometry",1.4e16),\
			#("View Gunner Geometry",1.5e16),\
			#("View Gunner Fire Geometry",1.6e16))
			
			
		rollout p3dExpRoll "Save p3d Options" width:584 height:488
		(
			checkbox exportChoice "Export selected objects only" pos:[368,461] width:160 height:15
			GroupBox grp2 "LOD Options" pos:[8,48] width:568 height:352
			dotNetControl tv "TreeView" pos:[16,64] width:152 height:296
			label lbl1 "==>" pos:[176,200] width:24 height:16
			button doAuto "Try to automaticaly determine." pos:[176,250]
			label lbl2 "First select one of the LODs from the list. Then choose the corresponding O2 LOD. Click add button to add the layer to the list of exportable LODs." pos:[16,368] width:552 height:32
			dropdownList lodList "Corresponding LOD" pos:[208,177] width:152 height:40
			GroupBox grp3 "Exportable LODs" pos:[368,64] width:200 height:264
			button addLOD "+" pos:[504,336] width:24 height:24 toolTip:"Add" images:#(((getDir #scripts) + "\\ArmAToolBox\\armaToolBoxSnsTools.bmp"), undefined, 4, 3, 3, 3, 3)
			dotNetControl lv "ListView" pos:[376,80] width:184 height:240
			GroupBox grp4 "Other Options" pos:[8,408] width:568 height:40
			checkbox saveTexture "Save Textures" pos:[16,424] width:112 height:16 enabled:true
			checkbox saveMaterial "Save Materials" pos:[136,424] width:112 height:16 enabled:true
			spinner res "Resolution" pos:[215,224] width:144 height:16
			button exportReady "E" pos:[552,456] width:24 height:24 toolTip:"Export" images:#(((getDir #scripts) + "\\ArmAToolBox\\armaToolBoxSnsTools.bmp"), undefined, 4, 1, 1, 1, 1)
			button deleteLOD "-" pos:[536,336] width:24 height:24 toolTip:"Delete Selected LODs" images:#(((getDir #scripts) + "\\ArmAToolBox\\armaToolBox2.bmp"), undefined, 10, 9, 9, 9, 9)
			label lbl3 "Arma3 p3d Exporter for 3dsmax" pos:[194,8] width:160 height:16
			label lbl4 "by Soul_Assassin" pos:[224,24] width:160 height:16
			
			on doAuto pressed do
			(
				nodeTree = tv.Nodes.Item[0].Nodes
				for i = 0 to (nodeTree.count-1) do
				(
					compString = nodeTree.Item[i].text
					if (compString as float) != undefined then
					(
						lvops.AddLvItem lv pTextItems:#(compString,((compString as float) as string)) pChecked:false pTag:undefined  pToolTip:"" pInsertAt: undefined
					) else (
						match = false
						for i in listOfLods do
						(
							if compString == i[1] do
							(
								lvops.AddLvItem lv pTextItems:#(compString,(i[2] as string)) pChecked:false pTag:undefined  pToolTip:"" pInsertAt: undefined
							)
						)
					)
				)
			)
			
			on exportChoice changed state do
			(
				tv.enabled = not state
				lodList.enabled = not state
				addLOD.enabled = not state
				lv.enabled = not state
				deleteLOD.enabled = not state
				res.enabled = not state
			)
			on p3dExpRoll open do
			(
				listOfLodNames = #()
				for i = 1 to listOfLods.count do
				(
					append listOfLodNames listOfLods[i][1]
				)
				lodList.items = listOfLodNames
				LODsOutlinerRefresh tv
				lvops.InitListView lv pLabelEdit: false pAllowReorder: false pCheckBoxes: true pFullRowSel: true pMultiSel: true pGridLines: true pHideHeaders: false pAllowDrop: false pInitColumns:  #("Layer","LOD Res")  pInitColWidths:#(120,60)
			)
			on addLOD pressed do
			(
				textCheck = "LOD"
				try (textCheck = tv.SelectedNode.text) catch ()
				if textCheck != "LOD" and tv.SelectedNode != undefined do
				(
					if lodlist.selection == 1 then
					(
						lvops.AddLvItem lv pTextItems:#(tv.SelectedNode.text,(res.value as string)) pChecked:false pTag:undefined  pToolTip:"" pInsertAt: undefined
					)else(
						lvops.AddLvItem lv pTextItems:#(tv.SelectedNode.text,(listOfLods[lodlist.selection][2] as string)) pChecked:false pTag:undefined  pToolTip:"" pInsertAt: undefined
					)
				)
			)
			on exportReady pressed do
			(
				exportFilePath = getsavefilename caption:"Save p3d File" filename:"untitled.p3d" types:"P3D Model (*.p3d)|*.p3d"
				if exportFilePath != undefined do
				(
					LodResList = #()
					for i = 0 to (lvops.GetLvItemCount lv)-1 do
					(
						append LodResList #(((lvops.GetLvItemName lv i 0) as string),((lvops.GetLvItemName lv i 1) as float))
					)
					fs = fopen exportFilePath "wb"
					newExport = p3dStruct file:fs noOfLods:lodsArray selected:exportChoice.state noOfLods:LodResList saveTex:saveTexture.state saveMat:saveMaterial.state savePath:exportFilePath
					--try(
						newExport.writeFile()
					--) catch ( messagebox "You have unexportable objects selected. Try Again. \t")
				)
			)
			on deleteLOD pressed do
			(
				local count = lvops.GetLvItemCount lv
				local i = 0
				while (i < (count)) do
				(
					if (lvops.GetLvItemCheck lv i) == true then 
					(
						lvops.DeleteLvItem lv i
						i = 0
						count = lvops.GetLvItemCount lv
					) else (
						i+=1
						count = lvops.GetLvItemCount lv
					)
				)
			)
		)
		createDialog p3dExpRoll
		
	)
	
	on reset_xform_btn pressed do
	(
		for obj in selection where SuperClassOf obj == GeometryClass do
		(
			ResetXForm obj
		)
	)
	
	on reset_piv pressed do
	(
		for obj in selection where SuperClassOf obj == GeometryClass do
		(
			ResetPivot obj
			CenterPivot obj
			WorldAlignPivot obj
		)
	)
	
	on collapse_obj pressed do
	(
		for obj in selection where SuperClassOf obj == GeometryClass do
		(
			convertToPoly(obj)
		)
	)
	
	on export_to pressed do
	(
		if selection.count != 0 then
		(
			exportFilePath = getsavefilename caption:"Save 3ds File" filename:"untitled.3ds" types:"3DS Model (*.3ds)|*.3ds"
			if exportFilePath != undefined do
			(
				exportFile exportFilePath selectedOnly:true
			)
		)else(
			messageBox("Select the objects you want to export")
		)
	)
	
)
