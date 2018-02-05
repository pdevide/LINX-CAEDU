** OBJ_009161SPK.PRG --> PAULO DEVIDE -> 27-05-2013

*- Definindo a classe do objeto de entrada que sera criado na Form.
Define Class obj_entrada As Custom
*- Nome do metodo/função que os objetos linx vão chamar.
	Procedure metodo_usuario
	Lparam xmetodo, xobjeto, xnome_obj

	Do Case
	Case Upper(xmetodo) == 'USR_ALTER_BEFORE'



	Case Upper(xmetodo) == 'USR_INIT'

		** PAULO DEVIDE -> 21-05-2013 (botao pra imprimir pedido em inglês)
		thisformset.lx_form1.addobject('bt_report1', 'bt_report')
		WITH thisformset.lx_form1.bt_report1
			.height = 54
			.fontname = 'Arial'
			.Caption = 'Relatório Excel'
			.Left = 524
			.Top = 24
			.Width = 70
			.Visible = .T.
			.Enabled = .T.
			.anchor = 0
			.p_manter_baixo = .f.
			.p_manter_cima = .f.
			.p_manter_direita = .f.
			.p_manter_esquerda = .f.
			.p_muda_size = .f.
			
		ENDWITH
		** FIM: 20-05-2013
		

	Case Upper(xmetodo) == 'USR_SAVE_BEFORE'




	Endcase
	Endproc

Enddefine


** PAULO DEVIDE -> 22-05-2013
DEFINE CLASS bt_report as botao
	caption = 'Relatório Excel'
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
		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Formatar Relatório no Excel?",292,"Aviso")=6
		
		IF llRet
			f_wait("Exportando dados para o Excel...")
			LOCAL lcArquivo as String
			lcArquivo = SYS(2023)+"\conta_corrente_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"
			
			zConta_Corrente_Excel(lcArquivo)
			
			f_wait()	
		ENDIF
		

	ENDPROC
	
	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L") 
	ENDPROC
	
ENDDEFINE
** FIM: 22-05-2013



