/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: 00projectSet.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                                *
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

rollout setupRoll "Project Setup" width:264 height:216
(
	groupBox grp3 "Project Folders" pos:[8,8] width:248 height:56
	button create_folders "Create" pos:[16,24] width:232 height:32
	groupBox grp4 "Model Set-Up" pos:[8,72] width:248 height:136
	groupBox grp5 "Tools" pos:[16,88] width:232 height:48
	button create_bp "B" pos:[24,104] width:24 height:24 toolTip:"Create a blueprint object." images:#("armaToolBoxBP.bmp", undefined, 1, 1, 1, 1, 1)
	button create_lt "L" pos:[54,104] width:24 height:24 toolTip:"Create three point light setup for better viewport material preview." images:#("armaToolBoxMem.bmp", undefined, 4, 4, 4, 4, 4)
	label lbl1 "Current Units:" pos:[16,144] width:72 height:16
	label unit_text "" pos:[88,144] width:104 height:16
	button reset_units "Reset Units to Meters" pos:[16,168] width:232 height:32 toolTip:"Reset to meters for a 1:1 import."
		
	on create_bp pressed do
	(
		startObjectCreation blueprintcross_def
	)
	on create_lt pressed do
	(
		startObjectCreation ArmAthreeLights
	)
	on create_folders pressed do
	(
		rollout setupFoldersRoll "Make Project Folder" width:240 height:248
		(
			editText folder_tag "Tag\t" pos:[8,8] width:112 height:16
			editText folder_name "Project Name\t" pos:[8,32] width:224 height:16
			groupBox grp6 "Sub-folders" pos:[8,56] width:224 height:152
			checkbox chk_anims "Animations" pos:[16,80] width:96 height:16
			checkbox chk_co "Textures" pos:[16,104] width:96 height:16 checked:true
			checkbox chk_nohq "Normal Maps" pos:[24,128] width:96 height:16 checked:true
			checkbox chk_spec "Specular Maps" pos:[24,152] width:96 height:16 checked:true
			checkbox chk_as "Ambient Occlusion" pos:[24,176] width:144 height:16 checked:true
			checkbox chk_sounds "Sounds" pos:[120,80] width:96 height:16
			checkbox chk_scripts "Scripts" pos:[120,104] width:96 height:16
			button makeFolder "A" pos:[208,216] width:24 height:24 toolTip:"Make the folders." images:#(((getDir #scripts) + "\\ArmAToolBox\\armaToolBox2.bmp"), undefined, 10, 8, 8, 8, 8)
			
			fn createFolder root folderName create=
			(
				fullPath = root+"\\"+folderName
				if create == true do (makeDir fullPath)
			)
			
			fn createFolders folderPath tag folderName folders=
			(
				mainFolder = (folderPath+"\\"+tag+"_"+folderName)
				success = makeDir mainFolder
				if success == true then
				(
					createFolder mainFolder folders[1][1] folders[1][2]
					createFolder mainFolder folders[2][1] folders[2][2]
					if folders[2][2] != false then
					(
						local dataFolder = mainFolder+"\\data"
						createFolder dataFolder folders[3][1] folders[3][2]
						createFolder dataFolder folders[4][1] folders[4][2]
						createFolder dataFolder folders[5][1] folders[5][2]
					) else (
						false
					)
					createFolder mainFolder folders[6][1] folders[6][2]
					createFolder mainFolder folders[7][1] folders[7][2]
				)else(
					false
				)
			)
			
			on chk_co changed val do
			(
				chk_nohq.enabled = val
				chk_spec.enabled = val
				chk_as.enabled = val
			)
			
			on makeFolder pressed do
			(
				newPath = getsavepath()
				if newPath != undefined and folder_tag.text != "" and folder_name.text != "" then
					createFolders newPath folder_tag.text folder_name.text #(#("anims",chk_anims.checked),#("data",chk_co.checked),#("normals",chk_nohq.checked),#("smdi",chk_spec.checked),#("as",chk_as.checked),#("sounds",chk_sounds.checked),#("scripts",chk_scripts.checked))
				else
					messageBox "You have to specify a tag and a foldername."
			)
			
		)
		createDialog setupFoldersRoll
	)
	
	on setupRoll open do
	(
		unit_text.text = (units.SystemType as string)
	)
	
	on reset_units pressed do
	(
		units.SystemType = #meters
		units.DisplayType = #Metric
		units.MetricType = #Meters
		unit_text.text = (units.SystemType as string)
	)
)
