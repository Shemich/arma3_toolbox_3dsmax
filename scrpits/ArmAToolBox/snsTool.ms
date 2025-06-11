/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: snsTool.ms 160 2009-04-17 17:53:33Z Alex Vorobiev 			                   *
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
try 
(
	if snsTool != undefined do 
	(
		destroyDialog snsTool
	)
	
) catch ()

global fileNameSeed = (getDir #scripts) + "\\ArmAToolBox\\modules\\NameSets\\example.ajv"

rollout snsTool "Slecetion Name Set Generator" width:272 height:488
(
	button sns_save "S" pos:[8,8] width:24 height:24 images:#("armaToolBoxSnsTools.bmp", undefined, 4, 1, 1, 1, 1) toolTip:"Save Selection Name Set"
	button sns_load "L" pos:[40,8] width:24 height:24 images:#("armaToolBoxSnsTools.bmp", undefined, 4, 2, 2, 2, 2) toolTip:"Load Selection Name Set"
	button sns_clear "X" pos:[240,8] width:24 height:24 images:#("armaToolBox2.bmp", undefined, 10, 9, 9, 9, 9) toolTip:"Clear Table"
	label sns_loaded "Currently Loaded Set: " pos:[8,36] width:240 height:13
	dotNetControl sns_lv "ListView" pos:[8,61] width:256 height:327
	label sns_lrem "Remember not to use any spaces in descriptions." pos:[16,429] width:241 height:13
	button sns_add "+" pos:[8,456] width:24 height:24 images:#("armaToolBoxSnsTools.bmp", undefined, 4, 3, 3, 3, 3) toolTip:"Add Selection Name"
	button sns_remove "-" pos:[40,456] width:24 height:24 images:#("armaToolBoxSnsTools.bmp", undefined, 4, 4, 4, 4, 4) toolTip:"Remove Selected Selection Name"
	editText sns_new_desc "" pos:[11,408] width:109 height:16
	editText sns_new_name "" pos:[120,408] width:136 height:16
	groupBox grp36 "Add Entry" pos:[8,392] width:256 height:56
	
	on snsTool open do
	(
		lvops.InitListView sns_lv pLabelEdit: false pAllowReorder: false pCheckBoxes: true pFullRowSel: true pMultiSel: true pGridLines: true pHideHeaders: false pAllowDrop: false pInitColumns:  #("Description","Selection Name")  pInitColWidths:#() 
	)
	
	on sns_clear pressed do
	(
		sns_loaded.text = "Currently Loaded Set: "
		lvops.ClearLvItems sns_lv
	)
	
	on sns_add pressed do
	(
		if ((sns_new_desc.text != "") and (sns_new_name.text !="")) then
		(
			lvops.AddLvItem sns_lv pTextItems:#(sns_new_desc.text,sns_new_name.text) pChecked:false pTag:undefined  pToolTip:"" pInsertAt: undefined
		) else (
			messageBox("Either the Description or the Name you have added into the \"Add Entry\" boxes is empty")
		)
	)
	
	on sns_remove pressed do
	(
		local count = lvops.GetLvItemCount sns_lv
		local i = 0
		while (i < (count)) do
		(
			if (lvops.GetLvItemCheck sns_lv i) == true then 
			(
				lvops.DeleteLvItem sns_lv i
				i = 0
				count = lvops.GetLvItemCount sns_lv
			) else (
				i+=1
				count = lvops.GetLvItemCount sns_lv
			)
		)
	)
	
	on sns_load pressed do
	(
		
		fileName =  getOpenFileName caption:"Open .ajv file" filename:fileNameSeed types:"AJV file(*.ajv)|*.ajv|"
		
		try(
			
			sns_fs = openFile fileName
			lvops.ClearLvItems sns_lv
			while (eof sns_fs != true) do
			(
				nameStringFull = filterString (readLine sns_fs)  ", "
				lvops.AddLvItem sns_lv pTextItems:nameStringFull pChecked:false pTag:undefined  pToolTip:"" pInsertAt: undefined
				skipToNextLine
			)
			
			close sns_fs
			
			sns_loaded.text = "Currently Loaded Set: " + (getFilenameFile fileName)
		)catch()
	)
	
	on sns_save pressed do
	(
		fileName =  getSaveFileName caption:"Save .ajv file" filename:fileNameSeed types:"AJV file(*.ajv)|*.ajv|"
		try(
			sns_fs = createFile fileName
			
			for i = 0 to (lvops.GetLvItemCount sns_lv)-1 do
			(
				format "% %\n" (lvops.GetLvItemName sns_lv i 0) (lvops.GetLvItemName sns_lv i 1) to:sns_fs
			)
			close sns_fs
			
			sns_loaded.text = "Currently Loaded Set: " + (getFilenameFile fileName)
		)catch()
	)
)

createDialog snsTool
