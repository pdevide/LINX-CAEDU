

**********************************************************
*        Ultimas alterações no Grupo Palma               *
**********************************************************
* Data :  27/05/2014
* Autor:  Sandra Ono
*              a) Inclusão Automatica de Tabelas com preço  Default
*              b) Validar se campo dá mensagem de Campo Inativo
*              c) Alteração para corrigir erro da linx para não alterar o preço liquido dos produtos


***  03/08/2013: Paulo Devide 
*!*					** VALIDAÇÃO DA PROPRIEDADE DATA_ATIVACAO (00027)
*!*				llOk=zvalida_prop_data_ativacao() &&PAULO DEVIDE - 03-09-2013
***         Verifica se a Data informada na propriedade DATA_ATIVACAO é válida!"



* 24-05-2013: Paulo Devide
*!*					** PAULO DEVIDE -> 24-05-2013
*!*					llOk=zvalida_campos_produto()
** 1) valida campo Categoria "Campo [Categoria] é obrigatório..."
** 2) valida campo Subcategoria "Campo [Subcategoria] é obrigatório..."
** 3) valida tabela de preços preeenchida (campo Preco1)


*!*	* 20/05/2014: Sandra Ono   
*!*	* Validação se o Produto esta devidamente cadastrado na Tabela NCM  (obrigação para calculo de imposto nas lojas)




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

				*thisformset.lx_form1.addobject('bt_copia', 'bt_estfilial')
				thisformset.lx_FORM1.lx_pageframe1.page5.addobject('bt_copia', 'bt_estfilial')
				thisformset.lx_FORM1.lx_pageframe1.page5.addobject('bt_copia2', 'btdefprice')  && Sandra Ono - 27/05/2014 
				

	case UPPER(xmetodo) == 'USR_SEARCH_AFTER'
	
*!*		      
*!*			Text TO  thisformset.dataenvironment.Cursorv_produtos_tamanho_00.SelectCmd TextMerge NoShow
*!*			SELECT PRODUTOS_TAMANHOS.GRADE, PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, PRODUTOS_TAMANHOS.QUEBRA_1, PRODUTOS_TAMANHOS.QUEBRA_2, PRODUTOS_TAMANHOS.QUEBRA_3, PRODUTOS_TAMANHOS.QUEBRA_4,
*!*			 PRODUTOS_TAMANHOS.QUEBRA_5, PRODUTOS_TAMANHOS.TAMANHO_1, PRODUTOS_TAMANHOS.TAMANHO_2, PRODUTOS_TAMANHOS.TAMANHO_3, PRODUTOS_TAMANHOS.TAMANHO_4, PRODUTOS_TAMANHOS.TAMANHO_5, PRODUTOS_TAMANHOS.TAMANHO_6, PRODUTOS_TAMANHOS.TAMANHO_7,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_8, PRODUTOS_TAMANHOS.TAMANHO_9, PRODUTOS_TAMANHOS.TAMANHO_10, PRODUTOS_TAMANHOS.TAMANHO_11, PRODUTOS_TAMANHOS.TAMANHO_12, PRODUTOS_TAMANHOS.TAMANHO_13, PRODUTOS_TAMANHOS.TAMANHO_14, PRODUTOS_TAMANHOS.TAMANHO_15,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_16, PRODUTOS_TAMANHOS.TAMANHO_17, PRODUTOS_TAMANHOS.TAMANHO_18, PRODUTOS_TAMANHOS.TAMANHO_19, PRODUTOS_TAMANHOS.TAMANHO_20, PRODUTOS_TAMANHOS.TAMANHO_21, PRODUTOS_TAMANHOS.TAMANHO_22, PRODUTOS_TAMANHOS.TAMANHO_23,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_24, PRODUTOS_TAMANHOS.TAMANHO_25, PRODUTOS_TAMANHOS.TAMANHO_26, PRODUTOS_TAMANHOS.TAMANHO_27, PRODUTOS_TAMANHOS.TAMANHO_28, PRODUTOS_TAMANHOS.TAMANHO_29, PRODUTOS_TAMANHOS.TAMANHO_30, PRODUTOS_TAMANHOS.TAMANHO_31,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_32, PRODUTOS_TAMANHOS.TAMANHO_33, PRODUTOS_TAMANHOS.TAMANHO_34, PRODUTOS_TAMANHOS.TAMANHO_35, PRODUTOS_TAMANHOS.TAMANHO_36, PRODUTOS_TAMANHOS.TAMANHO_37, PRODUTOS_TAMANHOS.TAMANHO_38, PRODUTOS_TAMANHOS.TAMANHO_39,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_40, PRODUTOS_TAMANHOS.TAMANHO_41, PRODUTOS_TAMANHOS.TAMANHO_42, PRODUTOS_TAMANHOS.TAMANHO_43, PRODUTOS_TAMANHOS.TAMANHO_44, PRODUTOS_TAMANHOS.TAMANHO_45, PRODUTOS_TAMANHOS.TAMANHO_46, PRODUTOS_TAMANHOS.TAMANHO_47,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_48, PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA,
*!*			 PRODUTOS_TAMANHOS.GRADE_BASE FROM PRODUTOS_TAMANHOS 
*!*			EndText			
*!*			
*!*		    thisformset.dataenvironment.Cursorv_produtos_tamanho_00.Query()
								
				
	Case Upper(xmetodo) == 'USR_INCLUDE_BEFORE'
	
