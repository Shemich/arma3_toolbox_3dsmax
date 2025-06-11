/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: 04hierarchy.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                    *
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
function addChildren theNode theChildren = 
(
	for c in theChildren do
	(
		newNode = theNode.Nodes.add c.name
		newNode.tag = dotNetMXSValue c
		if c.children != undefined do addChildren newNode c.children
-- 		if c.isHidden == false do newNode.Checked = true
-- 		clouds_name_array =  c.alLoadedCloudName
-- 		clouds_bool_array = c.alLoadedCloudVisible
-- 		addClouds newNode clouds_name_array clouds_bool_array c
	)
)

function fillInNodesTreeView tv =
(
	tv.nodes.clear()	
	theRoot = tv.Nodes.add "Named Selections"
	--theRoot.Checked = true
	rootNodes = for o in objects where (superClassOf o == GeometryClass and o.parent == undefined and o.isHidden == false and o.isFrozen == false) collect o
	addChildren theRoot rootNodes 
)

function OutlinerRefresh tv =
(
	try (tvops.initTreeView tv pLabelEdit:false  pCheckBoxes:false pFullRowSel:false pAllowDrop:false pScrollable:true  pShowLines:true)catch("Init Error")
	try (	
			fillInNodesTreeView tv
			tv.ExpandAll()
		)catch("Fill Error")
)

rollout heirarchyRoll "Hierarchy" width:264 height:504
(
	dotNetControl tv "TreeView" pos:[8,8] width:248 height:456
	button cfgTool_btn "CFG" pos:[8,472] width:24 height:24 toolTip:"Model.cfg Generator" images:#("armaToolBoxTools.bmp", undefined, 2, 2, 2, 2, 2)
	button tv_ref "R" pos:[232,472] width:24 height:24 images:#("armaToolBox2.bmp", undefined, 10, 10, 10, 10, 10) toolTip:"Refresh"
	
	on heirarchyRoll open  do
	(
		OutlinerRefresh tv
	)
	on tv NodeMouseDoubleClick arg do
	(
		try(
			execute ("select $"+(tv.SelectedNode.text as string))
		) catch ()
	)
	on tv_ref pressed  do
	(
		OutlinerRefresh tv
	)
	on cfgTool_btn pressed do
	(
		fileIn ((getDir #scripts) + "\\ArmAToolBox\\cfgTools.ms")
	)
)
	