** PAULO DEVIDE -> 22-05-2013
FUNCTION zConta_Corrente_Excel
PARAMETERS tcArquivo

	*** Comentado, não tem modelo de layout para este relatório (lista padrão)	
	*!*		** Define o nome do arquivo XLSX a ser criado
	*!*		lcSQL = "select codigo_modelo,descricao_modelo,imagem_modelo "+;
	*!*					"from CAE_MODELOS_EXCEL where codigo_modelo='0001'"

	*!*		** Pega o modelo (template em branco) para gerar o Excel do relatório
	*!*		f_select(lcSQL,"vCAE_Modelos") 

	*!*		** Converte a imagem para arquivo binário
	*!*		lcTmpArqxls = CAST(vCAE_Modelos.imagem_modelo as blob)
	*!*		STRTOFILE(lcTmpArqxls,tcArquivo) && grava modelo na pasta temporária do usuário

	** Querys de dados do relatório
	IF USED("vtmp_excel_ctb_lancamento")
		SELECT vtmp_excel_ctb_lancamento 
		USE
	ENDIF

	IF USED("vtmp_ctb_lancamento_01_item")
		SELECT vtmp_ctb_lancamento_01_item
		USE
	ENDIF

	** função do linx para gerar o cursor vtmp_ctb_lancamento_01_item com 
	** os dados selecionados no filtro
	=f_popula_filha('v_ctb_lancamento_01','v_ctb_lancamento_01_item')		

	** relaciona a tabela pai com cursor da tabela filtro gerada pela f_popula_filha	
	select ;
		v_ctb_lancamento_01.empresa ,;
		v_ctb_lancamento_01.lancamento ,;
		v_ctb_lancamento_01.lote_lancamento ,;
		vtmp_ctb_lancamento_01_item.item ,;
		v_ctb_lancamento_01.cod_filial ,;
		v_ctb_lancamento_01.data_lancamento ,;
		v_ctb_lancamento_01.data_conciliado ,;
		v_ctb_lancamento_01.indica_depara ,;
		v_ctb_lancamento_01.permitir_inclusao ,;
		v_ctb_lancamento_01.desc_empresa ,;
		v_ctb_lancamento_01.filial ,;
		v_ctb_lancamento_01.lancamento_padrao ,;
		v_ctb_lancamento_01.desc_lancamento_padrao ,;
		v_ctb_lancamento_01.controle_sistema ,;
		v_ctb_lancamento_01.indicador_tabela_origem ,;
		v_ctb_lancamento_01.inativa ,;
		v_ctb_lancamento_01.tipo_movimento ,;
		v_ctb_lancamento_01.lx_grupo_movimento ,;
		v_ctb_lancamento_01.desc_tipo_movimento ,;
		v_ctb_lancamento_01.gerado_integracao ,;
		v_ctb_lancamento_01.desc_lote ,;
		v_ctb_lancamento_01.data_exportacao ,;
		v_ctb_lancamento_01.lote_conciliado ,;
		v_ctb_lancamento_01.data_inicial ,;
		v_ctb_lancamento_01.data_final ,;
		v_ctb_lancamento_01.tipo_lote ,;
		v_ctb_lancamento_01.gerado_valor_financeiro ,;
		v_ctb_lancamento_01.usuario_assinatura ,;
		v_ctb_lancamento_01.data_assinatura ,;
		v_ctb_lancamento_01.numero_correlativo ,;
		v_ctb_lancamento_01.tipo_comprovante ,;
		v_ctb_lancamento_01.desc_tipo_comprovante ,;
		vtmp_ctb_lancamento_01_item.cod_clifor ,;
		vtmp_ctb_lancamento_01_item.conta_contabil ,;
		vtmp_ctb_lancamento_01_item.credito ,;
		vtmp_ctb_lancamento_01_item.debito ,;
		vtmp_ctb_lancamento_01_item.historico ,;
		vtmp_ctb_lancamento_01_item.codigo_historico ,;
		vtmp_ctb_lancamento_01_item.rateio_centro_custo ,;
		vtmp_ctb_lancamento_01_item.conciliado ,;
		vtmp_ctb_lancamento_01_item.moeda ,;
		vtmp_ctb_lancamento_01_item.data_digitacao ,;
		vtmp_ctb_lancamento_01_item.nome_clifor ,;
		vtmp_ctb_lancamento_01_item.codigo_resumido ,;
		vtmp_ctb_lancamento_01_item.desc_conta ,;
		vtmp_ctb_lancamento_01_item.desc_tipo_lancamento ,;
		vtmp_ctb_lancamento_01_item.razao_social ,;
		vtmp_ctb_lancamento_01_item.cgc_cpf ,;
		vtmp_ctb_lancamento_01_item.rg_ie ,;
		vtmp_ctb_lancamento_01_item.uf ,;
		vtmp_ctb_lancamento_01_item.pais ,;
		vtmp_ctb_lancamento_01_item.desc_conta_reduzida ,;
		vtmp_ctb_lancamento_01_item.desc_rateio_centro_custo ,;
		vtmp_ctb_lancamento_01_item.lx_tipo_lancamento ,;
		vtmp_ctb_lancamento_01_item.permite_alteracao ,;
		vtmp_ctb_lancamento_01_item.dispara_formula ,;
		vtmp_ctb_lancamento_01_item.credito_debito ,;
		vtmp_ctb_lancamento_01_item.indica_id_contabil_terceiro ,;
		vtmp_ctb_lancamento_01_item.somente_lanc_contabil ,;
		vtmp_ctb_lancamento_01_item.inativo_para_lancto_manual ,;
		vtmp_ctb_lancamento_01_item.debito_moeda ,;
		vtmp_ctb_lancamento_01_item.credito_moeda ,;
		vtmp_ctb_lancamento_01_item.cambio_na_data ,;
		vtmp_ctb_lancamento_01_item.tipo_conta ,;
		vtmp_ctb_lancamento_01_item.conta_padrao ,;
		vtmp_ctb_lancamento_01_item.rateio_filial ,;
		vtmp_ctb_lancamento_01_item.desc_rateio_filial ,;
		vtmp_ctb_lancamento_01_item.id_contrapartida ,;
		vtmp_ctb_lancamento_01_item.banco ,;
		vtmp_ctb_lancamento_01_item.valor_financeiro ,;
		vtmp_ctb_lancamento_01_item.valor_financeiro_padrao ;
	from v_ctb_lancamento_01 ;
		inner join vtmp_ctb_lancamento_01_item on vtmp_ctb_lancamento_01_item.lancamento = v_ctb_lancamento_01.lancamento ;
	order by v_ctb_lancamento_01.lancamento , vtmp_ctb_lancamento_01_item.item ;
	into cursor vtmp_excel_ctb_lancamento 
	** Fim: Querys de dados do relatório

	SELECT 	vtmp_excel_ctb_lancamento 
	** Cria um excel e exporta os dados
	zExporta_Excel("vtmp_excel_ctb_lancamento")
					

