*** PAULO DEVIDE - 04/12/2013
*****************************
*- Definindo a classe do objeto de entrada que sera criado na Form.
Define Class obj_entrada As Custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	Procedure metodo_usuario
		Lparam xmetodo, xobjeto, xnome_obj

		Do Case

			case upper(xmetodo) == 'USR_INIT'

				WITH thisformset.lx_form1.lx_pageframe1
					.pagecount = .pagecount + 1
					.activepage = .pagecount
					lcPage =  ALLTRIM(TRANSFORM(.activepage,"99"))
				ENDWITH

				thisformset.lx_form1.lx_pageframe1.Page&lcPage..caption = "WK"
				thisformset.lx_form1.lx_pageframe1.Page&lcPage..name = "pageWK"

									
				WITH thisformset.lx_form1.lx_pageframe1.pageWK
					.addobject("sh_WK1","sh_WK")
					.addobject('lb_codigo_wk1', 'lb_codigo_wk')
					.addobject('tx_codigo_wk1', 'tx_codigo_wk')
				ENDWITH
				
				thisformset.lx_form1.lx_pageframe1.activepage = 1
				
				
		endcase
	endproc

enddefine


DEFINE CLASS sh_WK AS lx_shape 
	Top = 10
	Left = 4
	Height = 40
	Width = 202
	Name = "sh_WK1"
	visible = .t.
ENDDEFINE


DEFINE CLASS lb_codigo_wk AS lx_label 
	FontBold = .T.
	Alignment = 0
	Caption = "Código WK:"
	Left = 18
	Top = 20
	Name = "lb_codigo_wk1"
	visible = .t.
ENDDEFINE


DEFINE CLASS tx_codigo_wk AS lx_textbox_base 
	Height = 21
	Left = 108
	Top = 20
	Width = 84
	Name = "tx_codigo_wk1"
	controlsource = "v_ctb_conta_plano_00.ERP_CONTA_CONTABIL_WK"
	p_tipo_dado  = "EDITA"
	visible = .t.
ENDDEFINE






