
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
		
			case upper(xmetodo) == 'USR_INIT'
			
				xobjeto.p_acesso_alterar = .F.
				xobjeto.p_acesso_excluir = .F.
				xobjeto.p_acesso_incluir = .F.
				xobjeto.p_acesso_pesquisar = .T.
				xobjeto.P_Acesso_item_excluir = .F.
				xobjeto.P_Acesso_item_incluir = .F.
   	 		    
   	 		    IF xobjeto.pp_cadastra_003008
   	 		    
						xobjeto.p_acesso_alterar = .T.
						xobjeto.p_acesso_excluir = .T.
						xobjeto.p_acesso_incluir = .T.
						xobjeto.p_acesso_pesquisar = .T.
						xobjeto.P_Acesso_item_excluir = .T.
						xobjeto.P_Acesso_item_incluir = .T.
   	 		    
   	 		    
   	 		    Endif 	
   	 		Case upper(xmetodo) == 'USR_SAVE_AFTER'
   	 		
                   IF THISFORMSET.P_TOOL_STATUS = "I"        
                   
						XVALOR = F_SEQUENCIAIS('MATERIAIS.MATERIAL', .T.)
						
						l_codold = material
						
						TEXT TO lcsql noshow
						 UPDATE materiais
						 SET material = ?XVALOR
						 where material like ?l_codold
						ENDTEXT 
						
						f_update(lcsql) 
						
						SELECT v_materiais_00
      				    replace  material WITH XVALOR IN v_materiais_00
      				    
					   
				   Endif	   
   	 		 
			 			
			OTHERWISE
				
					 RETURN .T. 		
					 
		endcase				
		
	endproc
	
enddefine