ENDFUNC
** Fim: 22-05-2013

** PAULO DEVIDE -> 28-05-2013
FUNCTION zExporta_Excel
PARAMETERS lcCursor
** Formata cursor no excel
lcOldPoint = SET("Point")
lcOldSeparator = SET("Separator")

** tem que ficar neste formato para exportar para txt
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

	SELECT (lcCursor)
	lcArqtmp = "curtmp"+SYS(2015)+".txt"
	lcArqtmp = SYS(2023)+"\"+lcArqtmp
	COPY TO (lcArqtmp) DELIMITED WITH " WITH tab
	
	lcStrArq = FILETOSTR(lcArqtmp)
	_cliptext = lcStrArq
	
	.cells(2,1).select
	.ActiveSheet.Paste

    
    .Cells(1,1).select
	.Application.WindowState = -4137    	
	
	DELETE FILE (lcArqtmp)
	_cliptext = ""
	
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
				.Selection.NumberFormat = "General"
				.Selection.NumberFormat = "_(* #,##0.00_);_(* (#,##0.00);_(* ""-""??_);_(@_)"
				
			CASE laFields[lnCount,2] = 'D' && Date
			    .Selection.NumberFormat = "@" &&"m/d/yyyy"
				lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";D," 

			CASE laFields[lnCount,2] = 'T' && Datetime
		    	.Selection.NumberFormat = "@" &&"d/m/yy h:mm;@"
				lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";T," 
		    	
			CASE laFields[lnCount,2] = 'B' && Double (Numeric)
				 .Selection.NumberFormat = "General"
				 lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
				 .Selection.NumberFormat = lcMascara

			CASE laFields[lnCount,2] = 'F' && Float (Numeric)
	 			 .Selection.NumberFormat = "General"
				 lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
				 .Selection.NumberFormat = lcMascara

			CASE laFields[lnCount,2] = 'I' && Inteiro
			    .Selection.NumberFormat = "General"  
				.Selection.NumberFormat = "#,##0"
				
			CASE laFields[lnCount,2] = 'L' && Logico (Verdadeiro/Falso)
				.Selection.NumberFormat = "General"

			CASE laFields[lnCount,2] = 'N' && Numeric
			     .Selection.NumberFormat = "General"
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

	.Cells.Select
    .Cells.EntireColumn.AutoFit
	
	.cells(1,1).select	
	.visible = .t.
	
ENDWITH
SET SEPARATOR TO &lcOldSeparator.
SET POINT TO &lcOldPoint.
RELEASE oExcel

RETURN
ENDFUNC