*!*			
*!*			Text TO  thisformset.dataenvironment.Cursorv_produtos_tamanho_00.SelectCmd TextMerge NoShow
*!*			SELECT PRODUTOS_TAMANHOS.GRADE, PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, PRODUTOS_TAMANHOS.QUEBRA_1, PRODUTOS_TAMANHOS.QUEBRA_2, PRODUTOS_TAMANHOS.QUEBRA_3, PRODUTOS_TAMANHOS.QUEBRA_4,
*!*			 PRODUTOS_TAMANHOS.QUEBRA_5, PRODUTOS_TAMANHOS.TAMANHO_1, PRODUTOS_TAMANHOS.TAMANHO_2, PRODUTOS_TAMANHOS.TAMANHO_3, PRODUTOS_TAMANHOS.TAMANHO_4, PRODUTOS_TAMANHOS.TAMANHO_5, PRODUTOS_TAMANHOS.TAMANHO_6, PRODUTOS_TAMANHOS.TAMANHO_7,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_8, PRODUTOS_TAMANHOS.TAMANHO_9, PRODUTOS_TAMANHOS.TAMANHO_10, PRODUTOS_TAMANHOS.TAMANHO_11, PRODUTOS_TAMANHOS.TAMANHO_12, PRODUTOS_TAMANHOS.TAMANHO_13, PRODUTOS_TAMANHOS.TAMANHO_14, PRODUTOS_TAMANHOS.TAMANHO_15,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_16, PRODUTOS_TAMANHOS.TAMANHO_17, PRODUTOS_TAMANHOS.TAMANHO_18, PRODUTOS_TAMANHOS.TAMANHO_19, PRODUTOS_TAMANHOS.TAMANHO_20, PRODUTOS_TAMANHOS.TAMANHO_21, PRODUTOS_TAMANHOS.TAMANHO_22, PRODUTOS_TAMANHOS.TAMANHO_23,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_24, PRODUTOS_TAMANHOS.TAMANHO_25, PRODUTOS_TAMANHOS.TAMANHO_26, PRODUTOS_TAMANHOS.TAMANHO_27, PRODUTOS_TAMANHOS.TAMANHO_28, PRODUTOS_TAMANHOS.TAMANHO_29, PRODUTOS_TAMANHOS.TAMANHO_30, PRODUTOS_TAMANHOS.TAMANHO_31,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_32, PRODUTOS_TAMANHOS.TAMANHO_33, PRODUTOS_TAMANHOS.TAMANHO_34, PRODUTOS_TAMANHOS.TAMANHO_35, PRODUTOS_TAMANHOS.TAMANHO_36, PRODUTOS_TAMANHOS.TAMANHO_37, PRODUTOS_TAMANHOS.TAMANHO_38, PRODUTOS_TAMANHOS.TAMANHO_39,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_40, PRODUTOS_TAMANHOS.TAMANHO_41, PRODUTOS_TAMANHOS.TAMANHO_42, PRODUTOS_TAMANHOS.TAMANHO_43, PRODUTOS_TAMANHOS.TAMANHO_44, PRODUTOS_TAMANHOS.TAMANHO_45, PRODUTOS_TAMANHOS.TAMANHO_46, PRODUTOS_TAMANHOS.TAMANHO_47,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_48, PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA,
*!*			 PRODUTOS_TAMANHOS.GRADE_BASE FROM PRODUTOS_TAMANHOS 
*!*			EndText			
*!*			
*!*		    thisformset.dataenvironment.Cursorv_produtos_tamanho_00.Query()
*!*						


			case UPPER(xmetodo) == 'USR_ALTER_AFTER'


				IF ThisFormSet.p_Tool_Status == 'A'

					WAIT WINDOW 'ALTERACAO, '

					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia2.enabled = .f.
					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia2.visible = .f.


					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia.enabled = .t.
					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia.visible = .t.
					
					SELECT SUM(preco1) as tot FROM V_PRODUTOS_00_PRECOS INTO CURSOR xvalida

					IF xvalida.tot > 0
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .t.
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.p_tool_grid.Visible = .f.
					ELSE
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
					endif


				ENDIF
				
			case UPPER(xmetodo) == 'USR_ALTER_BEFORE'
				xlibera = 0
				
