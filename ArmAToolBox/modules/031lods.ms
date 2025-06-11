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
lodNameList = #()
for i in listOfLods do
(
	append lodNameList i[1]
)
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

function hideLODs nonHide= 
(
	for i = 0 to layerManager.count-1 do
	(
		ilayer = layerManager.getLayer i
		ilayer.ishidden = true
		ilayer.isfrozen = true
		
	)
	
	nonHide.ishidden = false
	nonHide.isfrozen = false
	nonHide.current = true
)

function refreshCurrLayer textCont=
(
	layer = LayerManager.current
	layerName = layer.name
	textCont.text = "Current LOD: "+layerName
)

function removeLayer layername tv textCont=
(
	if LayerManager.current == (LayerManager.getLayerfromname layername) do
	(
		hideLODs (LayerManager.getLayerfromname "0")
		refreshCurrLayer textCont
	)
	lodA = LayerManager.getLayerfromname layername
	lodA.nodes &theNodesA
	for ANode in theNodesA do
	(
		delete ANode
	)
	LayerManager.deleteLayerByName layername
)
rollout lodRoll "LODs" width:264 height:296
(
	label currLOD "Current LOD: " pos:[8,8] height:16 width:248
	dotNetControl lodtree "TreeView" pos:[8,32] width:248 height:224
	button addLOD "A" pos:[8,264] width:24 height:24 toolTip:"Add a new LOD." images:#("armaToolBoxSnsTools.bmp", undefined, 4, 3, 3, 3, 3)
	button editLOD "E" pos:[40,264] width:24 height:24 toolTip:"Edit selected LOD properties." images:#("armaToolBoxLods.bmp", undefined, 2, 1, 1, 1, 1)
	button dupeLOD "D" pos:[72,264] width:24 height:24 toolTip:"Duplicate selected LOD." images:#("armaToolBoxLods.bmp", undefined, 2, 2, 2, 2, 2)
	button removeLOD "R" pos:[104,264] width:24 height:24 toolTip:"Remove selected LOD." images:#("armaToolBox2.bmp", undefined, 10, 9, 9, 9, 9)
	button refreshLOD "Re" pos:[232,264] width:24 height:24 toolTip:"Refresh the current LOD tree." images:#("armaToolBox2.bmp", undefined, 10, 10, 10, 10, 10)
	
	on lodRoll open do
	(
		refreshCurrLayer currLOD
		LODsOutlinerRefresh lodtree
	)
	
	on removeLOD pressed do
	(
		query = querybox("Are you sure you want to delete the selected LOD? \t")
		if query == true do 
		(
			removeLayer lodtree.SelectedNode.text lodtree currLOD
			LODsOutlinerRefresh lodtree
		)
	)
	
	on lodtree NodeMouseDoubleClick arg do
	(
		try(
			layer = layerManager.getlayerfromname lodtree.SelectedNode.text
			hideLODs layer
			refreshCurrLayer currLOD
		) catch ()
	)
	
	on dupeLOD pressed do
	(
		try
		(
			destroyDialog dupeLODroll
		)catch()
		if lodtree.SelectedNode != undefined do
		(
			global lodA = lodtree.SelectedNode
			rollout dupeLODroll "Edit LOD" width:312 height:64
			(
				edittext lodName "LOD Name : " pos:[8,8] width:296 height:16
				button dupeLODa "A" pos:[248,32] width:24 height:24 images:#("C:\Program Files\Autodesk\3ds Max 2010\scripts\ArmAToolBox\armaToolBox2.bmp", undefined, 10, 8, 8, 8, 8) toolTip:"Confirm."
				button exitDupeLOD "D" pos:[280,32] width:24 height:24 images:#("C:\Program Files\Autodesk\3ds Max 2010\scripts\ArmAToolBox\armaToolBox2.bmp", undefined, 10, 9, 9, 9, 9) toolTip:"Cancel."
				dropDownList presetsList "" pos:[67,32] width:120 height:21 items:lodNameList
				label lbl1 "Presets" pos:[8,36] width:56 height:16
				
				on presetsList selected val do
				(
					lodName.text = presetsList.items[val]
				)
				
				on dupeLODroll open do
				(
					lodName.text = lodA.text
				)
				on dupeLODa pressed do
				(
					if lodName.text != undefined and lodName.text != "" then
					(
						lodA = LayerManager.getLayerfromname lodA.text
						lodB = LayerManager.newLayer()
						lodNaming = false
						try (
							lodNaming = lodB.setName lodName.text
						) catch ()
						if lodNaming == true then
						(
							lodA.nodes &theNodesA
							for ANode in theNodesA do
							(
								BNode = copy ANode
								BNode.name = ANode.name
								lodB.addNode BNode
							)
							hideLODs lodB
							
							LODsOutlinerRefresh lodRoll.lodtree
							refreshCurrLayer currLOD							
							destroyDialog dupeLODroll
						)							
						else (
							messageBox("The LOD should have a unique name. \t ")
						)
					)else(
						messageBox("A LOD should have a name. \t ")
					)
				)
				on exitDupeLOD pressed do
				(
					destroyDialog dupeLODroll
				)
			)
			createdialog dupeLODroll
		)
		
	)
	
	on addLOD pressed do
	(
		try
		(
			destroyDialog newLODroll
		)catch()
		rollout newLODroll "Add New LOD" width:312 height:64
		(
			editText lodName "LOD Name : " pos:[8,8] width:296 height:16
			button addLODa "A" pos:[248,32] width:24 height:24 toolTip:"Confirm." images:#(((getDir #scripts) + "\\ArmAToolBox\\armaToolBox2.bmp"), undefined, 10, 8, 8, 8, 8)
			button exitAddLOD "D" pos:[280,32] width:24 height:24 toolTip:"Cancel." images:#(((getDir #scripts) + "\\ArmAToolBox\\armaToolBox2.bmp"), undefined, 10, 9, 9, 9, 9)
			dropDownList presetsList "" pos:[67,32] width:120 height:21 items:lodNameList
			label lbl1 "Presets" pos:[8,36] width:56 height:16
			
			on presetsList selected val do
			(
				lodName.text = presetsList.items[val]
			)
			
			on addLODa pressed do
			(
				if lodName.text != undefined and lodName.text != "" then
				(
					newLOD = LayerManager.newLayer()
					lodNaming = newLOD.setName lodName.text
					if lodNaming == true then
					(
						LODsOutlinerRefresh lodRoll.lodtree
						destroyDialog newLODroll
					)
					else (
						LayerManager.deleteLayerByName newLOD.name
						messageBox("The LOD should have a unique name. \t ")
					)
				)else(
					messageBox("A new LOD should have a name. \t ")
				)
			)
			
			on exitAddLOD pressed do
			(
				destroyDialog newLODroll
			)
		)
		createdialog newLODroll
	)
	on editLOD pressed do
	(
		try
		(
			destroyDialog editLODroll
		)catch()
		if lodtree.SelectedNode != undefined do
		(
			global existingLod = lodtree.SelectedNode
			rollout editLODroll "Edit LOD" width:312 height:64
			(
				editText lodName "LOD Name : " pos:[8,8] width:296 height:16
				button editLODa "A" pos:[248,32] width:24 height:24 toolTip:"Confirm." images:#(((getDir #scripts) + "\\ArmAToolBox\\armaToolBox2.bmp"), undefined, 10, 8, 8, 8, 8)
				button exitEditLOD "D" pos:[280,32] width:24 height:24 toolTip:"Cancel." images:#(((getDir #scripts) + "\\ArmAToolBox\\armaToolBox2.bmp"), undefined, 10, 9, 9, 9, 9)
				dropDownList presetsList "" pos:[67,32] width:120 height:21 items:lodNameList
				label lbl1 "Presets" pos:[8,36] width:56 height:16
				
				on presetsList selected val do
				(
					lodName.text = presetsList.items[val]
				)
				
				on editLODroll open do
				(
					lodName.text = existingLod.text
				)
				
				on editLODa pressed do
				(
					if lodName.text != undefined and lodName.text != "" then
					(
						newLOD = LayerManager.getLayerFromName existingLod.text
						lodNaming = false
						try (
							lodNaming = newLOD.setName lodName.text
						) catch ()
						if lodNaming == true then
						(
							LODsOutlinerRefresh lodRoll.lodtree
							refreshCurrLayer currLOD
							destroyDialog editLODroll
						)							
						else (
							messageBox("The LOD should have a unique name. \t ")
						)
					)else(
						messageBox("A LOD should have a name. \t ")
					)
				)
				
				on exitEditLOD pressed do
				(
					destroyDialog editLODroll
				)
			)
			createdialog editLODroll
		)
		
	)
	
	on refreshLOD pressed do
	(
		LODsOutlinerRefresh lodtree
	)
	
)