*--------------------------------------------------------
* Function Name.: rbInputBox()
*
* Author........: Rick Borup
*                 Information Technology Associates
*                 Champaign, IL U.S.A.
*                 http://www.ita-software.com
*                 rborup@ita-software.com
*
* Date Written..: March 20, 2000
*
* Date Released.: April 27, 2000
*
* Date Revised..: January 30, 2003
*
* Abstract......: A simple, general-purpose input box for Visual FoxPro.
*
* Parameters....: (All parameters are optional.)
*
*    tcPrompt - the prompt that the user sees.
*               The default is "Enter the value".
*
*    tcTitle - the title for the form.
*              The default is "InputBox".
*
*    txDefaultValue - default value.
*              This parameter can be a character, date, numeric, or
*              currency data type. If this parameter is omitted, an
*              empty textbox is displayed and the data type is character.
*              The data type of the return value is the same as the
*              data type of the default value.
*
*    tnLeft - the form's Left position
*
*    tnTop - the form's Top position.
*
*            If Left and Top are omitted or are not numeric, rbInputBox()
*            is auto-centered.
*
*    tcFormat - a value for the Format property of the textbox
*
*    tcInputMask - a value for the InputMask property of the textbox
*
*    tcPasswordChar - a value for the textbox's PasswordChar value
*                     (the default is blank)
*
* Returns.......: Character, Date, Numeric, or Currency depending
*                 on the data type of the default value
*
*                 If the Cancel button is chosen, rbInputBox() returns
*                 an empty value of the appropriate data type.
*
* Copyright.....: Copyright (c) Information Technology Associates, 2000-2003
*
* License.......: rbInputBox() is freeware. You may include rbInputBox()
*                 royalty-free inside a compiled Visual FoxPro APP or EXE
*                 that you create for your own use or for distribution to
*                 a third party.
*
*                 You may redistribute the rbInputBox() distribution
*                 package, INPUTBOX.ZIP, as long as (a) you distribute
*                 INPUTBOX.ZIP in its entirety and without modifications,
*                 and (b) you do not charge anything for it.
*
* Warranty......: NONE. This code is released AS IS without warranty
*                 of any kind. The user assumes all responsibility and
*                 liability for its use.
*
* Support.......: NONE, but your comments and suggestions for improvements
*                 are welcome. Please e-mail rborup@ita-software.com or
*                 reach me via the Universal Thread at
*                 http://www.universalthread.com.
*
* Release History:January 30, 2003 - Renamed as "rbInputBox" to avoid conflict
*                                    with the native InputBox() function in
*                                    VFP 7.0 and later.
*                                  - Added tcPasswordChar as 8th parameter
*
*                 May 2, 2000 - Corrected errata in the readme.txt file.
*
*                 April 27, 2000 - Original Release
*
* Known Limitations:
*                 The original release of rbInputBox does not automatically
*                 resize the form or any of its controls. The current
*                 sizes are designed to be adequate for most simple input
*                 functions. There is no arbitrary limitations, other than
*                 VFP's own inherent limitations, on the size of the return
*                 value. However, long titles, prompts, or entered values may
*                 appear truncated on the form.
*
Function rbInputBox
Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar
Private pcReturnValue
pcReturnValue = txDefaultValue
Local oInputBox
oInputBox = Createobject("rbInputBox", tcPrompt, tcTitle, ;
	txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar)
oInputBox.Show()
Return pcReturnValue



Function rbInputBox2
Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar
Private pcReturnValue
pcReturnValue = txDefaultValue
Local oInputBox
oInputBox = Createobject("rbInputBox2", tcPrompt, tcTitle, ;
	txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar)
oInputBox.Show()
Return pcReturnValue


Function rbMotivo
Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar
	
Private pcReturnValue
pcReturnValue = txDefaultValue

Local oInputBox
oInputBox = Createobject("rbMotivo", tcPrompt, tcTitle, ;
	txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar)
oInputBox.Show()

Return pcReturnValue


**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
Define Class rbInputBox As Form


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


	Add Object lblinputbox As Label With ;
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


	Add Object txtinputbox As TextBox With ;
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


	Add Object cmdok As CommandButton With ;
		Top = 72, ;
		Left = 84, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 3, ;
		Name = "cmdOK"


	Add Object cmdcancel As CommandButton With ;
		Top = 72, ;
		Left = 172, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		TabIndex = 4, ;
		Name = "cmdCancel"


	Procedure Unload
	With Thisform
		If Type(".xReturnValue") = "C"
			.xreturnvalue = Rtrim( .xreturnvalue)
		Endif
		pcReturnValue = .xreturnvalue
	Endwith
	Endproc


	Procedure Init
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	If Type("tcPrompt") <> "C"
		tcPrompt = "Enter the value"
	Endif
	If Type("tcTitle") <> "C"
		tcTitle = "Input Box"
	Endif
	If !( Type("txDefaultValue") $ "CDNY")
