/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: 02namedSelections.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                    *
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

global nameString = ""

fn loadNameSets catList=
(
	-- checks for .ajv files in the names dir
	-- lists them in the sets dropdown
	-- ?? calls the fill function
	
	-- TAKES
	-- catList = catogory dropdown
	
	nameCatPath = (getDir #scripts) + "\\ArmAToolBox\\modules\\NameSets\\*.ajv"
	global modules = getFiles (nameCatPath)
	
	categotyNames = #()
	
	for i in modules do
	(
		nameSetFileName = getFilenameFile i
		append categotyNames nameSetFileName
	)
	
	catList.items = categotyNames 
	catList.selection = 1
)

fn loadNames catList nameList=
(
	-- reads out the .ajv file and copiles the arrays
	-- sets the dropdownlist
	
	-- TAKES
	-- catList = catogory dropdown
	-- nameList = name dropdown
	
	global nameSetArray = #()
	global nameSetEqArray = #()
	
	arrayIndex = catList.selection
	
	fs = openFile modules[arrayIndex]
	
	while (eof fs != true) do
	(
		nameStringFull = filterString (readLine fs)  ", "
		append nameSetArray nameStringFull[1]
		append nameSetEqArray nameStringFull[2]
		skipToNextLine
	)
	
	nameList.items = nameSetArray
)

fn compilePre sidel sider frontf frontb downu downd add=
(
	-- compiles the prefix
	
	--TAKES
	-- side = integer of button
	-- front = integer of button
	-- down = integer of button
	-- add = integer of button
	
	side = ""
	front = ""
	down = ""
	addPre = ""
	
	sideArray = #("l_","r_")
	frontArray = #("f_","b_")
	downArray = #("u_","lo_")
	
	if sidel == true do (append side sideArray[1])
	if sider == true do (append side sideArray[2])
	if frontf == true do (append front frontArray[1])
	if frontb == true do (append front frontArray[2])
	if downu == true do (append down downArray[1])
	if downd == true do (append down downArray[2])
	
	if add != "" do (addPre = add+"_")
	
    preString = side + front + down + addPre 
	
	return preString
)

fn compileString preString mainString postString=
(
	-- compiles the strings and returns the final name
	
	-- TAKES
	-- preString = prefix
	-- mainString = main
	-- postString = suffix
	
	totalName = preString + mainString + postString
	return totalName
)


rollout nameSelections "Named Selection" width:264 height:504
(
	
	dropdownList catList "Availiable Sets" pos:[8,9] width:216 height:40
	button cat_ref "R" pos:[232,25] width:24 height:24 images:#("armaToolBox2.bmp", undefined, 10, 10, 10, 10, 10) toolTip:"Refresh"
	button set_ref "R" pos:[224,225] width:24 height:24 images:#("armaToolBox2.bmp", undefined, 10, 10, 10, 10, 10) toolTip:"Refresh"
	GroupBox grp4 "Prefixes" pos:[8,56] width:248 height:131
	GroupBox grp1 "Side" pos:[16,71] width:72 height:48
	checkbutton pre_left "L" pos:[24,88] width:24 height:24 toolTip:"l_" images:#("armaToolBox2.bmp", undefined, 10, 1, 1, 1, 1)
	checkbutton pre_right "R" pos:[56,88] width:24 height:24 toolTip:"r_" images:#("armaToolBox2.bmp", undefined, 10, 2, 2, 2, 2)
	GroupBox grp2 "Front/Back" pos:[96,71] width:72 height:48
	checkbutton pre_front "F" pos:[104,88] width:24 height:24 toolTip:"f_" images:#("armaToolBox2.bmp", undefined, 10, 3, 3, 3, 3)
	checkbutton pre_back "B" pos:[136,88] width:24 height:24 toolTip:"b_" images:#("armaToolBox2.bmp", undefined, 10, 4, 4, 4, 4)
	GroupBox grp3 "Up/Down" pos:[176,71] width:72 height:48
	checkbutton pre_up "U" pos:[184,88] width:24 height:24 toolTip:"u_" images:#("armaToolBox2.bmp", undefined, 10, 5, 5, 5, 5)
	checkbutton pre_down "D" pos:[216,88] width:24 height:24 toolTip:"lo_" images:#("armaToolBox2.bmp", undefined, 10, 6, 6, 6, 6)
	edittext pre_add "Additional : " pos:[16,131] width:232 height:16
	label lbl1 "Note: No need to add the \"_\" (underscore) character before or after." pos:[17,155] width:232 height:29
	GroupBox grp9 "Part Name" pos:[8,193] width:248 height:96
	dropdownList namelist "Names in the current set:" pos:[16,209] width:200 height:40
	edittext totalMain "Part Name" pos:[16,258] width:232 height:16
	GroupBox grp10 "Suffixes" pos:[8,297] width:248 height:95
	edittext sufAdd "Custom : " pos:[16,313] width:232 height:16
	label lbl4 "Note: No need to add the \"_\" (underscore) character before or after." pos:[17,337] width:232 height:29
	GroupBox grp11 "Preview Box" pos:[8,401] width:248 height:62
	label prevLine "" pos:[16,418] width:232 height:35
	button prev_btn "P" pos:[8,472] width:24 height:24 images:#("armaToolBox2.bmp", undefined, 10, 7, 7, 7, 7) toolTip:"Preview"
	button name_btn "N" pos:[40,472] width:24 height:24 images:#("armaToolBox2.bmp", undefined, 10, 8, 8, 8, 8) toolTip:"Apply"
	button clr_btn "X" pos:[232,472] width:24 height:24 images:#("armaToolBox2.bmp", undefined, 10, 9, 9, 9, 9) toolTip:"Reset Fields"
	checkbox seq_chk "Sequence" pos:[16,370] width:120 height:16
	
	on nameSelections open do
	(
		-- fills in the dropdown boxes
		
		loadNameSets catList
		loadNames catList nameList
	)
	
	on cat_ref pressed do
	(
		-- refreshes the category dropdown
		
		loadNameSets catList
	)
	
	on set_ref pressed do
	(
		-- refreshes the name dropdown
		
		loadNames catList nameList
	)
	
	on catList selected arg do
	(
		-- refresh the name dropdown
		
		loadNames catList nameList
	)
	
	on nameList selected arg do
	(
		-- refresh the name textbox
		
		totalMain.text = nameSetEqArray[arg]
	)
	
	on prev_btn pressed do
	(
		-- displays the string
		
		preComp = compilePre pre_left.checked pre_right.checked pre_front.checked pre_back.checked pre_up.checked pre_down.checked pre_add.text
		sufComp = ""
		if sufAdd.text != "" do (sufComp = "_" + sufAdd.text)
		totalString = preComp + totalMain.text + sufComp
		
		if seq_chk.checked == true do (append totalString "##")
		
		prevLine.text = totalString
	)
	
	on name_btn pressed do
	(
		-- names the selected objects with the name
		
		preComp = compilePre pre_left.checked pre_right.checked pre_front.checked pre_back.checked pre_up.checked pre_down.checked pre_add.text
		sufComp = ""
		if sufAdd.text != "" do (sufComp = "_" + sufAdd.text)
		totalString = preComp + totalMain.text + sufComp
		
		numInt = 0
		
		for i in selection do
		(
			if seq_chk.checked == true then 
			(
				numInt += 1
				num = numInt as string
			) else (
				num = ""
			)
			i.name = totalString+num
		)
	)
	
	on clr_btn pressed do
	(
		-- clears the 4 fields
		-- unchecks all buttons
		
		sufAdd.text = ""
		totalMain.text = ""
		pre_add.text = ""
		prevLine.text = ""
		
		pre_left.checked = false
		pre_right.checked = false
		pre_front.checked = false
		pre_back.checked = false
		pre_up.checked = false
		pre_down.checked = false
		seq_chk.checked = false
	)
)
	
