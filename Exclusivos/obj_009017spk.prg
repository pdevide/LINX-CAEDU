

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

	*- Nome do metodo/fun��o que os objetos linx v�o chamar.
	procedure metodo_usuario
	lparam xmetodo, xobjeto ,xnome_obj

		do case
		   case UPPER(xmetodo) == 'USR_INIT'
  			    

				IF TYPE("o_009017.pp_acessa_009017") = "L"
				   
					   IF !o_009017.pp_acessa_009017
					       
					       f_Msg(['Usu�rio sem permiss�o de acesso a esta Tela!',48, 'Aten��o'])
					       RETURN .F.
					   Endif

				ENDIF  			     			    
				
		   		
		   OTHERWISE
						
				return .t.				
				
			endcase
	ENDPROC
	
enddefine