
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

*SET STEP ON

		do case
			case UPPER(xmetodo) == 'USR_INIT'



			case UPPER(xmetodo) == 'USR_ALTER_AFTER'


*!*					IF ThisFormSet.p_Tool_Status == 'A'

*!*						WAIT WINDOW 'ALTERACAO, '



*!*						thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia.enabled = .t.
*!*						thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia.visible = .t.
*!*						SELECT SUM(preco1) as tot FROM V_PRODUTOS_00_PRECOS INTO CURSOR xvalida

*!*						IF xvalida.tot > 0
*!*							thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .t.
*!*							thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.p_tool_grid.Visible = .f.
*!*						ELSE
*!*							thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
*!*						endif


*!*					ENDIF
			case UPPER(xmetodo) == 'USR_ALTER_BEFORE'
*!*					xlibera = 0

			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

*!*					** VALIDAÇÃO DA PROPRIEDADE DATA_ATIVACAO (00027)
*!*					llOk=zvalida_prop_data_ativacao() &&PAULO DEVIDE - 03-09-2013
*!*					IF NOT llOk
*!*						RETURN .f.
*!*					ENDIF
				
				** PAULO DEVIDE -> 24-05-2013
*!*					llOk=zvalida_campos_produto()
*!*					IF NOT llOk
*!*						RETURN .f.
*!*					ENDIF
				** FIMI: 24-05-2013			

				** Sandra Ono -> 24-05-2013   	
*!*					 lc_NCM = ALLTRIM(V_PRODUTOS_00.CLASSIF_FISCAL)    
*!*					   	
*!*					 lc_sql =  " Select NCM_NBS from TMP_TABELA_ALIQUOTA_IMPOSTO_ITEM  ALIQ where NCM_NBS =  ?lc_NCM"
*!*						
*!*					 IF USED("tmp_NCM")
*!*						  USE IN tmp_NCM
*!*					 ENDIF

*!*					 f_select(lc_sql,"tmp_NCM")			   	
*!*					   	
*!*					 IF RECCOUNT("tmp_NCM") = 0
*!*					   	
*!*					   	   =MESSAGEBOX("O NCM (Classificação Fiscal) não foi encontrado na tabela Aliquota de Impostos das lojas. Verifique ! ",16,"Atenção")
*!*					   	   
*!*					   	   RETURN .F.
*!*					 ENDIF
				   	
			CASE UPPER(xmetodo) == 'USR_SAVE_AFTER'
				
				lcmsg = "Operação = " + ThisFormSet.p_Tool_Status+ CHR(13) + "Codigo : " + curtabela_propriedade.codigo + CHR(13) +;
							"Descrição: " + curtabela_propriedade.descricao 


				MESSAGEBOX(lcmsg,64,"Aviso")	
				
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

*!*			LOCAL inppass
*!*			*	Password (masked)
*!*			inppass = rbInputBox( "Digite a Senha", "Senha para alteração de Pedido de Compra", "", , , "!", , "*")
*!*			inppass = ALLTRIM(UPPER(inppass ))


*!*			f_select("Select valor_atual from parametros where parametro = 'CAE_SENHA_COMPRAS' ","LISTAUT"	)

*!*			SELECT LISTAUT
*!*			CAEWHERE = LISTAUT.VALOR_ATUAL
*!*			xaut = 0

*!*			IF INLIST(inppass  , &CAEWHERE  )
*!*				xaut = xaut  +1
*!*			endif



*!*			IF xaut > 0
*!*				thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
*!*				thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.p_tool_grid.Visible = .T.
*!*				xlibera = 1
*!*				RETURN .t.
*!*			ELSE
*!*				MESSAGEBOX("Senha incorreta ou não autorizada")
*!*				RETURN .f.
*!*			endif
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
		RETURN .t.
	ELSE
		MESSAGEBOX("Senha incorreta ou não autorizada")
		RETURN .f.
	endif	

	ENDPROC
ENDDEFINE

FUNCTION zvalida_prop_data_ativacao
	LOCAL llRet as Boolean, lcMsg as String
	LOCAL zold_area as Integer, zdd as Date, zddano_ant as Integer, zddano_pos as Integer

	zold_area=select()

	llRet = .t.
	lcMsg = ""
	
	select CURPROPPRODUTOS
	locate for propriedade='00027'

	if !found() 
		select (zold_area)
		return llRet && não obrigatório
	endif

	if empty(CURPROPPRODUTOS.valor_propriedade)
		select (zold_area)
		return llRet && não obrigatório
	endif

	zdd=CAST(CURPROPPRODUTOS.valor_propriedade as Date)
	zddano_ant = YEAR(DATE())-1
	zddano_pos = YEAR(DATE())+1


	IF EMPTY(zdd)

		select (zold_area)
		llRet = .f.
	ELSE
		IF !BETWEEN(YEAR(zdd),zddano_ant,zddano_pos)

			select (zold_area)
			llRet = .f.

		ENDIF
	ENDIF

	IF !llRet
		lcMsg = "Data informada na propriedade DATA_ATIVACAO é inválida!"
		MESSAGEBOX(lcMsg, 16,"Aviso")	
		RETURN llRet
	ENDIF

	RETURN llRet && .t.	
	
ENDFUNC


** PAULO DEVIDE -> 24-05-2013
FUNCTION zvalida_campos_produto
	LOCAL llRet as Boolean, lcMsg as String, lcTabelas as String

	LOCAL lnOldSelect as Integer
	lnOldSelect = SELECT()
	
	llRet = .t.
	lcMsg = ""
	lcTabelas = ""
	
	** 1) valida campo Categoria
	IF EMPTY(NVL(v_produtos_00.cod_categoria,''))
		llRet = .f.
		lcMsg = lcMsg + "Campo [Categoria] é obrigatório..."
	ENDIF
	
	** 2) valida campo Subcategoria
	IF EMPTY(NVL(v_produtos_00.cod_subcategoria,''))
		llRet = .f.
		lcMsg = lcMsg + CHR(13) + "Campo [Subcategoria] é obrigatório..."
	ENDIF

	** 3) valida tabela de preços preeenchida (campo Preco1)
	SELECT v_produtos_00_precos
	SCAN 	
		IF NOT INLIST(ALLTRIM(v_produtos_00_precos.codigo_tab_preco),'CM','02','05','37')
		
			IF EMPTY(NVL(v_produtos_00_precos.Preco1,0))
				lcTabelas = lcTabelas + ALLTRIM(v_produtos_00_precos.codigo_tab_preco) +","			
			ENDIF
			
		ENDIF
		
	ENDSCAN
	GO top

	IF NOT EMPTY(lcTabelas)
		lcTabelas = LEFT(lcTabelas,LEN(lcTabelas)-1)
		lcMsg = lcMsg + CHR(13) + "Obrigatório informar preço nas tabela(s) "+lcTabelas+"..."
	ENDIF
	 		
	SELECT (lnOldSelect)
	
	IF NOT EMPTY(lcMsg)
		MESSAGEBOX(lcMsg, 16,"Aviso")
	ENDIF
		
	RETURN llRet
ENDFUNC
** FIM: 24-05-2013


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
