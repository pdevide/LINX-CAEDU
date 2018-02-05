Define Class Obj_Entrada as Custom

   Procedure Metodo_Usuario
   
      Lparameters cMetodo, oObjeto, cNome_Obj
      
      DO Case
         Case Upper(Alltrim(cMetodo)) == 'USR_INIT'
         
*!*	         	f_select("select DISTINCT NOME_CONTAGEM  from ESTOQUE_PROD_CONTAGEM a "+;
*!*				"left join faturamento b on a.nome_contagem = b.conferido_por "+;
*!*				"where A.estoque_Ajustado = 1 and b.NF_SAIDA IS NULL", 'CurInventarios')


            ThisFormSet.lx_Form1.lx_pageframe1.page3.AddObject('cmbInventarios', 'cmbInventarios')
            ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.enabled = .f.
            ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.visible = .t.
            ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.rowsourcetype = 3
            ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.rowsource = [f_select("select DISTINCT NOME_CONTAGEM  from ESTOQUE_PROD_CONTAGEM a "+;
																						"left join faturamento b on a.nome_contagem = b.conferido_por "+;
																						"where A.estoque_Ajustado = 1 and b.NF_SAIDA IS NULL", 'CurInventarios')]
																						
            ThisFormSet.lx_Form1.lx_pageframe1.page3.AddObject('lblInventarios', 'lblInventarios')
            ThisFormSet.lx_Form1.lx_pageframe1.page3.lblInventarios.enabled = .f.
            ThisFormSet.lx_Form1.lx_pageframe1.page3.lblInventarios.visible = .t.
            
            ThisFormSet.lx_Form1.lx_pageframe1.page3.AddObject('btnInventarios', 'btnInventarios')
            ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios.enabled = .f.
            ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios.visible = .t.
            
            Return .T.

         Case Upper(Alltrim(cMetodo)) == 'USR_REFRESH'

            If Type('ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios') == 'O'
               ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.enabled = ( ThisFormSet.p_Tool_Status $ 'IA' )
            ENDIF
            
            If Type('ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios') == 'O'
               ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios.enabled = ( ThisFormSet.p_Tool_Status $ 'IA' )
            EndIf

			Return .T.
		
*!*			CASE UPPER(cMetodo) == 'USR_INCLUDE_AFTER'
*!*				IF USED('CurInventarios')
*!*					SELECT CurInventarios
*!*					USE
*!*				ENDIF 
*!*				ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.rowsource = ''
*!*	         	f_select("select DISTINCT NOME_CONTAGEM  from ESTOQUE_PROD_CONTAGEM a "+;
*!*						"left join faturamento b on a.nome_contagem = b.conferido_por "+;
*!*						"where A.estoque_Ajustado = 1 and b.NF_SAIDA IS NULL", 'CurInventarios')
*!*				ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.rowsource = 'CurInventarios'		
			
			
         Otherwise

            Return .T.

      EndCase

   EndProc

EndDefine

DEFINE CLASS cmbInventarios AS combobox

	Top = 32
	Left = 730
	Height = 24
	Width = 150
	FontName = "Tahoma"
	FontSize = 8
	Name = "cmbInventarios"
	style = 2
	
ENDDEFINE 	

DEFINE CLASS lblInventarios AS label

	Top = 20
	Left = 730
	Height = 24
	Width = 150
	FontName = "Tahoma"
	FontSize = 8
	Name = "cmbInventarios"
	Caption = "Ajustes"
	backstyle = 0
	
ENDDEFINE 	

DEFINE CLASS btnInventarios AS botao

	Top = 60
	Left = 730
	Height = 24
	Width = 150
	FontName = "Tahoma"
	FontSize = 8
	Name = "cmbInventarios "
	Caption = "Processa"

	
	PROCEDURE click 
		LOCAL strAjuste
		strAjuste =  ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.value
		IF !EMPTY(ALLTRIM(ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.value)) AND EMPTY(ALLTRIM(NVL(v_faturamento_05.conferido_por,'')))
			ThisFormset.px_tabela_preco = '00'
			ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_container1.ck_produtos.value = .T.
			f_select(" select produto, sum(qtde_ajuste) as qtde from ESTOQUE_PROD_CTG_AJUSTE "+;
					"where nome_Contagem = '"+alltr(strAjuste)+"' "+;
					"group by produto "+;
					"having sum(qtde_ajuste) < 0",'vtmp_inventario')
			ThisFormSet.lx_Form1.lockscreen = .t.
			SELECT vtmp_inventario
			SCAN
				Messagebox.ShowProgress( "Importando Produtos ("+ALLTRIM(vtmp_inventario.produto)+") de Inventario " + Alltrim(Str(RECNO('vtmp_inventario')))+"/"+Alltrim(Str(RECCOUNT('vtmp_inventario')))) 
				thisformset.p_filha_Atual = 'V_FATURAMENTO_05_ITEM'
				thisformset.l_filhas_inclui()
				ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_grid_filha1.col_tx_codigo_item.tx_codigo_item.value = ALLTRIM(vtmp_inventario.produto)
				ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_grid_filha1.col_tx_codigo_item.tx_codigo_item.l_desenhista_recalculo()
				ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_grid_filha1.col_tx_qtde_item.tx_qtde_item.value = ABS(vtmp_inventario.qtde)
				ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_grid_filha1.col_tx_qtde_item.tx_qtde_item.l_desenhista_recalculo()
				SELECT vtmp_inventario
			ENDSCAN 		
			SELECT v_faturamento_05
			replace v_faturamento_05.conferido_por WITH strAjuste
			ThisFormSet.lx_Form1.lockscreen = .f.
			ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios.enabled = .f.
			ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.enabled = .f.
			f_wait()
		ENDIF 		
	ENDPROC 
	
ENDDEFINE 	