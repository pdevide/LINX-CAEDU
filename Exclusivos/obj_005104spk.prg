
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
	*- Nome do metodo/função que os objetos linx vão chamar.
	Procedure metodo_usuario
		Lparam xmetodo, xobjeto, xnome_obj
	
		Do Case
		
			case upper(xmetodo) == 'USR_INCLUDE_AFTER'

 			 xobjeto.lx_FORM1.lx_pageframe1.page2.lx_grid_filha1.col_DESCRICAO_ITEM.ReadOnly = .T.

 			 
 			 xobjeto.lx_FORM1.lx_pageframe1.page2.Cnt_itens_fiscais.TX_descricao_item.ReadOnly = .T.
   	 		     	
			Case Upper(xmetodo) == 'USR_SAVE_AFTER'			 			

				*** PAULO DEVIDE - MAI/14 == OPERADOR LOGISTICO ==
				IF .f.
					IF ThisFormSet.p_Tool_Status = "I" && operação de inclusão de NOTA de Entrada de PA

						*** Chama rotina para OPERADOR LOGISTICO
						IF INLIST(UPPER(ALLTRIM(v_entradas_00.filial)),"CD ARAQUARI","CD IMPORTACAO","CD REGIS")
							***cria_nf_remessa()
							** Verifica se a classe de objetos esta carregada em memória
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
				ENDIF
				
				*** PAULO DEVIDE - MAI/14 == OPERADOR LOGISTICO ==

			OTHERWISE
				
					 RETURN .T. 		
					 
		endcase				
		
	endproc
	
enddefine


