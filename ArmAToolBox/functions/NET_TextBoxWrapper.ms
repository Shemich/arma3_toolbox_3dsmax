/*******************************************************************************
* ARMA II Workflow toolset for 3dsmax v1                                        			    *
********************************************************************************
*                                                                                                                     *
* $Id:: NET_TextBoxWrapper.ms 160 2009-04-17 17:53:33Z Alex Vorobiev                                *
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
struct TextBoxOps
(
	function initTextBox tb pMultiline: true \
		pCanSelect: true \
		pEnabled: true \
		pScrollBars:3 \
		pWordWrap: false \
		pTab: true \
		initText:"" =
	(
		tb.Multiline = pMultiline
		
		--tb.AutoWordSelection = true
		--tb.RightMargin = 1
		
		
		tb.Enabled = pEnabled
		tb.WordWrap = pWordWrap
		tb.AcceptsTab = pTab
		local SBclass = dotNetClass "System.Windows.Forms.RichTextBoxScrollBars"
		case pScrollBars of
		(
			0:
				tb.ScrollBars = SBclass.None
				--#stop
			1:
				tb.ScrollBars = SBclass.Horizontal
				--#stop
			2:
				tb.ScrollBars = SBclass.Vertical
				--#stop
			3:
				tb.ScrollBars = SBclass.Both
				--#stop
			default:
				tb.ScrollBars = SBclass.None
				--#stop
		)
		tb.Text = initText
		
	)
)

global tbops = TextBoxOps()