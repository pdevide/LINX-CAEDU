
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
******************** Calcula o Desconto  *****************

*- Definindo a classe do objeto de entrada que sera criado na Form.
Define Class obj_entrada As Custom
	*- Nome do metodo/fun��o que os objetos linx v�o chamar.
	Procedure metodo_usuario
		Lparam xmetodo, xobjeto, xnome_obj
	
		Do Case
		
			case upper(xmetodo) == 'USR_INIT'
			
				CREATE CURSOR xCalcula_Icms;
				(Valor_Prod Numeric(18,2),;
				Valor_ICMS Numeric(18,2),;
				Aliquota Numeric(18,2),;
				Desconto Numeric(18,2);
				)

				IF thisformset.pp_NF_REMESSA_GPO_AUTOMATICA = .t.
					
					*** Adiciona bot�o para emiss�o de nfe de contigencia da GPO Logistica
					IF "GPO" $ SET( "ClassLib" )
						** Ok, Registry carregado
					ELSE
						SET CLASSLIB TO GPO.vcx ADDITIVE
					ENDIF		
					
					TRY 

						thisformset.lx_FORM1.Lx_pageframe1.Page1.Pageframe1.Page1.addobject('btn_nfe_gpo1', 'btn_nfe_gpo')				
						WITH thisformset.lx_FORM1.Lx_pageframe1.Page1.Pageframe1.Page1.btn_nfe_gpo1				
							.visible=.t.
							.top = 290
							.left = 5
						ENDWITH
									
					CATCH
						** objeto ja inserido
					ENDTRY
					
				ELSE

					WAIT WINDOW "Par�metro NF_REMESSA_GPO_AUTOMATICA est� desligado!" TIMEOUT 1

				ENDIF
				
			
     		case upper(xmetodo) == 'USR_INCLUDE_AFTER'     		  				
     		
     		
     		    IF USED("xCalcula_Icms")
     		    
     		       SELECT xCalcula_Icms
     		       ZAP
     		       
     		    Endif
     		 
			**** case upper(xmetodo) = 'USR_INCLUDE_AFTER'
			

		     	 **IF INLIST(ALLTRIM(v_Entradas_00.NATUREZA),'200.01')
*!*			     	 IF MESSAGEBOX("Entrada referente � 'Compra de Produto Acabado' ?",32+4+256,"Confirma") = 6
*!*			     	 

*!*							SELECT xCalcula_Icms
*!*							ZAP
*!*							APPEND BLANK
*!*							inppass = rbInputBox3( " ", "Calculo de Desconto do ICMS", "", , , "!", , "*")		
*!*							
*!*								
*!*					 Endif				     	
							
			      **ENDIF   
			      
			      			     	
