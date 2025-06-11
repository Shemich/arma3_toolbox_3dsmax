/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1.1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: mainMenu.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                                *
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
	if atbFloater != undefined do 
	(
		cui.UnRegisterDialogBar atbFloater
		closeRolloutFloater atbFloater
	)
	
) catch ()

global ExporterPath = (getDir #scripts) + "\\ArmAToolBox\\exporter\\*.ms"
global exporterFiles = getFiles (ExporterPath)

for i in exporterFiles do 
(
	newExp = FileIn i quiet:true
	format "Exporter Loaded: %\n" i
)

global ModulePath = (getDir #scripts) + "\\ArmAToolBox\\modules\\*.ms"
global modules = getFiles (ModulePath)

global rolloutNames = #()

ToolsPath = (getDir #scripts) + "\\ArmAToolBox\\tools\\*.ms"
toolFiles = getFiles (ToolsPath)

for i in toolFiles do 
(
	newTool = FileIn i quiet:true
	format "Tools Loaded: %\n" i
)

for i in modules do
(
   global loadedfile = FileIn i
   append rolloutNames (loadedfile)
)

viewportHeight = getViewSize()
viewLayout = viewport.getLayout() 
if viewLayout == #layout_2h or viewLayout == #layout_2t or viewLayout == #layout_2hb or viewLayout == #layout_3vl or viewLayout == #layout_3vr or viewLayout == #layout_3vt or viewLayout == #layout_3vb or viewLayout == #layout_4 or viewLayout == #layout_4vl or viewLayout == #layout_4vr or viewLayout == #layout_4ht or viewLayout == #layout_4hb do viewportHeight = viewportHeight*2 
global atbFloater = newRolloutFloater "ArmA Tool Box" 274 (viewportHeight[2] as integer)  --style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)

rollout primaryRollout "Arma 3 Toolbox v1.2" width:264 height:310
(
    dotNetControl logo "PictureBox" pos:[65,7] width:143 height:149
    GroupBox grp26 "Additional Tools" pos:[8,160] width:248 height:48
    button launch_nsc "NS" pos:[16,176] width:24 height:24 toolTip:"Selection Name Set Generator" images:#("armaToolBoxTools.bmp", undefined, 2, 1, 1, 1, 1)
    button launch_cfg "CFG" pos:[45,176] width:24 height:24 toolTip:"Model.cfg Generator" images:#("armaToolBoxTools.bmp", undefined, 2, 2, 2, 2, 2)
    label lbl12 "2009 (c) Alex <<Soul_Assassin>> Vorobiev. All rights reserved." pos:[8,223] width:248 height:32
    label lbl13 "2025 (c) Shemich. Updated for Arma 3." pos:[8,255] width:248 height:32

    on primaryRollout open do
    (
        logo.width = 143
        logo.height = 149
        logo.imageLocation = (getDir #scripts) + "\\ArmAToolBox\\logo.bmp"
        logo.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").Normal
    )
    
    on launch_nsc pressed do
    (
        fileIn ((getDir #scripts) + "\\ArmAToolBox\\snsTool.ms")
    )
    on launch_cfg pressed do
    (
        fileIn ((getDir #scripts) + "\\ArmAToolBox\\cfgTools.ms")
    )
)

addRollout primaryRollout atbFloater

for j in rolloutNames do
(
 	addrollout j atbFloater
	j.open = false
)

cui.RegisterDialogBar atbFloater maxSize:-1 minSize:-1 style:#(#cui_dock_left,#cui_floatable,#cui_handles)
cui.DockDialogBar atbFloater #cui_dock_left