*!*				
*!*					Text TO  thisformset.dataenvironment.Cursorv_produtos_tamanho_00.SelectCmd TextMerge NoShow
*!*					SELECT PRODUTOS_TAMANHOS.GRADE, PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, PRODUTOS_TAMANHOS.QUEBRA_1, PRODUTOS_TAMANHOS.QUEBRA_2, PRODUTOS_TAMANHOS.QUEBRA_3, PRODUTOS_TAMANHOS.QUEBRA_4,
*!*					 PRODUTOS_TAMANHOS.QUEBRA_5, PRODUTOS_TAMANHOS.TAMANHO_1, PRODUTOS_TAMANHOS.TAMANHO_2, PRODUTOS_TAMANHOS.TAMANHO_3, PRODUTOS_TAMANHOS.TAMANHO_4, PRODUTOS_TAMANHOS.TAMANHO_5, PRODUTOS_TAMANHOS.TAMANHO_6, PRODUTOS_TAMANHOS.TAMANHO_7,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_8, PRODUTOS_TAMANHOS.TAMANHO_9, PRODUTOS_TAMANHOS.TAMANHO_10, PRODUTOS_TAMANHOS.TAMANHO_11, PRODUTOS_TAMANHOS.TAMANHO_12, PRODUTOS_TAMANHOS.TAMANHO_13, PRODUTOS_TAMANHOS.TAMANHO_14, PRODUTOS_TAMANHOS.TAMANHO_15,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_16, PRODUTOS_TAMANHOS.TAMANHO_17, PRODUTOS_TAMANHOS.TAMANHO_18, PRODUTOS_TAMANHOS.TAMANHO_19, PRODUTOS_TAMANHOS.TAMANHO_20, PRODUTOS_TAMANHOS.TAMANHO_21, PRODUTOS_TAMANHOS.TAMANHO_22, PRODUTOS_TAMANHOS.TAMANHO_23,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_24, PRODUTOS_TAMANHOS.TAMANHO_25, PRODUTOS_TAMANHOS.TAMANHO_26, PRODUTOS_TAMANHOS.TAMANHO_27, PRODUTOS_TAMANHOS.TAMANHO_28, PRODUTOS_TAMANHOS.TAMANHO_29, PRODUTOS_TAMANHOS.TAMANHO_30, PRODUTOS_TAMANHOS.TAMANHO_31,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_32, PRODUTOS_TAMANHOS.TAMANHO_33, PRODUTOS_TAMANHOS.TAMANHO_34, PRODUTOS_TAMANHOS.TAMANHO_35, PRODUTOS_TAMANHOS.TAMANHO_36, PRODUTOS_TAMANHOS.TAMANHO_37, PRODUTOS_TAMANHOS.TAMANHO_38, PRODUTOS_TAMANHOS.TAMANHO_39,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_40, PRODUTOS_TAMANHOS.TAMANHO_41, PRODUTOS_TAMANHOS.TAMANHO_42, PRODUTOS_TAMANHOS.TAMANHO_43, PRODUTOS_TAMANHOS.TAMANHO_44, PRODUTOS_TAMANHOS.TAMANHO_45, PRODUTOS_TAMANHOS.TAMANHO_46, PRODUTOS_TAMANHOS.TAMANHO_47,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_48, PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA,
*!*					 PRODUTOS_TAMANHOS.GRADE_BASE FROM PRODUTOS_TAMANHOS 
*!*					EndText			
*!*					
*!*				    thisformset.dataenvironment.Cursorv_produtos_tamanho_00.Query()				
				
				
			Case Upper(xmetodo) == 'USR_INCLUDE_AFTER'
	
	
				IF ThisFormSet.p_Tool_Status == 'I'
				
				

					*****WAIT WINDOW 'inclusão de botão com preço default'
					*** Sandra Ono - 27/05/2014 ****

					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia2.enabled = .t.
					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia2.visible = .t.
					
					SELECT SUM(preco1) as tot FROM V_PRODUTOS_00_PRECOS INTO CURSOR xvalida

					IF xvalida.tot > 0
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .t.
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.p_tool_grid.Visible = .f.
					ELSE
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
					endif



				ENDIF	


	   		case UPPER(xmetodo) == 'USR_VALID'			
			
			
				*** Sandra Ono - 27/05/2014 ****
				**** Alteração para corrigir erro da linx para não alterar 
				**** o preço liquido dos produtos
				 
				IF 'TX_PRECO1'$UPPER(xnome_obj)
		    		IF  INLIST(ThisFormSet.p_tool_status,'I','A')
		    		
   	     	    		replace 	preco_liquido1 with 0, ;
	 					preco_liquido2 with 0, ;
						preco_liquido3 with 0, ;
						preco_liquido4 with 0  IN V_PRODUTOS_00_PRECOS

		    		
				    		
		    		ENDIF
				ENDIF    		
				

				

										

			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

				** VALIDAÇÃO DA PROPRIEDADE DATA_ATIVACAO (00027)
				IF USED("CURPROPPRODUTOS")
					llOk=zvalida_prop_data_ativacao() &&PAULO DEVIDE - 03-09-2013
					IF NOT llOk
						RETURN .f.
					ENDIF
				Endif	
				
				** PAULO DEVIDE -> 24-05-2013
				llOk=zvalida_campos_produto()
				IF NOT llOk
					RETURN .f.
				ENDIF
				** FIMI: 24-05-2013		
					

				** Sandra Ono -> 24-05-2013   	
				 lc_NCM = ALLTRIM(V_PRODUTOS_00.CLASSIF_FISCAL)    
				   	
				 lc_sql =  " Select NCM_NBS from TMP_TABELA_ALIQUOTA_IMPOSTO_ITEM  ALIQ where NCM_NBS =  ?lc_NCM"
					
				 IF USED("tmp_NCM")
					  USE IN tmp_NCM
				 ENDIF

				 f_select(lc_sql,"tmp_NCM")			   	
				   	
				 IF RECCOUNT("tmp_NCM") = 0
				   	
				   	   =MESSAGEBOX("O NCM (Classificação Fiscal) não foi encontrado na tabela Aliquota de Impostos das lojas. Verifique ! ",16,"Atenção")
				   	   
				   	   RETURN .F.
				 ENDIF
				   	
				
				
			otherwise
				return .t.
		endcase
	endproc
