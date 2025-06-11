/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: cfgTools.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                                *
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

global skelClassNum = 1
global modelClassNum = 1
global preSkels = #()
global preModels = #()
global preAnims = #()

filein ((getDir #scripts) + "\\ArmAToolBox\\functions\\NET_TextBoxWrapper.ms")

RCMenu cfgToolsMenu
(
	subMenu "File"
	(
		MenuItem	OpenFileF	"Open File..."		-- saves custom format (schematic data)
		
		MenuItem	resetF	"Reset"
		separator serp1
		MenuItem	exitF "Close"
	)
	fn findClassNum type file=
	(
		classNum = 0
		for i=1 to 99 do
		(
			seek file 0
			lookString = "//"+type+"Class"+(i as string)
			found = skipToString file lookString
			if found != undefined do
			(
				classNum = i
			)
		)
		--print (classNum as string)
		return classNum
	)
	fn buildClassArray type file=
	(
		classArray = #()
		seek file 0
		lookString = "/*"+type+"Classes"
		lookEndString = "End"+type+"Classes*/"
		found = skipToString file lookString
		if found != undefined do
		(
			skipToNextLine file
			while (newString = readline file) != lookEndString do
			(
				append classArray newString
			)
			
		)
		for i in classArray do print i
		return classArray
	)
	on OpenFileF picked do
	(
		skelFile = getopenfilename caption:"Open Model.cfg" types:"CFG (*.cfg)|*.cfg|"
		if skelFile != undefined do
		(
			openSkelFile = openFile skelFile
			seek openSkelFile 0
			line1 = readline openSkelFile
			if line1 != "//0x753d947a" then
			(
				openQuery = querybox("This model.cfg file was not generated with the toolbox and will not function properly if you try to edit it here. Do you want to open it anyway?")
				case openQuery of
				(
					true:
					(
						seek openSkelFile #eof
						maxlen=filepos openSkelFile
						seek openSkelFile 0
						res = readChars openSkelFile maxlen errorAtEOF:false
						tbops.initTextBox cfgToolRollout.preview_box 
						cfgToolRollout.preview_box.text = res as string
						close openSkelFile
						#stop
					)
					false:
						#stop
				)
			)else(
				skelClassNum = (findClassNum "skel" openSkelFile)
				modelClassNum = (findClassNum "model" openSkelFile)
				
				preSkels = buildClassArray "Skeleton" openSkelFile
				cfgToolRollout.skel_class_inherit.items = #("none")
				cfgToolRollout.skel_class_inherit.items = join cfgToolRollout.skel_class_inherit.items preSkels
				cfgToolRollout.skel_bones_inherit.items = #("none")
				cfgToolRollout.skel_bones_inherit.items = join cfgToolRollout.skel_bones_inherit.items preSkels
				cfgToolRollout.model_skel.items = #()
				cfgToolRollout.model_skel.items = join cfgToolRollout.model_skel.items preSkels
				
				preModels = buildClassArray "Model" openSkelFile
				cfgToolRollout.model_class_inherit.items = #("Default")
				cfgToolRollout.model_class_inherit.items = join cfgToolRollout.model_class_inherit.items preModels
				cfgToolRollout.anim_class.items = #()
				cfgToolRollout.anim_class.items = join cfgToolRollout.anim_class.items preModels
				
				preAnims = buildClassArray "Animation" openSkelFile
				cfgToolRollout.anim_class_inherit.items = #("none")
				cfgToolRollout.anim_class_inherit.items = join cfgToolRollout.anim_class_inherit.items preAnims
				
				if skelClassNum == 0 or modelClassNum == 0 do messageBox("This file does not contain the proper formatting and thus you will not be able to edit it. \t")
				seek openSkelFile #eof
				maxlen=filepos openSkelFile
				seek openSkelFile 0
				res = readChars openSkelFile maxlen errorAtEOF:false
				tbops.initTextBox cfgToolRollout.preview_box 
				cfgToolRollout.preview_box.text = res as string
				close openSkelFile
			)
		)
	)
	on resetF picked do
	(
		global skelClassNum = 1
		global modelClassNum = 1
		global preSkels = #()
		global preModels = #()
		global preAnims = #()
		skelFile = (getDir #scripts) + "\\ArmAToolBox\\modules\\cfgSets\\cfgSkeletonTemp.tmp"
		openSkelFile = openFile skelFile
		seek openSkelFile #eof
		maxlen=filepos openSkelFile
		seek openSkelFile 0
		res = readChars openSkelFile maxlen errorAtEOF:false
		tbops.initTextBox cfgToolRollout.preview_box 
		cfgToolRollout.preview_box.text = res as string
		close OpenSkelFile
	)
	
	on exitF picked do
	(
		
		destroyDialog cfgToolRollout
	)
)

try 
(
	if cfgToolRollout != undefined do 
	(
		destroyDialog cfgToolRollout
	)
	
) catch ()

fn addMemPoints tv show=
(
	if show == true then
	(
		theRoot = tv.Nodes.add "Virtual Memory Points"
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
	)else(
		try(
			tv.Nodes.Item[1].Remove()
		)catch()
	)
)

fn updateClassList type nameClass file=
(
	try(
		file = substitutestring file ("/*"+type+"Classes") ("/*"+type+"Classes\n"+nameClass)
	)catch()
	return file
)

fn removeNode tv=
(
	tv.SelectedNode.Remove()
)

fn skelStringGen theNode=
(
	local skelString = ""
	if theNode.level == 1 then
	(
		append skelString ("\n\t\t\t\""+(theNode.Tag.value.name as string)+"\",\"\",")
	) else (
		append skelString ("\n\t\t\t\""+(theNode.Tag.value.name as string)+"\",\""+(theNode.parent.Tag.value.name as string)+"\",")
	)
	if theNode.Nodes.Count != 0 then
	(
		for i =0 to (theNode.Nodes.Count-1) do
			append skelString (skelStringGen theNode.Nodes.Item[i])
	)
	return skelString
)

fn skelBoneTree tv=
(
	boneTree = ""
	try(
		for i =0 to (tv.Nodes.Item[0].Nodes.Count-1) do
		(
			append boneTree (skelStringGen tv.Nodes.Item[0].Nodes.Item[i])
		)
	)catch()
	return boneTree
)

fn buildSkelClass inher tv=
(
	classString = ""
	append classString "\n\t\tisDiscrete=1;"
	if (inher != "none") then
	(
		append classString ("\n\t\tskeletonInherit = \""+inher+"\";")
	) else (
		append classString "\n\t\tskeletonInherit = \"\";"
	)
	append classString ("\n\t\tskeletonBones[]=\n\t\t{\n"+(skelBoneTree tv)+"\n\t\t};")
	return classString
)

fn buildModelClass inher classInher skel nameClass animInher=
(
	classString = ""
	if (inher == true) then
	(
		append classString ("\n\t\tsectionsInherit = \""+classInher+"\";")
	) else (
		append classString "\n\t\tsectionsInherit = \"\";"
	)
	append classString "\n\t\tsections[] = \n\t\t{\n\t\t\t//section\n\t\t};"
	append classString ("\n\t\tskeletonName = \""+skel+"\";")
	append classString "\n\t\tclass Animations"
	if animInher == true do (append classString " : Animations")
	append classString ("\n\t\t{\n\t\t\t//anims"+nameClass+"\n\t\t};")
)

fn buildAnimClass cName inher type source mem lv=
(
	classString = "class "+cName
	if inher != "none" do
		append classString (" : "+inher)
	append classString "\n\t\t\t{"
	append classString ("\n\t\t\t\ttype = \""+type+"\";")
	append classString ("\n\t\t\t\tsource = \""+source+"\";")
	append classString ("\n\t\t\t\tmemory = \""+(mem as string)+"\";")
	propArray = lvops.GetLvItems lv
	if propArray.count != 0 do
	(
		for i = 1 to (propArray.count) do
		(
			append classString ("\n\t\t\t\t"+propArray[i].subitems.item[0].name+" = \""+propArray[i].subitems.item[1].name+"\";")
		)
	)
	append classString "\n\t\t\t};"
	return classString
)	



rollout cfgToolRollout "Model.cfg Generator" width:1208 height:712
(
	------- CfgSkeletons
	groupBox grp54 "cfgSkeletons" pos:[8,0] width:328 height:704
	-- add skeleton external class 
	
	GroupBox grp2 "Add External Class References" pos:[14,15] width:312 height:64
	edittext skel_class_ref "Class:" pos:[22,51] width:266 height:16
	button add_skel_class_ref "A" pos:[296,48] width:24 height:24 toolTip:"Add External Class Reference" images:#("armaToolBox2.bmp", undefined, 10, 8, 8, 8, 8)
	
	-- add skeleton class
	
	GroupBox grp3 "General" pos:[14,87] width:312 height:608
	label lbl2 "Model Name" pos:[22,103] width:88 height:16
	edittext skel_model_name "" pos:[19,123] width:133 height:20
	label semicol ":" pos:[155,127] width:8 height:16
	dropdownList skel_class_inherit "Class Inherit" pos:[166,104] width:112 height:40 items:#("none")
	dropdownList skel_bones_inherit "Skeleton Inherit" pos:[22,157] width:133 height:40 items:#("none")
	
	-- bones hierarchy
	
	dotNetControl skel_bones "TreeView" pos:[22,207] width:296 height:416
	button skel_bones_populate "P" pos:[54,631] width:24 height:24 toolTip:"Populate Hierarchy" images:#("armaToolBox2.bmp", undefined, 10, 10, 10, 10, 10)
	button skel_bones_delete "D" pos:[86,631] width:24 height:24 toolTip:"Remove Selected Node From Hierarchy" images:#("armaToolBox2.bmp", undefined, 10, 9, 9, 9, 9)
	button skel_bones_clear "X" pos:[294,631] width:24 height:24 toolTip:"Clear Hierarchy" images:#("armaToolBox2.bmp", undefined, 10, 9, 9, 9, 9)
	button add_skel_class "A" pos:[294,663] width:24 height:24 toolTip:"Add The Class" images:#("armaToolBox2.bmp", undefined, 10, 8, 8, 8, 8)
	checkbutton disp_mem "D" pos:[22,631] width:24 height:24 toolTip:"Display Memory Points" images:#("armaToolBoxMem.bmp", undefined, 4, 1, 1, 1, 1)
	
	----CfgModels
	groupBox grp5 "cfgModels" pos:[344,1] width:416 height:623
	-- add models reference class
	
	GroupBox grp6 "Add External Class References" pos:[352,16] width:400 height:64
	edittext model_class_ref "Class:" pos:[360,52] width:352 height:16
	button add_model_class_ref "A" pos:[720,48] width:24 height:24 toolTip:"Add External Class Reference" images:#("armaToolBox2.bmp", undefined, 10, 8, 8, 8, 8)
	
	-- add model class
	
	groupBox grp7 "Class" pos:[352,88] width:400 height:120
	label lbl4 "Model Name" pos:[365,105] width:88 height:16
	edittext model_name "" pos:[360,124] width:133 height:20
	label lbl3 ":" pos:[498,128] width:8 height:16
	dropdownList model_class_inherit "Class Inherit" pos:[509,105] width:112 height:40 items:#("Default")
	checkbox model_sec_inher "Section Inherit" pos:[630,125]
	dropdownList model_skel "Skeleton" pos:[366,152] width:133 height:40 items:#()
	checkbox anim_inher "Inherit Animations" pos:[520,172]
	button add_model_class "A" pos:[720,176] width:24 height:24 toolTip:"Add Class" images:#("armaToolBox2.bmp", undefined, 10, 8, 8, 8, 8)
	
	-- add anim class
	
	groupBox grp8 "Animation" pos:[352,216] width:400 height:400
	dropdownList anim_class "Class" pos:[360,232] width:133 height:40
	dropdownList anim_class_inherit "Inherit" pos:[498,232] width:133 height:40 items:#("none")
	
	editText anim_name "Name   " pos:[360,280] width:384 height:16
	label lbl5 "Type" pos:[360,307] width:32 height:16
	dropDownList anim_type "" pos:[400,304] width:144 height:21 items:#("rotation", "rotationX", "rotationY", "rotationZ", "translation", "translationX", "translationY", "translationZ", "hide", "direct")
	label lbl6 "Source" pos:[360,338] width:32 height:16
	dropDownList anim_source "" pos:[400,335] width:144 height:21 items:#("altBaro", "altRadar", "gear", "horizonBank", "horizonDive", "vertSpeed", "aileron", "aileronB", "aileronT", "aoa", "elevator", "flap", "rotor", "rudder", "speedBrake", "direction", "fuel", "oil", "gmeter", "rpm", "speed", "time", "clockHour", "clockMinute", "clockSecond", "damage", "user", "direct", "pedals", "damper", "FrontDamper", "BackDamper", "drivingWheel", "mainGun", "mainTurret", "wheel", "noseWheelTurn", "compassArrow", "compassCover", "compassPointer", "rotorH", "rotorV", "rotorHDive", "rotorVDive", "support", "hatchCommander", "hatchDriver", "hatchGunner", "obsGun", "obsTurret", "reload", "revolving", "turretDir", "wheelL", "wheelR", "scudLauncher", "flag")
	checkbox anim_memory "Memory" pos:[552,305] width:96 height:18 checked:true
	
	-- anim properties
	groupBox grp9 "Properties" pos:[360,360] width:384 height:216
	dotNetControl anim_property_list "ListView" pos:[368,376] width:368 height:160
	label lbl7 "Prop." pos:[368,547] width:32 height:16
	dropDownList anim_property "" pos:[403,544] width:94 height:21 items:#("selection", "axis", "begin", "end", "animPeriod", "minValue", "maxValue", "minPhase", "maxPhase", "sourceAddress", "angle0", "angle1", "offset0", "offset1", "hideValue", "axisPos[]", "axisDir[]", "angle", "axisOffset")
	edittext anim_value "Value" pos:[504,544] width:120 height:21
	button add_anim_property "A" pos:[632,544] width:24 height:24 toolTip:"Add Property" images:#("armaToolBoxSnsTools.bmp", undefined, 4, 3, 3, 3, 3)
	button remove_anim_property "M" pos:[661,544] width:24 height:24 toolTip:"Remove Selected Property" images:#("armaToolBoxSnsTools.bmp", undefined, 4, 4, 4, 4, 4)
	button clear_anim_property "R" pos:[712,544] width:24 height:24 toolTip:"Clear Properties" images:#("armaToolBox2.bmp", undefined, 10, 9, 9, 9, 9)
	button add_anim_class "A" pos:[720,584] width:24 height:24 toolTip:"Add Animation Class" images:#("armaToolBox2.bmp", undefined, 10, 8, 8, 8, 8)
	
	-- logo
	
	dotNetControl logo_btmp "PictureBox" pos:[344,632] width:416 height:72
	
	-- preview
	
	GroupBox grp4 "Preview" pos:[768,0] width:432 height:704
	--edittext preview_box "" pos:[776,24] width:416 height:640
	dotNetControl preview_box "RichTextBox" pos:[776,24] width:416 height:640
	Label warn_txt "WARNING! Do not delete the comments (//skelClass1 or //modelRefClass etc.)" pos:[776,678]
	button save_preview "A" pos:[1168,672] width:24 height:24 toolTip:"Dump into final file" images:#("armaToolBoxSnsTools.bmp", undefined, 4, 1, 1, 1, 1)
	
	on cfgToolRollout open do
	(
		--messageBox "TODO:\n -make file write out the classes\n -test \n\tde"
		logo_btmp.height = 149
		logo_btmp.imageLocation = (getDir #scripts) + "\\ArmAToolBox\\logo_cfg.bmp"
		
		skelFile = (getDir #scripts) + "\\ArmAToolBox\\modules\\cfgSets\\cfgSkeletonTemp.tmp"
		openSkelFile = openFile skelFile
		seek openSkelFile #eof
		maxlen=filepos openSkelFile
		seek openSkelFile 0
		res = readChars openSkelFile maxlen errorAtEOF:false
		tbops.initTextBox preview_box 
		preview_box.text = res as string
		close openSkelFile
		
		OutlinerRefresh skel_bones
		
		lvWidth = anim_property_list.width
		
		lvops.InitListView anim_property_list pLabelEdit:false pAllowReorder:true pCheckBoxes:false pFullRowSel:true pMultiSel:true pGridLines:true pHideHeaders:false pAllowDrop:false pInitColumns:  #("Property","Value") pInitColWidths:#(lvWidth/2,lvWidth/2)
	)
	on cfgToolRollout close do
	(
		saveFileQuery = queryBox("Would you like to save your file before exiting? \t")
		case saveFileQuery of
		(
			true:
			(
				local fileName = getSaveFileName caption:"Save As..." filename:"model.cfg"
				if fileName != undefined then
				(
					fs = createFile fileName
					format "%" preview_box.text to:fs
					close fs
				) else (
					false
				)
				#stop
			)
			false:
				#stop
		)
	)
	on disp_mem changed val do
	(
		addMemPoints skel_bones val
	)
	on skel_bones_populate pressed do
	(
		OutlinerRefresh skel_bones
	)
	
	on skel_bones_delete pressed do
	(
		removeNode skel_bones
	)
	
	on skel_bones_clear pressed do
	(
		tvops.ClearTvNodes skel_bones
	)
	
	on add_anim_property pressed do
	(
		lvops.AddLvItem anim_property_list pTextItems:#(anim_property.selected,anim_value.text)
	)
	
	on remove_anim_property pressed do
	(
		try(
			lvops.DeleteLvItem anim_property_list (lvops.GetSelectedIndex anim_property_list)
			lvops.RefreshListView anim_property_list
		) catch (
			messageBox("Nothing selected")
		)
	)
	
	on skel_bones NodeMouseDoubleClick arg do
	(
		try (
			anim_value.text = skel_bones.SelectedNode.text
		)catch()
	)
	on clear_anim_property pressed do
	(
		lvops.ClearLvItems anim_property_list
		lvops.RefreshListView anim_property_list
	)
	
	on add_skel_class_ref  pressed do
	(
		if (skel_class_ref.text != "") then
		(
			preview_box.text = substitutestring preview_box.text "//skelRefClass" ("//skelRefClass\n\tclass "+skel_class_ref.text+";")
			skel_classes = skel_class_inherit.items
			append skel_classes skel_class_ref.text
			skel_class_inherit.items = skel_classes
			skel_bones_inherit.items = append skel_bones_inherit.items skel_class_ref.text
			append preSkels skel_class_ref.text
			preview_box.text = updateClassList "Skeleton" skel_class_ref.text preview_box.text
		) else (
			messageBox("The external class reference must have a name. 1")
		)
	)
	
	on add_model_class_ref  pressed do
	(
		if (model_class_ref.text != "") then
		(
			preview_box.text = substitutestring preview_box.text "//modelRefClass" ("//modelRefClass\n\tclass "+model_class_ref.text+";")
			model_class_inherit.items = append model_class_inherit.items model_class_ref.text
			append preModels model_class_ref.text
			preview_box.text = updateClassList "Model" model_class_ref.text preview_box.text
		) else (
			messageBox("The external class reference must have a name. 1")
		)
	)
	
	on add_skel_class pressed do
	(
		if (skel_model_name.text != "") then
		(
			if (skel_class_inherit.selected != "none") then
				preview_box.text = substitutestring preview_box.text ("//skelClass"+(skelClassNum as string)) ("//skelClass"+(skelClassNum as string)+"\n\tclass "+skel_model_name.text+":"+skel_class_inherit.selected+"\n\t{\n\t\t"+(buildSkelClass skel_bones_inherit.selected skel_bones)+"\n\t};\n\t//skelClass"+((skelClassNum+1) as string))
			else
				preview_box.text = substitutestring preview_box.text ("//skelClass"+(skelClassNum as string)) ("//skelClass"+(skelClassNum as string)+"\n\tclass "+skel_model_name.text+"\n\t{\n\t\t"+(buildSkelClass skel_bones_inherit.selected skel_bones)+"\n\t};\n\t//skelClass"+((skelClassNum+1) as string))			
			skelClassNum +=1
			skel_bones_inherit.items = append skel_bones_inherit.items skel_model_name.text
			skel_class_inherit.items = append skel_class_inherit.items skel_model_name.text
			model_skel.items = append model_skel.items skel_model_name.text
			append preSkels skel_model_name.text
			preview_box.text = updateClassList "Skeleton" skel_model_name.text preview_box.text
		) else (
			messageBox("This class has to have a name.")
		)
	)
	
	on add_model_class pressed do
	(
		if (model_skel.items.count != 0 and model_name.text != "") then
		(
			preview_box.text = substitutestring preview_box.text ("//modelClass"+(modelClassNum as string)) ("//modelClass"+(modelClassNum as string)+"\n\tclass "+model_name.text+":"+model_class_inherit.selected+"\n\t{\n\t\t"+(buildModelClass model_sec_inher.checked model_class_inherit.selected model_skel.selected model_name.text anim_inher.checked)+"\n\t};\n\t//modelClass"+((modelClassNum+1) as string))
			modelClassNum +=1
			model_class_inherit.items = append model_class_inherit.items model_name.text
			anim_class.items = append anim_class.items model_name.text
			append preModels model_name.text
			preview_box.text = updateClassList "Model" model_name.text preview_box.text
		) else (
			messageBox("In order to create a model class with animations you should have at least one skeleton defined and the class must have a name.")
		)
	)
	
	on add_anim_class pressed do
	(
		if (anim_class.items.count != 0 and anim_name.text != "") then
		(
			preview_box.text = substitutestring preview_box.text ("//anims"+anim_class.selected) ((buildAnimClass anim_name.text anim_class_inherit.selected anim_type.selected anim_source.selected anim_memory.checked anim_property_list)+"\n\t\t\t//anims"+anim_class.selected)
			anim_class_inherit.items = append anim_class_inherit.items anim_name.text
			append preAnims anim_name.text
			preview_box.text = updateClassList "Animation" anim_name.text preview_box.text
		) else (
			messageBox("The animation class has to have a parent model class and a name.")
		)
	)
	
	on save_preview pressed do
	(
		-- ask for file location
		-- convert string to stream
		-- save file
		print preSkels
		print preModels
		print preAnims
		local fileName = getSaveFileName caption:"Save As..." filename:"model.cfg"
		if fileName != undefined then
		(
			fs = createFile fileName
			format "%" preview_box.text to:fs
			close fs
		) else (
			false
		)
	)
)

createDialog cfgToolRollout menu:cfgToolsMenu style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox,#style_sunkenedge)