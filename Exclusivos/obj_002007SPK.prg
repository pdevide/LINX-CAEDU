*1-Valida os campos 'ENDERECO/CEP/CIDADE/BAIRRO/PAIS/DDD1/TELEFONE1/CONTA_CONTABIL/' no cadastramento do fornecedor.
*Evita que o cadastro de fornecedor fique incompleto.
		*	USR_INIT
		*	USR_ALTER_BEFORE  ->Return .f. Para o Metodo
		*	USR_ALTER_AFTER
		*	USR_INCLUDE_AFTER
		*	USR_SEARCH_BEFORE ->Return .f. Para o Metodo
		*	USR_SEARCH_AFTER
		*	USR_CLEAN_AFTER
		*	USR_REFRESH
		*	USR_SAVE_BEFORE   ->Return .f. Para o Metodo
		*	USR_SAVE_AFTER
		*	USR_ITEN_DELETE_BEFORE ->Return .f. Para o Metodo
		*	USR_ITEN_DELETE_AFTER
		*	USR_ITEN_INCLUDE_BEFORE ->Return .f. Para o Metodo
		*	USR_ITEN_INCLUDE_AFTER
		*   USR_LOSTFOCUS
		*	USR_CLICK
define class obj_entrada as custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	procedure metodo_usuario

		lparam xmetodo, xobjeto ,xnome_obj

		do case
		   case UPPER(xmetodo) == 'USR_INIT'


				** PAULO DEVIDE -> 27-01-2014
				
				ThisFormset.Lx_form1.addobject('BT_EXCEL1', 'BT_EXCEL')
				WITH ThisFormset.Lx_form1.BT_EXCEL1
					.height = 27
					.fontname = 'Arial'
					.Caption = 'Excel'
					.Left = 550
					.Top = 31
					.Width = 70
					.Visible = .T.
					.Enabled = .T.
					.anchor = 0
					.p_manter_baixo = .f.
					.p_manter_cima = .f.
					.p_manter_direita = .f.
					.p_manter_esquerda = .f.
					.p_muda_size = .f.
					&& aumenta a largura do form
*!*						.parent.width = .parent.width + 150
*!*						.parent.windowstate = 2			 && maximiza		
				ENDWITH
				
  			   
		   case UPPER(xmetodo) == 'USR_ALTER_BEFORE'  			
		   	  
 							LOCAL inppass
							*	Password (masked)
							inppass = rbInputBox( "Digite a Senha", "Senha para alteração de Pedido de Compra", "", , , "!", , "*")
							inppass = ALLTRIM(UPPER(inppass ))
							
							
							f_select("Select valor_atual from parametros where parametro = 'CAE_SENHA_COMPRAS' ","LISTAUT"	)

							SELECT LISTAUT
							CAEWHERE = LISTAUT.VALOR_ATUAL
							xaut = 0
							
							IF INLIST(inppass  , &CAEWHERE  )
								xaut = xaut  +1
							endif 	
								
				
							IF xaut > 0
								RETURN .t.
							ELSE
								MESSAGEBOX("Senha incorreta ou não autorizada")
								RETURN .f.
							endif 			    
  			     
			otherwise
				return .t.				
		endcase
	endproc
enddefine




DEFINE CLASS bt_estfilial as botao
	caption = 'Liberar Alteração de Preço'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 502
	HEIGHT =  27
	enabled = .F.
	visible  = .t.
	backcolor =  RGB(64,128,128)
	
	PROCEDURE click

							LOCAL inppass
							*	Password (masked)
							inppass = rbInputBox( "Digite a Senha", "Senha para alteração de Pedido de Compra", "", , , "!", , "*")
							inppass = ALLTRIM(inppass )
							
							
							f_select("Select valor_atual from parametros where parametro = 'P_USER_APROVA_ALT_COMPRA' ","LISTAUT"	)
							SELECT LISTAUT
							CAEWHERE = LISTAUT.VALOR_ATUAL
							f_select("Select PASSW from USERS where USUARIO IN " + CAEWHERE +" ","LISTAUT2"	)
							xaut = 0
							SELECT listaut2
							SCAN
								caecomp =  F_ds_cr(ALLTRIM(LISTAUT2.passw))
								IF UPPER(inppass)  = UPPER(caecomp)
									xaut = xaut  +1
								endif 	
								
								SELECT listaut2
							endscan 
							
							IF xaut > 0
								thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
								thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.p_tool_grid.Visible = .T.
								xlibera = 1
								RETURN .t.
							ELSE
								MESSAGEBOX("Senha incorreta ou não autorizada")
								RETURN .f.
							endif								
							