enddefine


DEFINE CLASS btdefprice as botao
	caption = 'Definir Preço Default'
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


	
		thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
		
		IF ThisFormSet.p_Tool_Status == 'I'

			inppass3 = rbInputBox3( "Valor Default", "Preço Default para Tabelas", "", , , "!", , "")
			inppass3 = ALLTRIM(inppass3 )
			
		Endif	
		

	ENDPROC
	
ENDDEFINE		
		



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
	
	SET STEP ON 
	
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
		
		IF ThisFormSet.p_Tool_Status == 'I'

			inppass3 = rbInputBox3( "Valor Default", "Preço Default para Tabelas", "", , , "!", , "")
			inppass3 = ALLTRIM(inppass3 )
			
		Endif	
		
		
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
	
	IF !USED("CURPROPPRODUTOS")
		select (zold_area)
		return llRet && não obrigatório
	Endif
	
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
		IF NOT INLIST(ALLTRIM(v_produtos_00_precos.codigo_tab_preco),'02','05','37','CM')
		
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
	


 	IF  INLIST(o_002006.p_tool_status,'I')
  	
	    		
		IF	o_002006.lx_Form1.lx_PageFrame1.Page3.opt_Padrao.Value  !=  o_002006.pp_tipo_codigo_barra       
		    	lcMsg = lcMsg + CHR(13) + "O Código de Barras deve ser o padrão [OPÇÃO: "+ALLTRIM(PADR(INT(o_002006.pp_tipo_codigo_barra),2,' ' ))+"]"
	    ENDIF
	    
		    		
	endif			    		


	
	 		
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



