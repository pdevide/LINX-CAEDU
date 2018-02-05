** obj_100135spk - monitor nfe
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
		   
		   		PUBLIC xobj100135
		   		xobj100135 = thisformset.lx_FORM1
		   		
				thisformset.lx_FORM1.lx_pageframe.page1.addobject('bt_rel_nfe1', 'bt_rel_nfe')
				WITH thisformset.lx_form1.lx_pageframe.Page1.bt_rel_nfe1
					.visible = .t.
				ENDWITH


		   case UPPER(xmetodo) == 'USR_ALTER_BEFORE'  			
		   	  
  			     
			otherwise
				return .t.				
		endcase
	endproc
enddefine


** (inicio) --> PAULO DEVIDE - 30-SET-14
DEFINE CLASS bt_rel_nfe as botao
	caption = 'Imprime Relatórios'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 132
	top = 71
	left = 270
	HEIGHT =  18
	enabled = .t.
	visible  = .t.
	backcolor =  RGB(64,128,128)
	Style=0
	ToolTipText = "Impressão de relatórios de faturamento"
	SpecialEffect=0
	Autosize=.t.
	name="bt_rel_nfe1"
	
	PROCEDURE click

		LOCAL lcObs, lnArea
		lnArea = SELECT()

		PUBLIC frmRelat
		frmRelat = CreateObject ("Tform")
		frmRelat.show(1)

		SELECT (lnArea)


	ENDPROC

	*!*		PROCEDURE refresh
	*!*			** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
	*!*			this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	*!*		ENDPROC

ENDDEFINE
** (fim) PAULO DEVIDE - 30-SET-14



DEFINE CLASS Tform As Form

	Width = 300
	Height = 110
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Caption = "Imprimir relatórios de Faturamento"



	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=164, Top=70, ;
		Caption="Cancel" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=234, Top=70, ;
		Caption="Ok", Default=.T.


	PROCEDURE cmd1.Click
		ThisForm.Release
	ENDPROC

	PROCEDURE cmd2.Click
		Tform_imprime()
		ThisForm.Release
	ENDPROC
	
ENDDEFINE

FUNCTION Tform_imprime()
	IF MESSAGEBOX("Confirma impressão dos relatórios",292,"Aviso")=6
	
*!*			lcReport1 = ADDBS(WDIR_EXE)+"Report\User\U100135FR1 CÓPIA DE (B) CD CAEDU - CONFERÊNCIA DE PEÇAS.FRX"
*!*			REPORT FORM (lcReport1) TO PRINTER PROMPT noconsole

*!*			lcReport2 = ADDBS(WDIR_EXE)+"Report\User\U100135GD1 CÓPIA DE (B) CD CAEDU - RELAÇÃO DE CAIXAS.FRX"
*!*			REPORT FORM (lcReport2) TO PRINTER PROMPT noconsole
		
		lcReport3 = ADDBS(WDIR_EXE)+"report\linx\l100135f.prg"
		IF NOT ("l100135f" $ SET("procedure"))
			SET PROCEDURE TO &lcReport3. additive
		ENDIF
		llReport = Func_Relatorio("IMP",xobj100135)
		
	ENDIF
	RETURN
	
ENDFUNC
