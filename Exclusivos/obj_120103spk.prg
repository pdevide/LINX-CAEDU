define class obj_entrada as custom
	procedure metodo_usuario
	lparam xmetodo, xobjeto ,xnome_obj
	DO CASE
		CASE UPPER(xmetodo) == 'USR_INIT'	
			WAIT WINDOW 'OBJ' timeout 2
			STORE 0 TO lnTop, lnLeft	
			WITH thisformset.lx_foRM1.lx_PAGEFRAME1.page3.Cmd_salvaparcial
				lnTop = .top 
				lnLeft = .left + 200
			ENDWITH
			WITH thisformset.lx_foRM1.lx_PAGEFRAME1.page3
				.AddObject("bt_lecodigo1","bt_lecodigo")
				.bt_lecodigo1.visible=.t.
*!*					.bt_lecodigo1.top = lnTop
*!*					.bt_lecodigo1.left = lnLeft
			ENDWITH
			
			
		CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

		OTHERWISE
			RETURN .t.
	ENDCASE
	ENDPROC
ENDDEFINE

DEFINE CLASS bt_lecodigo as botao

	Top=36
	left=124
	width=132
	height=22
	caption="Importar TXT"
	visible=.t.
	
	PROCEDURE click

		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Importar arquivo TXT com os código de barras de Produtos?",292,"Aviso")=6

		IF !llRet
			RETURN 
		ENDIF
		
		lcArquivo = GETFILE("TXT","Selecionar","Abrir",0,"Abrir arquivo TXT de estoque")	
		IF EMPTY(lcArquivo)
			MESSAGEBOX("Operação Cancelada pelo usuário",16,"Aviso")
			RETURN 
		ENDIF
		
		lnselect = SELECT()
		IF USED("arq_estoque")
			USE IN arq_estoque
		ENDIF
		
		CREATE CURSOR arq_estoque (CODIGO_BARRA c(15) null)
		
		SELECT arq_estoque
		APPEND FROM &lcArquivo. TYPE SDF
		GO top
		
		SELECT CODIGO_BARRA ;
		FROM arq_estoque INTO ARRAY laProdutos
		
		lcTotReg = ALLTRIM(TRANSFORM(ALEN(laProdutos,1),"999999"))
		
		SELECT (lnSelect)
		
		FOR ixx=1 TO ALEN(laProdutos,1)
			
			ThisFormset.Lx_form1.LX_PAGEFRAME1.Page3.LX_IMPORTA_CBAR1.tx_codigo_barra.setfocus()
			ThisFormset.Lx_form1.LX_PAGEFRAME1.Page3.LX_IMPORTA_CBAR1.tx_codigo_barra.Value	= ALLTRIM(laProdutos[ixx])	
			ThisFormset.Lx_form1.LX_PAGEFRAME1.Page3.LX_IMPORTA_CBAR1.tx_codigo_barra.valid
			
			lcRegistro = TRANSFORM(ixx,"999999") + "/" + lcTotReg
			
			WAIT WINDOW lcRegistro + " Lendo SKU = "+ALLTRIM(laProdutos[ixx]) nowait
			ThisFormset.lx_fORM1.lx_PAGEFRAME1.page3.lx_GRID_FILHA1.Refresh
			
			DOEVENTS FORCE
			
			ThisFormset.Lx_form1.LX_PAGEFRAME1.Page3.LX_IMPORTA_CBAR1.tx_codigo_barra.Value	= ""
			
		ENDFOR
		
		ThisFormset.Lx_form1.LX_PAGEFRAME1.Page3.refresh
		MESSAGEBOX("Leitura de arquivo finalizada com sucesso!", 64, "Aviso")
		
		*
		
		SELECT (lnSelect)
		
		
		f_wait()
		
	ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC

ENDDEFINE