*	Valid input data types are C, D, N, and Y
		txDefaultValue = ""	&& default to character data type
	Endif
	If Type("tcFormat") <> "C"
		tcFormat = ""
	Endif
	If Type("tcInputMask") <> "C"
		tcInputMask = ""
	Endif
	If Type("tcPasswordChar") <> "C"
		tcPasswordChar = ""
	Endif
	If Len( Alltrim( tcPasswordChar)) > 1
		tcPasswordChar = Left( tcPasswordChar, 1)
	Endif
	Local llAutoCenter
	If Pcount() < 5	&& Top and Left parameters were not passed
		tnLeft = 0
		tnTop = 0
	Else	&& Top and left parameters were passed but may not be numeric
		If Type("tnTop") = "N" And Type("tnLeft") = "N"		&& both are numeric
			llAutoCenter = .F.
		Else	&& one or both is not numeric, so AutoCenter the form
			tnLeft = 0
			tnTop = 0
			llAutoCenter = .T.
		Endif
	Endif

	With Thisform
		.lblinputbox.Caption = Alltrim( tcPrompt)
		.Caption = Alltrim( tcTitle)
		.xdefaultvalue = txDefaultValue
		.xreturnvalue = .xdefaultvalue
		.txtinputbox.Value = .xdefaultvalue
		.txtinputbox.Format = Alltrim( tcFormat)
		.txtinputbox.InputMask = Alltrim( tcInputMask)
		.txtinputbox.PasswordChar = tcPasswordChar
		.Top = tnTop
		.Left = tnLeft
		.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

		Do Case
		Case Type("txDefaultValue") = "D"
			.xemptyvalue = {}
		Case Type("txDefaultValue") = "N"
			.xemptyvalue = 0
		Case Type("txDefaultValue") = "Y"
			.xemptyvalue = $0
		Otherwise
			.xemptyvalue = ""
		Endcase
	Endwith
	Endproc


	Procedure cmdok.Click
	With Thisform
		.xreturnvalue = .txtinputbox.Value
		.Release()
	Endwith
	Endproc


	Procedure cmdcancel.Click
*
*	If Cancel was chosen, return the empty value of the correct data type.
*
	With Thisform
		.xreturnvalue = .xemptyvalue
		.Release()
	Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************












Define Class lx_compr_rolos_m_vol As Container


	Width = 162
	Height = 47
	Name = "lx_compr_rolos_m_vol1"
	BorderWidth = 0
	BackStyle = 0


	Add Object tx_marca_volume As lx_textbox_base With ;
		ControlSource = "v_compras_01.marca_volumes", ;
		Height = 21, ;
		Left = 104, ;
		TabIndex = 11, ;
		Top = 26, ;
		Width = 58, ;
		Name = "tx_marca_volume"


	Add Object lx_label5 As lx_label With ;
		AutoSize = .F., ;
		Caption = "Marca Volumes", ;
		Height = 15, ;
		Left = 0, ;
		Top = 29, ;
		Width = 100, ;
		TabIndex = 46, ;
		Name = "Lx_label5"


	Add Object tx_cmprimento_rolos As lx_textbox_base With ;
		ControlSource = "v_compras_01.comprimento_de_rolos", ;
		Height = 22, ;
		InputMask = "999.9999", ;
		Left = 104, ;
		TabIndex = 10, ;
		Top = 0, ;
		Width = 58, ;
		Name = "tx_cmprimento_rolos"


	Add Object lx_label4 As lx_label With ;
		AutoSize = .F., ;
		Caption = "Comprimento", ;
		Height = 15, ;
		Left = 0, ;
		Top = 4, ;
		Width = 100, ;
		TabIndex = 45, ;
		p_muda_size = .F., ;
		Name = "Lx_label4"


	Procedure tx_marca_volume.l_desenhista_recalculo
	If v_Compras_01.Marca_Volumes > 100

		f_Msg(['Marca volumes não deve passar de 100% !', 0+48, 'Atenção'])
		Return .F.

	Endif

	Return .T.
	Endproc


	Procedure tx_cmprimento_rolos.l_desenhista_recalculo
	If v_Compras_01.Comprimento_de_Rolos > 100

		f_Msg(['O comprimento não deve passar de 100% !', 0+48, 'Atenção'])
		Return .F.

	Endif

	Return .T.
	Endproc


Enddefine




