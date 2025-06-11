/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: blueprint.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                                *
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

plugin geometry blueprintcross_def
name:"Blueprint"
category:"Arma 2 Tools"
(
	
	local master
	local planes =#()
-- 	local topPlane
-- 	local sidePlane
-- 	local frontPlane
	tool create
	(
		on mousePoint clicks do
		(
			case clicks of
			(
				2:
				(
					newMat1 = standard()
					newMat2 = standard()
					newMat3 = standard()
					
					master = bluePrintController()
					master.dummy.boxsize = [10,10,10]
					in master
					(
						master.topPlane = plane pos:[0,0,0] lengthsegs:1 widthsegs:1 length:1 width:1 name:"Top" wirecolor:(color 0 0 0)
						master.sidePlane = plane pos:[0,0,0] widthsegs:1 lengthsegs:1 length:1 width:1 name:"Side" wirecolor:(color 0 0 0)
						master.frontPlane = plane pos:[0,0,0] widthsegs:1 lengthsegs:1 length:1 width:1 name:"Front" wirecolor:(color 0 0 0)
						master.topPlane.material = newMat1
						master.sidePlane.material = newMat2
						master.frontPlane.material = newMat3
						rotate master.sidePlane (eulerangles 0 -90 0)
						rotate master.frontPlane (eulerangles -90 0 0)
					)
					addPluginRollouts master
					completeRedraw()
				)
				6:
				(
					select master
					master = undefined
					#stop
				)
			)
		)
		on mouseMove clicks do
		(
			if clicks ==3 do
			(
				in master
				(
					master.topPlane.length = abs gridDist.y
					master.sidePlane.length = abs gridDist.y
					master.length = master.topPlane.length
				)
			)
			if clicks ==4 do
			(
				in master
				(
					master.topPlane.width = abs gridDist.x
					master.frontPlane.width = abs gridDist.x
					master.width = master.topPlane.width
				)
			)
			if clicks ==5 do
			(
				in master
				(
					master.sidePlane.width = abs gridDist.y
					master.frontPlane.length = abs gridDist.y
					master.height = master.sidePlane.width
				)
			)
		)
	)
)