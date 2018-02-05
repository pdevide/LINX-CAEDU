define class obj_entrada as custom
	procedure metodo_usuario
	lparam xmetodo, xobjeto ,xnome_obj
	DO CASE
		CASE UPPER(xmetodo) == 'USR_INIT'	
			


			WAIT WINDOW 'OBJ' timeout 2

			STORE 0 TO lnTop, lnLeft	
			WITH thisformset.lx_FORM1.lx_pageframe1.page1.Lx_cabecalho_contato1.Lx_label3
				lnTop = .top - 2
				lnLeft = .parent.Cmb_STATUS_CONTATO.Left - 30
			ENDWITH
			WITH thisformset.lx_FORM1.lx_pageframe1.page1.Lx_cabecalho_contato1
				.AddObject("LABEL_ID_ORACLE","LABEL")
				.LABEL_ID_ORACLE.top = lnTop + 2
				.LABEL_ID_ORACLE.left = lnLeft - 50
				.LABEL_ID_ORACLE.Caption = "ID ORACLE"
				.LABEL_ID_ORACLE.BackStyle = 0
				.LABEL_ID_ORACLE.visible = .t.
				
				.AddObject("txt_Id_Oracle1","txt_Id_Oracle")
				.txt_Id_Oracle1.visible=.t.
*!*					.bt_lecodigo1.top = lnTop
*!*					.bt_lecodigo1.left = lnLeft
			ENDWITH
			
			
		CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

		CASE UPPER(xmetodo) == 'USR_REFRESH'
			IF NOT thisformset.pp_palma_edicao_cliente
				o_toolbar.Botao_inclui.Enabled=.f.
				o_toolbar.Botao_altera.Enabled = .f.
				o_toolbar.botao_exclui.Enabled = .f.
			ENDIF
					
		OTHERWISE
			RETURN .t.
	ENDCASE
	ENDPROC
ENDDEFINE

DEFINE CLASS txt_Id_Oracle as textbox

	Top=10
	left=266
	width=132
	height=22
	controlsource="v_clientes_01.EBS_ID_CLIENTE"
	readonly = .f.
	visible=.t.
	
*!*		PROCEDURE WHEN

*!*			RETURN .F.		
*!*			
*!*		ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","L")
	ENDPROC

ENDDEFINE