**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
Define Class rbInputBox2 As Form


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


	Add Object lbluser As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Usuário", ;
		Height = 20, ;
		Left = 6, ;
		Top = 16, ;
		Width = 190, ;
		TabIndex = 1, ;
		Name = "lblUser"


	Add Object txtUser As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 2, ;
		Top = 12, ;
		Width = 110, ;
		Name = "txtUser"
	ControlSource = "xUserSenha.Usuario"


	Add Object lblinputbox As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Enter the value", ;
		Height = 20, ;
		Left = 6, ;
		Top = 46, ;
		Width = 190, ;
		TabIndex = 3, ;
		Name = "lblInputBox"


	Add Object txtinputbox As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 4, ;
		Top = 42, ;
		Width = 110, ;
		Name = "txtInputBox"


	Add Object cmdok As CommandButton With ;
		Top = 72, ;
		Left = 84, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 5, ;
		Name = "cmdOK"


	Add Object cmdcancel As CommandButton With ;
		Top = 72, ;
		Left = 172, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		TabIndex = 6, ;
		Name = "cmdCancel"


	Procedure Unload
	With Thisform
		If Type(".xReturnValue") = "C"
			.xreturnvalue = Rtrim( .xreturnvalue)
		Endif
		pcReturnValue = .xreturnvalue
	Endwith
	Endproc


	Procedure Init
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	If Type("tcPrompt") <> "C"
		tcPrompt = "Enter the value"
	Endif
	If Type("tcTitle") <> "C"
		tcTitle = "Input Box"
	Endif
	If !( Type("txDefaultValue") $ "CDNY")
*	Valid input data types are C, D, N, and Y
		txDefaultValue = ""	&& default to character data type
	Endif
	If Type("tcFormat") <> "C"
		tcFormat = ""
	Endif
	If Type("tcInputMask") <> "C"
		tcInputMask = ""
	Endif
	If Type("tcPasswordChar") <> "C"
		tcPasswordChar = ""
	Endif
	If Len( Alltrim( tcPasswordChar)) > 1
		tcPasswordChar = Left( tcPasswordChar, 1)
	Endif
	Local llAutoCenter
	If Pcount() < 5	&& Top and Left parameters were not passed
		tnLeft = 0
		tnTop = 0
	Else	&& Top and left parameters were passed but may not be numeric
		If Type("tnTop") = "N" And Type("tnLeft") = "N"		&& both are numeric
			llAutoCenter = .F.
		Else	&& one or both is not numeric, so AutoCenter the form
			tnLeft = 0
			tnTop = 0
			llAutoCenter = .T.
		Endif
	Endif

	With Thisform
		.lblinputbox.Caption = Alltrim( tcPrompt)
		.Caption = Alltrim( tcTitle)
		.xdefaultvalue = txDefaultValue
		.xreturnvalue = .xdefaultvalue
		.txtinputbox.Value = .xdefaultvalue
		.txtinputbox.Format = Alltrim( tcFormat)
		.txtinputbox.InputMask = Alltrim( tcInputMask)
		.txtinputbox.PasswordChar = tcPasswordChar
		.Top = tnTop
		.Left = tnLeft
		.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

		Do Case
		Case Type("txDefaultValue") = "D"
			.xemptyvalue = {}
		Case Type("txDefaultValue") = "N"
			.xemptyvalue = 0
		Case Type("txDefaultValue") = "Y"
			.xemptyvalue = $0
		Otherwise
			.xemptyvalue = ""
		Endcase
	Endwith
	Endproc


	Procedure cmdok.Click
	With Thisform
	
	    IF f_vazio(.txtUser.Value)
	       MESSAGEBOX("Informe o Usuário!")
	       RETURN 
	    endif
	
		.xreturnvalue = .txtinputbox.Value

*!*			Select xUserSenha
*!*			Zap
*!*			Append Blank
		Replace usuario With Alltrim(.txtUser.Value) IN xUserSenha



		.Release()
	Endwith
	Endproc




	Procedure cmdcancel.Click
*
*	If Cancel was chosen, return the empty value of the correct data type.
*
	With Thisform
		.xreturnvalue = .xemptyvalue
		.Release()
	Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************




**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
Define Class rbMotivo As Form


	Height = 113
	Width = 318
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Motivo"
	ControlBox = .F.
	WindowType = 1
	Name = "frmMotivoAlt"

*-- empty value to return if Cancel is chosen; data type depends on data type of txValueIn
	xemptyvalue = .F.

*-- the default value (if any)
	xdefaultvalue = .F.

