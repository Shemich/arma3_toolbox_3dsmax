/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: blueprintController.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                                *
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
plugin helper bluePrintController
name:"BlueprintController"
classID:#(12344,54331)
extends:Dummy
replaceUI:true
invisible:true
(	
	parameters main rollout:params
	(
		topPlane type:#node
		sidePlane type:#node
		frontPlane type:#node
		length type:#worldUnits default:1 ui:lengthBP
		width type:#worldUnits default:1 ui:widthBP
		height type:#worldUnits default:1 ui:heightBP
		on length set val do
		(
			if topPlane != undefined and sidePlane != undefined and frontPlane != undefined do
			(
				topPlane.length = val
				sidePlane.length = val
			)
		)
		on width set val do
		(
			if topPlane != undefined and sidePlane != undefined and frontPlane != undefined do
			(
				topPlane.width = val
				frontPlane.width = val
			)
		)
		on height set val do
		(
			if topPlane != undefined and sidePlane != undefined and frontPlane != undefined do
			(
				sidePlane.width = val
				frontPlane.length = val
			)
		)
	)
	rollout params "Blueprint Dimensions"
	(
		spinner lengthBP "Length" type:#worldUnits range:[0.1, 1e32, 1]
		spinner widthBP "Width" type:#worldUnits range:[0.1, 1e32, 1]
		spinner heightBP "Height" type:#worldUnits range:[0.1, 1e32, 1]
	)
)