*!*		 			Case Upper(xmetodo) == 'USR_SAVE_BEFORE'
*!*		 			
*!*		 			
*!*		 			      SELECT v_Entradas_00_Imposto_Total
*!*		 			      LOCATE FOR 'ICMS'$UPPER(imposto) 
*!*		 			      
*!*		 			      SET STEP ON 
*!*		 			      
*!*		 			      IF FOUND()  and;
*!*	      	 			      (v_Entradas_00_Imposto_Total.Valor_Imposto_Calc > 0)
*!*		 			      
*!*		 			            ln_imposto = v_Entradas_00_Imposto_Total.Valor_Imposto_Calc
*!*		 			            ln_aliquota =  (ln_imposto/THISFORMSET.PX_SUB_TOTAL)*100
*!*		 			            	 			            	 			            
*!*					    		ln_Desconto = ROUND(THISFORMSET.PX_SUB_TOTAL*(( 12 -  (ln_imposto/THISFORMSET.PX_SUB_TOTAL)*100) )/100,2)
*!*					    						    		
*!*					    		
*!*								IF !BETWEEN(v_entradas_00.Desconto, ln_Desconto - 0.10, ln_Desconto + 0.10) 		    		
*!*								
*!*								   MESSAGEBOX("O valor de Desconto [ICMS Calculado] ("+ ALLTRIM(TRANSFORM(ln_Desconto,'9 999 999.99'))+ ") � diferente do desconto informado na tela ("+;
*!*								   ALLTRIM(TRANSFORM(v_entradas_00.Desconto,'9 999 999.99'))+"). " +CHR(13) +;
*!*								   "Imposs�vel Salvar os Dados!",16,"Aten��o")
*!*								   
*!*								   RETURN .F.
*!*								   
*!*					    		ENDIF
*!*					    		
*!*			 			  Endif     


	 			Case Upper(xmetodo) == 'USR_SAVE_AFTER'
	 			
	 			
						  TEXT TO lcsql noshow
												INSERT INTO Palma_Entradas_Desconto_ICMS_log
													(id,
													USUARIO,
													DATA_ALTERACAO,
													NOME_CLIFOR,
													NF_ENTRADA,
													SERIE_NF_ENTRADA,
													Valor_Prod,
													Valor_ICMS,
													Aliquota,
													Desconto)
												VALUES
														((select MAX(id)+1 from trigger_portal),
														  ?wusuario, 
														  getdate(),
														  			  
													  	    ?v_Entradas_00.NOME_CLIFOR,
														    ?v_Entradas_00.NF_ENTRADA,
															?v_Entradas_00.SERIE_NF_ENTRADA,
														  			  							  			  
															?xCalcula_Icms.Valor_Prod,
															?xCalcula_Icms.Valor_ICMS,
															?xCalcula_Icms.Aliquota,
															?xCalcula_Icms.Desconto)
							ENDTEXT
							F_INSERT(lcsql)	
							
							*** PAULO DEVIDE - ABR/14 == OPERADOR LOGISTICO ==
							IF thisformset.pp_NF_REMESSA_GPO_AUTOMATICA = .t.
								IF ThisFormSet.p_Tool_Status = "I" && opera��o de inclus�o de NOTA de Entrada de PA

									*** Chama rotina para OPERADOR LOGISTICO
									IF INLIST(UPPER(ALLTRIM(v_entradas_00.filial)),"CD ARAQUARI","CD IMPORTACAO","CD REGIS")
										***cria_nf_remessa()
										** Verifica se a classe de objetos esta carregada em mem�ria
										**SET STEP ON
										
										IF "GPO" $ SET( "ClassLib" )
											** Ok, Registry carregado
										ELSE
											SET CLASSLIB TO GPO.vcx ADDITIVE
										ENDIF							
												
										objGPO = CREATEOBJECT("FUNCOES_GPO")
										objGPO.filial = v_entradas_00.filial
										objGPO.serie_nf_saida = "1"
										objGPO.operador_logistico = "GPO LOGISTICA"
										objGPO.nf_saida = F_SEQUENCIAIS_ESPECIAL("faturamento_sequenciais", "sequencial", "filial = ?v_entradas_00.filial and serie_nf = '1'", .T.) 

										objGPO.cria_nf_remessa()
										
									ENDIF
									
								ENDIF
							ELSE
								WAIT WINDOW "Par�metro NF_REMESSA_GPO_AUTOMATICA est� desligado!" TIMEOUT 1
							ENDIF
							
							*** PAULO DEVIDE - ABR/14 == OPERADOR LOGISTICO ==
							
							***
							* PAULO EDUARDO DEVIDE
							* 28-04-2015
							* COLUNA FIN_EMISSAO_NFE ESTA GRAVANDO ERRADO - TA FOR�ANDO VALOR = 1
							*/
							IF ALLTRIM(v_Entradas_00.NATUREZA) = '250.01' && DEVOLU��O
								F_UPDATE("UPDATE ENTRADAS SET FIN_EMISSAO_NFE = 4 WHERE NOME_CLIFOR=?v_Entradas_00.NOME_CLIFOR AND NF_ENTRADA=?v_Entradas_00.NF_ENTRADA AND SERIE_NF_ENTRADA=?v_Entradas_00.SERIE_NF_ENTRADA")
							ENDIF
				
				*- Andre Maia - 04/05/2015 - Travar custo minimo do produto
	 			Case Upper(xmetodo) == 'USR_SAVE_BEFORE'
