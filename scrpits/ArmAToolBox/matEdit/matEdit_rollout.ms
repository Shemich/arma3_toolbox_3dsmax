try(destroydialog matEdit)catch()

RCMenu matEditMenu
(
	subMenu "File"
	(
		MenuItem	saveMat		"Save Material \t (ctrl-s)"		-- saves custom format (schematic data)
		MenuItem	saveAsMat	"Save Material As..."	-- saves custom format (schematic data)
		MenuItem	exportMat	"Export .rvmat"
		MenuItem 	LoadMat 	"Load Material"
		Seperator	sepA
		MenuItem	resetScem "Reset Material"
	)
)

rollout matEdit "ArmA2 Material Editor" width:867 height:644
(
	SchematicControl flowChart "Material Flow" pos:[8,40] width:640 height:592
	
	function refresh =
	(
		if heliumOps.targetControl != flowChart then
		(
			heliumOps.targetRollout = matEdit
			heliumOps.targetControl = matEdit.flowChart
			heliumOps.useMousePos = true
		)
	)
	
	on matEdit open do
	(
		fileIn "matEdit_func.ms"
		
		
		flowChart.setInfo = "2009 (c) Alex Vorobiev"
		flowChart.tileBackground = true
		flowChart.backgroundBitmap = (openBitmap ((getDir #scripts) + "\\ArmAToolBox\\matEdit\\o.bmp"))
		flowChart.redrawView
		refresh()
	)
	
	on flowChart rbuttonup do
	(
		heliumOps.connectionActive = false	-- since we are poping-up a right click menu, this will cancel our connection.
		refresh()
		-- below is only accurate if you get the right position, which the code below might not always get
		-- so use it as an example only for using 'findNodeByPos':
		--local heliumPos = (getDialogPos helium)
		--format "Node index found at right click mouse position: %\n" ( helium.s.findNodeByPos = (mouse.screenPos - heliumPos - [5,20]) ) -- the last point2 is to compensate for nodeWidth/Height and dialog borders etc. Can be different in your scripts
		popupmenu HeliumMenuA pos:mouse.screenpos
	)
)
createdialog matEdit style:#(#style_toolwindow, #style_sysmenu, #style_resizing) menu:matEditMenu
registerViewWindow matEdit