*******************************	
*  Sandra Ono  -  27/05/2014
*******************************
FUNCTION rbInputBox3
	lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	private pcReturnValue
	pcReturnValue = txDefaultValue
	local oInputBox
	oInputBox = CreateObject("rbInputBox3", tcPrompt, tcTitle, ;
		txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar)
	oInputBox.Show()
	RETURN pcReturnValue


	**************************************************
	*-- Class:        rbinputbox3
	*-- ParentClass:  form
	*-- BaseClass:    form
	*-- Time Stamp:   01/29/03 01:03:14 PM
	*   Sandra Ono  -  27/05/2014
	*
	**************************************************
	
DEFINE CLASS rbinputbox3 AS form


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
		value = 000000.00


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
					.xEmptyValue = 0.00
				case type("txDefaultValue") = "Y"
					.xEmptyValue = $0
				otherwise
					.xEmptyValue = ""
			endcase
		endwith
	ENDPROC


	PROCEDURE cmdok.Click
		with thisform
	SET STEP ON 	
			.xReturnValue = .txtInputBox.value
			
*!*				TEXT TO lc_sql noshow
*!*					select distinct tab.CODIGO_TAB_PRECO, tab.tabela
*!*						from
*!*							TABELAS_PRECO tab
*!*						where tab.INATIVO  = 0
*!*					ORDER BY 1			
*!*	            ENDTEXT
*!*	             
*!*	            f_select(lc_sql,"x_tabPreco" ) 
*!*				
			
			
			TEXT TO lc_sql noshow
				select distinct tab.CODIGO_TAB_PRECO, tab.tabela,  prd.PRODUTO, prd.PRECO1, prd.PRECO2,prd.PRECO3,prd.PRECO4, prd.ULT_ATUALIZACAO
					from
						PRODUTOS_PRECOS prd 
				     LEFT JOIN TABELAS_PRECO tab
				         ON PRD.CODIGO_TAB_PRECO = TAB.CODIGO_TAB_PRECO 
							where prd.PRODUTO in
							 ( select top 1 PRODUTO from PRODUTOS where DATA_CADASTRAMENTO  >= DATEADD(DAY,-1, GETDATE() ) )
							and tab.INATIVO  = 0
				ORDER BY 1			
            ENDTEXT
             
            f_select(lc_sql,"Preco_x" ) 
           
           IF RECCOUNT('Preco_x') < 1
					TEXT TO lc_sql noshow
						select distinct tab.CODIGO_TAB_PRECO, tab.tabela,  prd.PRODUTO, prd.PRECO1, prd.PRECO2,prd.PRECO3,prd.PRECO4, prd.ULT_ATUALIZACAO
							from
								PRODUTOS_PRECOS prd 
						     LEFT JOIN TABELAS_PRECO tab
						         ON PRD.CODIGO_TAB_PRECO = TAB.CODIGO_TAB_PRECO 
									where prd.PRODUTO = '51020859'
									and tab.INATIVO  = 0
						ORDER BY 1			
		            ENDTEXT
		             
		            f_select(lc_sql,"Preco_x" )            
           
           
           
           ENDIF
           
            
                     
            lnValor = VAL(.xReturnValue) 
            
            
            
            SELECT Preco_x
            SCAN
            
                 IF !INLIST(Preco_x.codigo_tab_preco,"00","02","37" ,"CM")
                 
                    SELECT V_PRODUTOS_00_PRECOS
                    LOCATE FOR ALLTRIM(produto) = ALLTRIM(V_PRODUTOS_00.PRODUTO) and;
                              ALLTRIM(CODIGO_TAB_PRECO) = ALLTRIM(Preco_x.codigo_tab_preco)
                    
                    IF !FOUND()
                    
			            insert into V_PRODUTOS_00_PRECOS( CODIGO_TAB_PRECO, TABELA, PRODUTO, PRECO1, PRECO2,PRECO3,PRECO4, ULT_ATUALIZACAO, STATUS, INATIVO )  values;
			            (Preco_x.CODIGO_TAB_PRECO, Preco_x.TABELA, V_PRODUTOS_00.PRODUTO, lnValor ,0,0,0, DATETIME(), 'A', .F.)
			            