*!*			 			IF ThisFormSet.p_Tool_Status $ "IA"
*!*			 				IF V_ENTRADAS_00.natureza = '200.01'
*!*			 					SET STEP ON 
*!*			 					*Busco o parametro com a tabela
*!*			 					F_Select("select valor_atual from parametros where parametro = 'MIT_TABELA_CUSTO_ENTRADA'", 'cur_tab')
*!*								VLC_Tabela = cur_tab.valor_atual
*!*								USE IN cur_tab
*!*								
*!*			 					F_Select("select valor_atual from parametros where parametro = 'MIT_PERCENTUAL_CUSTO'", 'cur_perc')
*!*								VLN_Taxa_Custo = VAL(cur_perc.valor_atual)
*!*								USE IN cur_perc
*!*									
*!*			 					VLC_Texto = ''
*!*			 					SELECT V_ENTRADAS_00_PROD1_ENT
*!*			 					SCAN
*!*			 						SELECT V_ENTRADAS_00_IMPOSTO
*!*			 						LOCATE FOR ALLTRIM(V_ENTRADAS_00_PROD1_ENT.ITEM_IMPRESSAO) == ALLTRIM(V_ENTRADAS_00_IMPOSTO.ITEM_IMPRESSAO) AND V_ENTRADAS_00_IMPOSTO.ID_IMPOSTO = 1
*!*			 						IF FOUND()
*!*										SELECT V_ENTRADAS_00_ITENS
*!*										LOCATE FOR ALLTRIM(V_ENTRADAS_00_PROD1_ENT.ITEM_IMPRESSAO) == ALLTRIM(V_ENTRADAS_00_ITENS.ITEM_IMPRESSAO)
*!*										
*!*										IF FOUND()
*!*					 						SELECT 1
*!*					 						f_select("select preco1 from produtos_precos where codigo_tab_preco = ?VLC_Tabela and produto = ?V_ENTRADAS_00_PROD1_ENT.produto", 'cur_custo')
*!*					 						
*!*					 						VLN_CustoNota = V_ENTRADAS_00_ITENS.preco_unitario - iif(V_ENTRADAS_00_ITENS.qtde_item > 0,V_ENTRADAS_00_IMPOSTO.valor_imposto/V_ENTRADAS_00_ITENS.qtde_item,0)
*!*					 						VLN_CustoPrevisto = cur_custo.preco1 * ((100-VLN_Taxa_Custo)/100)
*!*					 						
*!*					 						USE IN cur_custo
*!*					 						
*!*					 						IF VLN_CustoNota > VLn_CustoPrevisto 
*!*					 							IF !ALLTRIM(V_ENTRADAS_00_PROD1_ENT.produto) $ VLC_texto
*!*					 								VLC_Texto = VLC_Texto + IIF(EMPTY(VLC_Texto), '', CHR(13) + CHR(10)) + 'Produto:' + allt(V_ENTRADAS_00_PROD1_ENT.produto) + ' tem o custo m�nimo de ' + ALLTRIM(STR(VLN_CustoPrevisto,10,2)) + ' e veio na nota com ' + ALLTRIM(STR(VLN_CustoNota,10,2))
*!*					 							ENDIF
*!*					 						ENDIF
*!*										ELSE
*!*											MESSAGEBOX('Nao foi possivel encontrar o ITEM para o item impress�o ' + ALLTRIM(V_ENTRADAS_00_PROD1_ENT.ITEM_IMPRESSAO), 16, wusuario)
*!*											RETURN .F.
*!*										ENDIF		 						
*!*									ELSE
*!*										MESSAGEBOX('Nao foi possivel encontrar o IMPOSTO para o item impress�o ' + ALLTRIM(V_ENTRADAS_00_PROD1_ENT.ITEM_IMPRESSAO), 16, wusuario)
*!*										RETURN .F.
*!*									ENDIF			
*!*			 					ENDSCAN
*!*			 					
*!*			 					IF !EMPTY(VLC_Texto)
*!*			 						MESSAGEBOX(VLC_Texto, 16, wusuario)
*!*			 						RETURN .F.
*!*			 					ENDIF
*!*			 				ENDIF
*!*						ENDIF
						 			
				OTHERWISE
				
					 RETURN .T. 		
					 
		endcase				
		
	endproc
	
enddefine




*!*	Local cOldAlias

*!*	cOldAlias = Select()

*!*	IF  ThisFormSet.p_Tool_Status $ 'IA'

*!*		Select v_Entradas_00
*!*		Replace Porc_Desconto_Digitado With .T.

*!*	ENDIF


*!*	O_005102.chk_Porc_Desconto_Digitado.Refresh()
*!*	O_005102.tx_Valor_Total.l_Desenhista_Recalculo()





************************************************************
* Valida��o do Calculo de ICMS                             *  
************************************************************