*-- the return value
	xreturnvalue = .F.


	Add Object lblMotivo As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "MOTIVO", ;
		Height = 20, ;
		Left = 35, ;
		Top = 6, ;
		Width = 60, ;
		TabIndex = 1, ;
		Name = "lblUser"


	Add Object cboMotivo As Combobox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 50, ;
		TabIndex = 2, ;
		Top = 22, ;
		Width = 250, ;
		style = 2,;
		Name = "cboMotivo"



	Add Object cmdok As CommandButton With ;
	   Top = 72, ;
		Left = 230, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "OK", ;
		TabIndex = 6, ;
		Name = "cmdOK"



	Procedure Unload
	With Thisform
		If Type(".xReturnValue") = "C"
			.xreturnvalue = Rtrim( .xreturnvalue)
		Endif
		pcReturnValue = .xreturnvalue
	Endwith
	Endproc


	Procedure Init
	
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	If Type("tcPrompt") <> "C"
		tcPrompt = "Enter the value"
	Endif
	If Type("tcTitle") <> "C"
		tcTitle = "Input Box"
	Endif
	If !( Type("txDefaultValue") $ "CDNY")
*	Valid input data types are C, D, N, and Y
		txDefaultValue = ""	&& default to character data type
	Endif
	If Type("tcFormat") <> "C"
		tcFormat = ""
	Endif
	If Type("tcInputMask") <> "C"
		tcInputMask = ""
	Endif
	If Type("tcPasswordChar") <> "C"
		tcPasswordChar = ""
	Endif
	If Len( Alltrim( tcPasswordChar)) > 1
		tcPasswordChar = Left( tcPasswordChar, 1)
	ENDIF
	
	Local llAutoCenter
	If Pcount() < 5	&& Top and Left parameters were not passed
		tnLeft = 0
		tnTop = 0
	Else	&& Top and left parameters were passed but may not be numeric
		If Type("tnTop") = "N" And Type("tnLeft") = "N"		&& both are numeric
			llAutoCenter = .F.
		Else	&& one or both is not numeric, so AutoCenter the form
			tnLeft = 0
			tnTop = 0
			llAutoCenter = .T.
		Endif
	Endif

	With Thisform
*!*		
*!*			.lblinputbox.Caption = Alltrim( tcPrompt)
			.Caption = "Motivo da Alteração de Entrega"
*!*			.xdefaultvalue = txDefaultValue
*!*			.xreturnvalue = .xdefaultvalue
*!*			.txtinputbox.Value = .xdefaultvalue
*!*			.txtinputbox.Format = Alltrim( tcFormat)
*!*			.txtinputbox.InputMask = Alltrim( tcInputMask)
*!*			.txtinputbox.PasswordChar = tcPasswordChar

	    .cbomotivo.rowsourcetype  = 1
		.cbomotivo.rowsource = "Alteração compras,Alteração Fornecedor"
		.cbomotivo.requery()
		
		.Top = tnTop
		.Left = tnLeft
		.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

		Do Case
		Case Type("txDefaultValue") = "D"
			.xemptyvalue = {}
		Case Type("txDefaultValue") = "N"
			.xemptyvalue = 0
		Case Type("txDefaultValue") = "Y"
			.xemptyvalue = $0
		Otherwise
			.xemptyvalue = ""
		ENDCASE
		
		
	Endwith
	Endproc


	Procedure cmdok.Click
	With Thisform
	
	    IF f_vazio(.cboMotivo.Value)
	       MESSAGEBOX("Informe o MOTIVO!")
	       RETURN 
	    endif
	
		
		
		xmot = .cboMotivo.Value
		
		Replace motivo With Alltrim(xmot) IN xUserSenha

*!*			

*!*			f_insert("insert into CAEDU_COMPRAS_ENTREGA_LOG (PEDIDO, DATA_ALTERACAO_ENTREGA, DATA_ENTREGA, DATA_ENTREGA_NOVA, MOTIVO, USUARIO ) "+;
*!*				" values (?V_COMPRAS_01.PEDIDO, getdate(), ?x_entreg_atu.entrega , ?v_compras_01_produtos.entrega, ?xmot, ?wusuario )")
			
		=REQUERY('V_CAEDU_LOG_ENTRADA')
		
		thisform.Visible = .f.


		.Release()
		
	Endwith
	Endproc






Enddefine
*
*-- EndDefine: btn_exp
**************************************************