*!*				            SELECT x_tabPreco
*!*				            LOCATE FOR ALLTRIM(CODIGO_TAB_PRECO) =  ALLTRIM(Preco_x.CODIGO_TAB_PRECO)
*!*				            IF FOUND()
*!*				               replace tabela WITH x_tabPreco.tabela in V_PRODUTOS_00_PRECOS
*!*				            ENDIF
			            
			            
			            
		            ENDIF
		            
		         ELSE
		         
                    SELECT V_PRODUTOS_00_PRECOS
                    LOCATE FOR ALLTRIM(produto) = ALLTRIM(V_PRODUTOS_00.PRODUTO) and;
                              ALLTRIM(CODIGO_TAB_PRECO) = ALLTRIM(Preco_x.codigo_tab_preco)
                    
                    IF !FOUND()
			            insert into V_PRODUTOS_00_PRECOS( CODIGO_TAB_PRECO, TABELA, PRODUTO, PRECO1, PRECO2,PRECO3,PRECO4, ULT_ATUALIZACAO, STATUS, INATIVO )  values;
			            (Preco_x.CODIGO_TAB_PRECO, Preco_x.TABELA, V_PRODUTOS_00.PRODUTO, 0.00 ,0,0,0, DATETIME(), 'A', .F.)
		            ENDIF
		         	
		            
		         Endif   
		         
		         SELECT Preco_x
            Endscan          
									
			SELECT V_PRODUTOS_00_PRECOS 
			****replace ALL preco1 WITH VAL(.xReturnValue) FOR !INLIST(codigo_tab_preco,"00","02","37" ,"CM","05")
			GO TOP
			
			o_002006.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.REFRESH()
			
			
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