*!*								IF xaut > 0
*!*									RETURN .t.
*!*								ELSE
*!*									MESSAGEBOX("Senha incorreta ou não autorizada")
*!*									RETURN .f.
*!*								endif	

	ENDPROC
ENDDEFINE


** PAULO DEVIDE - 27-JAN-14
DEFINE CLASS BT_EXCEL as botao
	caption = 'Excel'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 644
	HEIGHT =  27
	enabled = .F.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		LOCAL llRet

		llRet = MESSAGEBOX("Deseja Formatar Relatório no Excel 2007/2010?",292,"Aviso")=6

		IF llRet
			
			f_wait("Exportando dados para o Excel...")
			
			ThisFormset.Lx_form1.Lx_pageframe1.Activepage = 2
			ThisFormset.Lx_form1.Lx_pageframe1.page2.LX_GRID_FILHA1.setfocus
			
			zExporta_Excel()

			f_wait()
		ENDIF


	ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
		*this.Visible = ThisFormset.Lx_form1.Lx_pageframe1.Activepage = 2
	ENDPROC

ENDDEFINE
** PAULO DEVIDE - 27-JAN-14


** PAULO DEVIDE - 27-JAN-14
FUNCTION zExporta_Excel
                
	lcCursor = "V_TABELAS_PRECO_00_PRODUTOS"

	IF NOT USED(lcCursor)
		RETURN
	ENDIF

	SELECT (lcCursor)
	IF RECCOUNT(lcCursor)=0
		MESSAGEBOX("Não há dados para exportar para o Excel!"+ CHR(13)+;
			"Selecione outro filtro.", 64, "Aviso")
		RETURN
	ENDIF

	GO top

	** Formata cursor no excel
	lcOldPoint = SET("Point")
	lcOldSeparator = SET("Separator")

	SET SEPARATOR TO ","
	SET POINT TO "."

	LOCAL oExcel as Object

	oExcel = CREATEOBJECT("Excel.application")

	WITH oExcel
		.Application.ErrorCheckingOptions.BackgroundChecking = .f.
		.SheetsInNewWorkbook = 1 && quantas sheets vai criar dentro do workbook = 1
		.workbooks.Add
		.Sheets(1).Name = lcCursor

		.visible = .f.

		** formata as celulas no excel, conforme se tipo no cursor
		lcColsDateFormat = ""

		lnFields = AFIELDS(laFields,lcCursor)
		FOR lnCount=1 TO ALEN(laFields,1)

			.Cells(1,lnCount).Select
			lcAdress = SUBSTR(.ActiveCell.Address,2,ATC("$",.ActiveCell.Address,2)-2)
			.Columns(lcAdress+":"+lcAdress).Select

			DO CASE
				CASE INLIST(laFields[lnCount,2],'C','M','V') && caracter
					.Selection.NumberFormat = "@" && formata a celula para TEXTO

				CASE laFields[lnCount,2] = 'Y' && moeda
					.Selection.NumberFormat = [_(* #,##0.00_);_(* (#,##0.00);_(* ""-""??_);_(@_)]

				CASE laFields[lnCount,2] = 'D' && Date
					.Selection.NumberFormat = "@" &&"m/d/yyyy"
					lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";D,"

				CASE laFields[lnCount,2] = 'T' && Datetime
					.Selection.NumberFormat = "@" &&"d/m/yy h:mm;@"
					lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";T,"

				CASE laFields[lnCount,2] = 'B' && Double (Numeric)
					lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
					.Selection.NumberFormat = lcMascara

				CASE laFields[lnCount,2] = 'F' && Float (Numeric)
					lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
					.Selection.NumberFormat = lcMascara

				CASE laFields[lnCount,2] = 'I' && Inteiro
					.Selection.NumberFormat = "#,##0"

				CASE laFields[lnCount,2] = 'L' && Logico (Verdadeiro/Falso)
					.Selection.NumberFormat = "General"

				CASE laFields[lnCount,2] = 'N' && Numeric
					lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
					.Selection.NumberFormat = lcMascara

				OTHERWISE
					.Selection.NumberFormat = "General"
			ENDCASE

			IF INLIST(laFields[lnCount,2],"B","F","I","N") && ALINHAMENTO A DIREITA DA CELULA numericos

				With .Selection
					.HorizontalAlignment = -4152
					.VerticalAlignment = -4107
					.WrapText = .F.
					.Orientation = 0
					.AddIndent = .F.
					.IndentLevel = 0
					.ShrinkToFit = .F.
					.ReadingOrder = -5002
					.MergeCells = .F.
				Endwith

			ENDIF

			.cells(1,lnCount).Select
			.Selection.NumberFormat = "@" && Formata a célula de cabeçalho (nome da coluna) como texto
			With .Selection.Interior
				.Pattern = 1
				.PatternColorIndex = -4105
				.Color = 65535
				.TintAndShade = 0
				.PatternTintAndShade = 0
			EndWith
			.Selection.Font.Bold = .t.

			.cells(1,lnCount).value = PROPER(laFields[lnCount,1])


		ENDFOR

		SELECT (lcCursor)
		lcArqtmp = "curtmp"+SYS(2015)+".txt"
		lcArqtmp = SYS(2023)+"\"+lcArqtmp
		COPY TO (lcArqtmp) DELIMITED WITH tab

		lcStrArq = FILETOSTR(lcArqtmp)
		_cliptext = lcStrArq

		.cells(2,1).select
		.ActiveSheet.Paste

		.Cells.Select
		.Cells.EntireColumn.AutoFit

		.Cells(1,1).select
		.Application.WindowState = -4137

		DELETE FILE (lcArqtmp)
		_cliptext = ""

		** Formatação de campo Date e Datetime
		IF NOT EMPTY(lcColsDateFormat)
			lcColsDateFormat = LEFT(lcColsDateFormat,LEN(lcColsDateFormat)-1) && tira a ultima virgula
			lnCols = GETWORDCOUNT(lcColsDateFormat,",")
			FOR lnCount=1 TO lnCols
				lcInfoColuna = GETWORDNUM(lcColsDateFormat,lnCount,",")
				lcColuna = GETWORDNUM(lcInfoColuna,1,";")
				lcTipoColuna = GETWORDNUM(lcInfoColuna,2,";")
				.Columns(lcColuna+":"+lcColuna).Select

				DO CASE
					CASE lcTipoColuna = "D"
						.Selection.NumberFormat = "m/d/yyyy"
					CASE lcTipoColuna = "T"
						.Selection.NumberFormat = "d/m/yy h:mm;@"
				ENDCASE

			ENDFOR
		ENDIF

		.cells(1,1).select
		.visible = .T.


	ENDWITH
	SET SEPARATOR TO &lcOldSeparator.
	SET POINT TO &lcOldPoint.
	RELEASE oExcel

	RETURN

ENDFUNC
** PAULO DEVIDE - 27-JAN-14



FUNCTION rbInputBox
lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
				tcFormat, tcInputMask, tcPasswordChar
private pcReturnValue
pcReturnValue = txDefaultValue
local oInputBox
oInputBox = CreateObject("rbInputBox", tcPrompt, tcTitle, ;
								 txDefaultValue, tnLeft, tnTop, ;
								 tcFormat, tcInputMask, tcPasswordChar)
oInputBox.Show()
RETURN pcReturnValue


**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
DEFINE CLASS rbinputbox AS form


	Height = 113
	Width = 318
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Input Box"
	ControlBox = .F.
	WindowType = 1
	Name = "frmInputBox"

	*-- empty value to return if Cancel is chosen; data type depends on data type of txValueIn
	xemptyvalue = .F.

	*-- the default value (if any)
	xdefaultvalue = .F.

	*-- the return value
	xreturnvalue = .F.


	ADD OBJECT lblinputbox AS label WITH ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Enter the value", ;
		Height = 20, ;
		Left = 6, ;
		Top = 26, ;
		Width = 190, ;
		TabIndex = 1, ;
		Name = "lblInputBox"


	ADD OBJECT txtinputbox AS textbox WITH ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 2, ;
		Top = 22, ;
		Width = 110, ;
		Name = "txtInputBox"


	ADD OBJECT cmdok AS commandbutton WITH ;
		Top = 72, ;
		Left = 84, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 3, ;
		Name = "cmdOK"


	ADD OBJECT cmdcancel AS commandbutton WITH ;
		Top = 72, ;
		Left = 172, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		TabIndex = 4, ;
		Name = "cmdCancel"


	PROCEDURE Unload
		with thisform
			if type(".xReturnValue") = "C"
				.xReturnValue = RTRIM( .xReturnValue)
			endif
			pcReturnValue = .xReturnValue
		endwith
	ENDPROC


	PROCEDURE Init
		lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
						tcFormat, tcInputMask, tcPasswordChar
		if type("tcPrompt") <> "C"
			tcPrompt = "Enter the value"
		endif
		if type("tcTitle") <> "C"
			tcTitle = "Input Box"
		endif
		if !( type("txDefaultValue") $ "CDNY")
			*	Valid input data types are C, D, N, and Y
			txDefaultValue = ""	&& default to character data type
		endif
		if type("tcFormat") <> "C"
			tcFormat = ""
		endif
		if type("tcInputMask") <> "C"
			tcInputMask = ""
		endif
		if type("tcPasswordChar") <> "C"
			tcPasswordChar = ""
		endif
		if len( alltrim( tcPasswordChar)) > 1
			tcPasswordChar = left( tcPasswordChar, 1)
		endif
		local llAutoCenter
		if pcount() < 5	&& Top and Left parameters were not passed
			tnLeft = 0
			tnTop = 0
		else	&& Top and left parameters were passed but may not be numeric
			if type("tnTop") = "N" and type("tnLeft") = "N"		&& both are numeric
				llAutoCenter = .F.
			else	&& one or both is not numeric, so AutoCenter the form
				tnLeft = 0
				tnTop = 0
				llAutoCenter = .T.
			endif
		endif

		with thisform
			.lblInputBox.caption = ALLTRIM( tcPrompt)
			.caption = ALLTRIM( tcTitle)
			.xDefaultValue = txDefaultValue
			.xReturnValue = .xDefaultValue
			.txtInputBox.value = .xDefaultValue
			.txtInputBox.format = ALLTRIM( tcFormat)
			.txtInputBox.InputMask = ALLTRIM( tcInputMask)
			.txtInputBox.PasswordChar = tcPasswordChar
			.Top = tnTop
			.Left = tnLeft
			.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

			do case
				case type("txDefaultValue") = "D"
					.xEmptyValue = {}
				case type("txDefaultValue") = "N"
					.xEmptyValue = 0
				case type("txDefaultValue") = "Y"
					.xEmptyValue = $0
				otherwise
					.xEmptyValue = ""
			endcase
		endwith
	ENDPROC


	PROCEDURE cmdok.Click
		with thisform
			.xReturnValue = .txtInputBox.value
			.release()
		endwith
	ENDPROC


	PROCEDURE cmdcancel.Click
		*
		*	If Cancel was chosen, return the empty value of the correct data type.
		*
		with thisform
			.xReturnValue = .xEmptyValue
			.release()
		endwith
	ENDPROC


ENDDEFINE
*
*-- EndDefine: btn_exp
**************************************************