Function rbInputBox3
Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar
Private pcReturnValue
pcReturnValue = txDefaultValue
Local oInputBox
oInputBox = Createobject("rbInputBox3", tcPrompt, tcTitle, ;
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
Define Class rbInputBox3 As Form


	Height = 180
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


	Add Object lblvalor As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Valor Total dos Produtos", ;
		Height = 20, ;
		Left = 6, ;
		Top = 16, ;
		Width = 190, ;
		Name = "lblUser"


	Add Object txtvalor As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 1, ;
		Top = 12, ;
		Width = 110, ;
		controlsource = "xCalcula_Icms.Valor_Prod",;
		inputmask = '999 999 999.99',;
		Name = "txtvalor "



	Add Object lblicms As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Valor ICMS", ;
		Height = 20, ;
		Left = 6, ;
		Top = 46, ;
		Width = 190, ;
		Name = "lblIcms"


	Add Object txticms As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		TabIndex = 2, ;
		Top = 42 ,;
		Width = 110, ;
		SelectOnEntry = .T., ;
		controlsource = "xCalcula_Icms.Valor_ICMS",;	
		inputmask = '999 999 999.99',;
		Name = "txticms"
		

	

	Add Object lblaliq As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Aliquota ICMS", ;
		Height = 20, ;
		Left = 6, ;
		Top = 76, ;
		Width = 190, ;
		Name = "lblAliq"


	Add Object txtaliq As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		Top = 72, ;
		Width = 110, ;
		Readonly = .T.,;
		controlsource = "xCalcula_Icms.Aliquota",;	
		inputmask = '999 999 999.99',;
		Name = "txtAliq"


	
		

	Add Object lblDesconto As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Valor Desconto", ;
		Height = 20, ;
		Left = 6, ;
		Top = 106, ;
		Width = 190, ;
		Name = "lblDesconto"


	Add Object txtDesconto As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		Top = 102, ;
		Width = 110, ;
		Readonly = .T.,;
		FontBold = .T.,;
		Forecolor = RGB(255,0,0),;
		controlsource = "xCalcula_Icms.Desconto",;	
		inputmask = '999 999 999.99',;
		Name = "txtDesconto"				
		

	
	
	
	Add Object cmdcalcula As CommandButton With ;
		Top = 132, ;
		Left = 32, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Calcular", ;
		TabIndex = 3, ;
		Name = "cmdCalcula"	


	Add Object cmdok As CommandButton With ;
		Top = 132, ;
		Left = 124, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "Confirmar", ;
		Default = .T., ;
		TabIndex = 20, ;
		Enabled = .F.,;
		Name = "cmdOK"


	Add Object cmdcancel As CommandButton With ;
		Top = 132, ;
		Left = 212, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancelar", ;
		TabIndex = 21, ;
		Enabled = .F.,;
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
	ENDIF
	
	

	With Thisform
		***.lblinputbox.Caption = Alltrim( tcPrompt)
		.Caption = Alltrim( tcTitle)
		.xdefaultvalue = txDefaultValue
		.xreturnvalue = .xdefaultvalue
		**.txtinputbox.Value = .xdefaultvalue
		**.txtinputbox.Format = Alltrim( tcFormat)
		**.txtinputbox.InputMask = Alltrim( tcInputMask)
		**.txtinputbox.PasswordChar = tcPasswordChar
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
	ENDPROC
	


	Procedure txtDesconto.When
	  RETURN .F.
	Endproc
	
	
	Procedure txtAliq.When
	  RETURN .F.
	ENDPROC
	

	Procedure txtValor.InteractiveChange
	
      With Thisform
      
		  
			.txtAliq.value =  0
			.txtDesconto.value = 0
				
  			.cmdok.Enabled = .F.		
  			.cmdCancel.Enabled = .F.		

		  
	  Endwith	  
	  
	ENDPROC
	

	Procedure txtICMS.InteractiveChange
	
      With Thisform
      
		  
			.txtAliq.value =  0
			.txtDesconto.value = 0
				
  			.cmdok.Enabled = .F.		
  			.cmdCancel.Enabled = .F.		
		  

		  
	  Endwith	  
	  
	ENDPROC

	

	Procedure cmdcalcula.Click
	With Thisform
	
		IF EMPTY(.txtvalor.value)	or;
     		EMPTY(.txticms.value)
     		MESSAGEBOX("Informe o Valor Total dos Produtos e o valor do ICMS",16,"Aten��o")
     		return
     	Endif	
     			   
	   
	
		IF !EMPTY(.txtvalor.value)	and;
     		!EMPTY(.txticms.value)
		
			.txtAliq.value =  ROUND((.txticms.value/.txtvalor.value)*100,2)
			
			ln_valor = ROUND(.txtvalor.value*(( 12 - .txtAliq.value) )/100,2)
			
			IF   ln_valor > 0
				.txtDesconto.value =  ln_valor
			ELSE
				.txtDesconto.value = 0
				
			Endif	
			
		endif	
		
		***IF .txtDesconto.value > 0
			.cmdok.Enabled = .T.		
		**	.cmdCancel.Enabled = .T.		
		***endif			



	Endwith
	Endproc

	Procedure cmdok.Click
	With Thisform



			  lcsql = ""
		
*!*		    IF f_vazio(.txtUser.Value)
*!*		       MESSAGEBOX("Informe o Usu�rio!")
*!*		       RETURN 
*!*		    endif
*!*		
*!*			.xreturnvalue = .txtinputbox.Value

*!*	*!*			Select xUserSenha
*!*	*!*			Zap
*!*	*!*			Append Blank
*!*			Replace usuario With Alltrim(.txtUser.Value) IN xUserSenha



		.Release()
	Endwith
	Endproc




	Procedure cmdcancel.Click
*
*	If Cancel was chosen, return the empty value of the correct data type.
*
	With Thisform
	
	     SELECT xCalcula_Icms
	     ZAP
	     
	
		.xreturnvalue = .xemptyvalue
		.Release()
	Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************


