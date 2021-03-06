

**********************************************************
*        Ultimas altera��es no Grupo Palma               *
**********************************************************
* Data :  27/05/2014
* Autor:  Sandra Ono
*              a) Inclus�o Automatica de Tabelas com pre�o  Default
*              b) Validar se campo d� mensagem de Campo Inativo
*              c) Altera��o para corrigir erro da linx para n�o alterar o pre�o liquido dos produtos


***  03/08/2013: Paulo Devide 
*!*					** VALIDA��O DA PROPRIEDADE DATA_ATIVACAO (00027)
*!*				llOk=zvalida_prop_data_ativacao() &&PAULO DEVIDE - 03-09-2013
***         Verifica se a Data informada na propriedade DATA_ATIVACAO � v�lida!"



* 24-05-2013: Paulo Devide
*!*					** PAULO DEVIDE -> 24-05-2013
*!*					llOk=zvalida_campos_produto()
** 1) valida campo Categoria "Campo [Categoria] � obrigat�rio..."
** 2) valida campo Subcategoria "Campo [Subcategoria] � obrigat�rio..."
** 3) valida tabela de pre�os preeenchida (campo Preco1)


*!*	* 20/05/2014: Sandra Ono   
*!*	* Valida��o se o Produto esta devidamente cadastrado na Tabela NCM  (obriga��o para calculo de imposto nas lojas)




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
	*- Nome do metodo/fun��o que os objetos linx v�o chamar.
	procedure metodo_usuario

		lparam xmetodo, xobjeto ,xnome_obj



		do case
			case UPPER(xmetodo) == 'USR_INIT'

				***
				* PROJETO CUPS - PAULO DEVIDE 01/ABR/15
				* (INICIO)
				*/
				thisformset.lx_form1.minbutton=.f.
				thisformset.lx_form1.maxbutton=.f.
				
				lcLastPage = "pgImportado"
				thisformset.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageImportado")
				WITH thisformset.lx_form1.lx_pageframe1.pgImportado
					.enabled=.t.
					.caption = "Importado"
					lnPgOrder = .pageorder
				ENDWITH
								
				lnqtdpags = thisformset.lx_form1.lx_pageframe1.pagecount 
				
				thisformset.lx_form1.lx_pageframe1.activepage = lnPgOrder

				lnHeightForm = thisformset.lx_form1.Height
				thisformset.lx_form1.Height = lnHeightForm + 35
				thisformset.lx_form1.lx_pageframe1.top = thisformset.lx_form1.lx_pageframe1.top + 30

				lnAlturaPanel = ThisFormset.Lx_form1.Lx_frame_3d1.height 
				ThisFormset.Lx_form1.Lx_frame_3d1.height = lnAlturaPanel + 35
				
				IF "CUPS01" $ SET( "ClassLib" )
					** Ok, Registry carregado
				ELSE
					SET CLASSLIB TO CUPS01.vcx ADDITIVE
				ENDIF
				
				** CLASSE DE COMPONENTES - PAULO DEVIDE
				IF "CONTROLES" $ SET( "ClassLib" )
					** Ok, Registry carregado
				ELSE
					SET CLASSLIB TO CONTROLES.vcx ADDITIVE
				ENDIF
				
				**objCups = CREATEOBJECT("funcoes_cups")
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_evento', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_evento1', 'cbo_evento')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_evento1
					.top = 20
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_EVENTO"
					.visible = .t.
					.parent.lbl_evento.caption = "Evento"
					.parent.lbl_evento.top = 25
					.parent.lbl_evento.left = 10
					.parent.lbl_evento.visible = .t.
				ENDWITH

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_tema', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_tema1', 'cbo_tema')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_tema1
					.top = 50
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_TEMA"
					.visible = .t.
					.parent.lbl_tema.caption = "Tema"
					.parent.lbl_tema.top = 55
					.parent.lbl_tema.left = 10
					.parent.lbl_tema.visible = .t.
				ENDWITH				

*!*					thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_umv', 'rotulo')
*!*					thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('txt_umv1', 'txt_umv')
*!*					WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.txt_umv1
*!*						.top = 80
*!*						.left = 90
*!*						.visible = .t.
*!*						.parent.lbl_umv.caption = "UMV"
*!*						.parent.lbl_umv.top = 85
*!*						.parent.lbl_umv.left = 10
*!*						.parent.lbl_umv.visible = .t.
*!*					ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_comprimento', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_comprimento1', 'cbo_comprimento')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_comprimento1
					.top = 110 - 30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_COMPRIMENTO"
					.visible = .t.
					.parent.lbl_comprimento.caption = "Comprimento"
					.parent.lbl_comprimento.top = 115 - 30
					.parent.lbl_comprimento.left = 10
					.parent.lbl_comprimento.visible = .t.
				ENDWITH				

				****
				* TRATAMENTO PARA CONJUNTO BOTTOM
				* PAULO DEVIDE - 05-08-2015
				*/
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('chk_conjunto1', 'chk_conjunto')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.chk_conjunto1.visible=.t.
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cntBottom1', 'Container')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1
					.top = 106
					.left = 305
					.height = 100
					.width = 290
					.backstyle = 0
					.visible = .t.
				ENDWITH
				
				***
				* CAMPO COMPRIMENTO BOTTOM
				*/
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('lbl_comprimento_bottom', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('cbo_comprimento_bottom1', 'cbo_comprimento')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.cbo_comprimento_bottom1
					.top = 6
					.left = 82
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_COMPRIMENTO_BOTTOM"
					.visible = .t.
					.parent.lbl_comprimento_bottom.caption = "Comprimento"
					.parent.lbl_comprimento_bottom.top = 6
					.parent.lbl_comprimento_bottom.left = 4
					.parent.lbl_comprimento_bottom.visible = .t.
				ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_construcao', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_construcao1', 'cbo_construcao')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_construcao1
					.top = 140 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_CONTRUCAO"
					.visible = .t.
					.parent.lbl_construcao.caption = "Constru��o"
					.parent.lbl_construcao.top = 145 - 30 
					.parent.lbl_construcao.left = 10
					.parent.lbl_construcao.visible = .t.
				ENDWITH				

				***
				* CAMPO COMPOSI��O BOTTOM
				*/
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('lbl_composicao_bottom', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('cbo_composicao_bottom1', 'cbo_composicao')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.cbo_composicao_bottom1
					.top = 36
					.left = 82
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_COMPOSICAO_BOTTOM"
					.visible = .t.
					.parent.lbl_composicao_bottom.caption = "Composi��o"
					.parent.lbl_composicao_bottom.top = 36
					.parent.lbl_composicao_bottom.left = 4
					.parent.lbl_composicao_bottom.visible = .t.
				ENDWITH				
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_composicao', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_composicao1', 'cbo_composicao')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_composicao1
					.top = 170 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_COMPOSICAO"
					.visible = .t.
					.parent.lbl_composicao.caption = "Composi��o"
					.parent.lbl_composicao.top = 175 - 30
					.parent.lbl_composicao.left = 10
					.parent.lbl_composicao.visible = .t.
				ENDWITH				
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_forro', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_forro1', 'cbo_forro')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_forro1
					.top = 200 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_FORRO"
					.visible = .t.
					.parent.lbl_forro.caption = "Forro"
					.parent.lbl_forro.top = 205 - 30
					.parent.lbl_forro.left = 10
					.parent.lbl_forro.visible = .t.
				ENDWITH				

				***
				* CAMPO FORRO BOTTOM
				*/
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('lbl_forro_bottom', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('cbo_forro_bottom1', 'cbo_forro')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.cbo_forro_bottom1
					.top = 66
					.left = 82
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_FORRO_BOTTOM"
					.visible = .t.
					.parent.lbl_forro_bottom.caption = "Forro"
					.parent.lbl_forro_bottom.top = 66
					.parent.lbl_forro_bottom.left = 4
					.parent.lbl_forro_bottom.visible = .t.
				ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_produto', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_produto1', 'cbo_produto')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_produto1
					.top = 230 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_PRODUTO"
					.visible = .t.
					.parent.lbl_produto.caption = "Produto"
					.parent.lbl_produto.top = 235 - 30
					.parent.lbl_produto.left = 10
					.parent.lbl_produto.visible = .t.
				ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_supplier', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_subgrupo_atc', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_subgrupo_atc1', 'cbo_subgrupo_atc')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_subgrupo_atc1
					.top = 260 
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_SUBGRUPO_ATACADO"
					.visible = .t.
					.parent.lbl_subgrupo_atc.caption = "Subgrupo ATC."
					.parent.lbl_subgrupo_atc.top = 265
					.parent.lbl_subgrupo_atc.left = 10
					.parent.lbl_subgrupo_atc.visible = .t.
				ENDWITH					

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('tv_supplier1', "fk_picklist")
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.tv_supplier1
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_SUPPLIER"
					*.Height = 21
					.Left = 90
					.Top = 230
					*.Width = 120
					.Name = "tv_Supplier"
					.descricao = "FORNECEDOR"
					.lista_campos = "FORNECEDOR,CLIFOR"
					.tabela_valida="FORNECEDORES"
					.ImgPesquisa.Stretch = 2
					.ImgPesquisa.picture = LOCFILE("lupa.gif","GIF","Localizar")
					
					.visible = .t.
					.parent.lbl_supplier.caption = "Supplier"
					.parent.lbl_supplier.top = 265 - 30
					.parent.lbl_supplier.left = 10
					.parent.lbl_supplier.visible = .t.
				ENDWITH	

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_preco_custo_estimado1', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('txt_preco_custo_estimado1', 'txt_preco_custo_estimado')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.txt_preco_custo_estimado1
					.top = 290 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_PRECO_CUSTO_ESTIMADO"
					.visible = .F.
					.parent.lbl_preco_custo_estimado1.caption = "Pr� Custo Est"
					.parent.lbl_preco_custo_estimado1.top = 295 - 30
					.parent.lbl_preco_custo_estimado1.left = 10
					.parent.lbl_preco_custo_estimado1.visible = .F.
				ENDWITH					

				thisformset.lx_FORM1.addobject('lbl_segmento', 'rotulo')
				thisformset.lx_FORM1.addobject('cbo_segmento1', 'cbo_segmento')
				WITH thisformset.lx_FORM1.cbo_segmento1
					.top = 60
					.left = 93
					.width = 100
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_SEGMENTO"
					.visible = .t.
					.parent.lbl_segmento.caption = "Segmenta��o"
					.parent.lbl_segmento.top = 65
					.parent.lbl_segmento.left = 10
					.parent.lbl_segmento.visible = .t.
				ENDWITH				

				thisformset.lx_FORM1.addobject('lbl_stylenumber', 'rotulo')
				thisformset.lx_FORM1.addobject('txt_stylenumber1', 'txt_stylenumber_edit')
				WITH thisformset.lx_FORM1.txt_stylenumber1
					.top = 60
					.left = 290
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_STYLENUMBER"
					.visible = .t.
					.parent.lbl_stylenumber.caption = "Style Number"
					.parent.lbl_stylenumber.top = 65
					.parent.lbl_stylenumber.left = 210
					.parent.lbl_stylenumber.visible = .t.
				ENDWITH				
				
				thisformset.lx_form1.lx_pageframe1.page3.lx_grid_filha1.height = 271
				
				WITH thisformset.lx_form1.lx_pageframe1.page3.cmd_ExportaCBar
					.Top = 119
					.Width = 125
					.Height = 27
					.left = 589-4
				ENDWITH
				
				thisformset.lx_form1.lx_pageframe1.page3.addobject('shape1', 'shape')
				thisformset.lx_form1.lx_pageframe1.page3.addobject('label_atacado1', 'label')
				
				WITH thisformset.lx_form1.lx_pageframe1.page3.shape1
					.top = 08
					.style = 3
					.width = 160
					.height = 108
					.left = 555
					.visible = .t.
				ENDWITH
				thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.top = 03
				thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.left = 565
				thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.caption = " Atacado " 
				thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.autosize = .t.
				thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.visible = .t.


				thisformset.lx_FORM1.lx_pageframe1.page3.addobject('lbl_codebar_ref', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.page3.addobject('txt_codebar_ref1', 'txt_codebar_ref')
				WITH thisformset.lx_FORM1.lx_pageframe1.page3.txt_codebar_ref1
					.top = 28-9
					.left = 584
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_CODEBAR_REF"
					.visible = .t.
					.parent.lbl_codebar_ref.caption = "Ref"
					.parent.lbl_codebar_ref.top = 31-9
					.parent.lbl_codebar_ref.left = 562
					.parent.lbl_codebar_ref.visible = .t.
				ENDWITH				
								
				thisformset.lx_FORM1.lx_pageframe1.page3.addobject('lbl_codebar_pb', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.page3.addobject('txt_codebar_pb1', 'txt_codebar_pb')
				WITH thisformset.lx_FORM1.lx_pageframe1.page3.txt_codebar_pb1
					.top = 58-9
					.left = 584
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_CODEBAR_PB"
					.visible = .t.
					.parent.lbl_codebar_pb.caption = "PB"
					.parent.lbl_codebar_pb.top = 61-9
					.parent.lbl_codebar_pb.left = 562
					.parent.lbl_codebar_pb.visible = .t.
				ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.page3.addobject('lbl_codebar_cx', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.page3.addobject('txt_codebar_cx1', 'txt_codebar_cx')
				WITH thisformset.lx_FORM1.lx_pageframe1.page3.txt_codebar_cx1
					.top = 88-5
					.left = 584
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_CODEBAR_CX"
					.visible = .t.
					.parent.lbl_codebar_cx.caption = "CX"
					.parent.lbl_codebar_cx.top = 91-9
					.parent.lbl_codebar_cx.left = 562
					.parent.lbl_codebar_cx.visible = .t.
				ENDWITH				


				**** REORGANIZA��O DE CAMPOS NA TELA PRINCIPAL DE PRODUTOS ***************************
				*CAMPO		ORDEM TOP ATUAL		ORDEM  TOP NOVO	OBJETOS
				*=====================================================================================
				*LINHA		8	180/177		 1	 12/9	LABEL_LINHA/TVLINHA
				*GRIFFE		7	156/153		 2	 36/33	LABEL_GRIFFE/TVGRIFFE
				*GRUPO		1	 12/9		 3	 60/57	Label_GRUPO_PRODUTO/tvGrupoProduto
				*SUBGRUPO	2	 36/33       4	 84/81	Label_SUBGRUPO_PRODUTO/tvSubGrupoProduto
				*CATEGORIA	3	 60/57       5	108/105	Lx_label6/cmb_Categoria_produto
				*SUB CAT.	4	 84/81       6 	132/129	Lx_label16/cmb_SubCategoria_produto
				*TIPO		5	108/105      7	156/153	Label_TIPO_PRODUTO/tvTipoProduto
				*COLE��O	6	132/129  	 8	180/177	Label_COLECAO/tv_Colecao
				*/
*** n�o funciona - o linx em opera��o de altera��o/inclus�o remonta os campos da forma antiga				
*!*					WITH thisformset.lx_foRM1.lx_pagEFRAME1.page1.pgDadosProdutos.page1
*!*						* Linha
*!*						.label_linha.top = 12
*!*						.tvlinha.top = 9
*!*						* Griffe
*!*						.LABEL_GRIFFE.top = 36
*!*						.TVGRIFFE.top = 33
*!*						* Grupo
*!*						.Label_GRUPO_PRODUTO.top = 60
*!*						.tvGrupoProduto.top = 57
*!*						* Subgrupo
*!*						.Label_SUBGRUPO_PRODUTO.top = 84
*!*						.tvSubGrupoProduto.top = 81
*!*						* Categoria
*!*						.Lx_label6.top = 108
*!*						.cmb_Categoria_produto.top = 105
*!*						* Sub Categoria
*!*						.Lx_label16.top = 132
*!*						.cmb_SubCategoria_produto.top = 129
*!*						* Tipo
*!*						.Label_TIPO_PRODUTO.top = 156
*!*						.tvTipoProduto.top = 153
*!*						* Cole��o
*!*						.Label_COLECAO.top = 180
*!*						.tv_Colecao.top = 177
*!*						
*!*					ENDWITH

				thisformset.lx_form1.lx_pageframe1.activepage = 1
				*\
				* PROJETO CUPS - PAULO DEVIDE 01/ABR/15
				* (FINAL)
				****				


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
				
				

					*****WAIT WINDOW 'inclus�o de bot�o com pre�o default'
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

					***
					* VALORES DEFAULT - INCLUS�O
					* PROJETO CUPS - PAULO DEVIDE
					*/
					
					thisformset.lx_FORM1.cbo_segmento1.VALUE = '000155' && VAREJO
					thisformset.lx_FORM1.cbo_segmento1.valid()


				ENDIF	


	   		case UPPER(xmetodo) == 'USR_VALID'			
			
			
				*** Sandra Ono - 27/05/2014 ****
				**** Altera��o para corrigir erro da linx para n�o alterar 
				**** o pre�o liquido dos produtos
				 
				IF 'TX_PRECO1'$UPPER(xnome_obj)
		    		IF  INLIST(ThisFormSet.p_tool_status,'I','A')
		    		
   	     	    		replace 	preco_liquido1 with 0, ;
	 					preco_liquido2 with 0, ;
						preco_liquido3 with 0, ;
						preco_liquido4 with 0  IN V_PRODUTOS_00_PRECOS

		    		
				    		
		    		ENDIF
				ENDIF    		
				

				

										

			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

				** VALIDA��O DA PROPRIEDADE DATA_ATIVACAO (00027)
				IF USED("CURPROPPRODUTOS")
					llOk=zvalida_prop_data_ativacao() &&PAULO DEVIDE - 03-09-2013
					IF NOT llOk
						RETURN .f.
					ENDIF
				Endif	
				
				** PAULO DEVIDE -> 24-05-2013
				** alterado em 15/04/2015 
				** inclus�o de regras de valida��o para page do Atacado - PROJETO CUPS
				llOk=zvalida_campos_produto()
				IF NOT llOk
					RETURN .f.
				ENDIF
				** FIMI: 24-05-2013		
				** FIM : 15-04-2015		
					

				** Sandra Ono -> 24-05-2013   	
				 lc_NCM = ALLTRIM(V_PRODUTOS_00.CLASSIF_FISCAL)    
				   	
				 lc_sql =  " Select NCM_NBS from TMP_TABELA_ALIQUOTA_IMPOSTO_ITEM  ALIQ where NCM_NBS =  ?lc_NCM"
					
				 IF USED("tmp_NCM")
					  USE IN tmp_NCM
				 ENDIF

				 f_select(lc_sql,"tmp_NCM")			   	
				   	
				 IF RECCOUNT("tmp_NCM") = 0
				   	
				   	   =MESSAGEBOX("O NCM (Classifica��o Fiscal) n�o foi encontrado na tabela Aliquota de Impostos das lojas. Verifique ! ",16,"Aten��o")
				   	   
				   	   RETURN .F.
				 ENDIF
				   	
				
				
			otherwise
				return .t.
		endcase
	endproc
enddefine

****
* PAULO DEVIDE - 04/08/2015
* override da classe pai (original)
* modifica��o de m�todos originais da .vcx
*/
DEFINE CLASS txt_stylenumber_edit as txt_stylenumber
	top = 60
	left = 290
	controlsource = "V_PRODUTOS_00.ERP_CUPS_STYLENUMBER"

	visible = .t.
	
	PROCEDURE when
		IF INLIST(ThisFormSet.p_Tool_Status,"I","A")

			IF ALLTRIM(cbo_segmento1.descricao)=="VAREJO"
				IF EMPTY(NVL(this.Value,''))
					RETURN .t.
				
				ELSE
				
					** Regra do Danilo
					** WAIT WINDOW "Style Number n�o pode mais ser alterado." &&"N�o � necess�rio o preenchimento deste campo para o segmento VAREJO"
					*** Danilo precisa alterar la no VMulti				
					
					WAIT WINDOW "OK!" nowait
					RETURN .T.
					**RETURN .f.					
					
				ENDIF
				

			ELSE
				IF INLIST(ThisFormSet.p_tool_status,'A')
					IF !EMPTY(NVL(this.Value,''))
						WAIT WINDOW "Style Number n�o pode mais ser alterado."
						RETURN .f.
					ENDIF
				ENDIF
			ENDIF
			
		ENDIF


		RETURN .T.
	ENDPROC

	PROCEDURE valid
		IF INLIST(ThisFormSet.p_Tool_Status,"I","A")

			IF !(ALLTRIM(cbo_segmento1.descricao)=="VAREJO") && Atacado ou Atacado/Varejo
				
				llOk = .t.
				lcMsgErr = ""
				
				TEXT TO lcSQL NOSHOW TEXTMERGE
					SELECT * FROM produtos 
					WHERE ERP_CUPS_STYLENUMBER='<<ALLTRIM(this.value)>>' 
				ENDTEXT
				
				f_select(lcSQL,"tmp_valida_StyleNumber")
				
				IF ThisFormSet.p_Tool_Status = "I" && inclus�o
					** N�o deveria existir, pois produto esta em modo inclus�o
					** e produto n�o foi incluido no banco
					IF RECCOUNT("tmp_valida_StyleNumber")>0
						lcMsgErr = "(I)-Style Number j� tem um PRODUTO associado" + CHR(13) + ;
									"PRODUTO = "+ALLTRIM(tmp_valida_StyleNumber.PRODUTO)
						llOk = .f.
					ENDIF
				ENDIF
				
				IF ThisFormSet.p_Tool_Status = "A" && altera��o
					** N�o deveria existir, pois produto esta em modo inclus�o
					** e produto n�o foi incluido no banco
					IF RECCOUNT("tmp_valida_StyleNumber")>0
						SELECT tmp_valida_StyleNumber
						SCAN 			
							IF !(ALLTRIM(tmp_valida_StyleNumber.PRODUTO) == ALLTRIM(V_PRODUTOS_00.PRODUTO))
								lcMsgErr = "(A)-Style Number j� tem um PRODUTO associado" + CHR(13) + ;
											"PRODUTO = "+ALLTRIM(tmp_valida_StyleNumber.PRODUTO)
								llOk = .f.
								EXIT
							ENDIF
						ENDSCAN
					ENDIF
				ENDIF
				
				IF llOk=.f. && erro - exibir mensagem e retornar
					MESSAGEBOX(lcMsgErr, 16,"AVISO")
					RETURN .f.
				ENDIF
				
			ENDIF
			
		ENDIF
		RETURN .t.
	
	ENDPROC

	PROCEDURE refresh
		** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")	
	ENDPROC
	
	PROCEDURE m_valida
		RETURN .t.
	ENDPROC
	
			
ENDDEFINE

***
* CHECKBOX PARA SELECIONAR SE � CONJUNTO OU N�O
*/
DEFINE CLASS chk_conjunto as checkbox
	caption = 'Conjunto?'
	autosize = .T.
	WIDTH = 192
	top = 86
	left = 305
	HEIGHT =  27
	enabled = .t.
	controlsource = "V_PRODUTOS_00.ERP_CUPS_CONJUNTO"
	visible  = .t.
	**backcolor =  RGB(64,128,128)

	PROCEDURE click
		IF INLIST(ThisFormSet.p_Tool_Status,"I","A")	
			IF V_PRODUTOS_00.ERP_CUPS_CONJUNTO	
			
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.Enabled = .t.
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.refresh
				
			ELSE

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.Enabled = .f.
				replace V_PRODUTOS_00.ERP_CUPS_COMPRIMENTO_BOTTOM WITH NULL
				replace V_PRODUTOS_00.ERP_CUPS_COMPOSICAO_BOTTOM WITH NULL
				replace V_PRODUTOS_00.ERP_CUPS_FORRO_BOTTOM WITH NULL
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.refresh

			ENDIF
		ENDIF
	ENDPROC

	PROCEDURE refresh
		** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")	
	ENDPROC
		
ENDDEFINE
				
				
DEFINE CLASS btdefprice as botao
	caption = 'Definir Pre�o Default'
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

			inppass3 = rbInputBox3( "Valor Default", "Pre�o Default para Tabelas", "", , , "!", , "")
			inppass3 = ALLTRIM(inppass3 )
			
		Endif	
		

	ENDPROC
	
ENDDEFINE		
		



DEFINE CLASS bt_estfilial as botao
	caption = 'Liberar Altera��o de Pre�o'
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
*!*			inppass = rbInputBox( "Digite a Senha", "Senha para altera��o de Pedido de Compra", "", , , "!", , "*")
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
*!*				MESSAGEBOX("Senha incorreta ou n�o autorizada")
*!*				RETURN .f.
*!*			endif


	inppass = rbInputBox( "Digite a Senha", "Senha para altera��o de Pedido de Compra", "", , , "!", , "*")
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

			inppass3 = rbInputBox3( "Valor Default", "Pre�o Default para Tabelas", "", , , "!", , "")
			inppass3 = ALLTRIM(inppass3 )
			
		Endif	
		
		
		RETURN .t.
	ELSE
		MESSAGEBOX("Senha incorreta ou n�o autorizada")
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
		return llRet && n�o obrigat�rio
	Endif
	
	select CURPROPPRODUTOS
	locate for propriedade='00027'

	if !found() 
		select (zold_area)
		return llRet && n�o obrigat�rio
	endif

	if empty(CURPROPPRODUTOS.valor_propriedade)
		select (zold_area)
		return llRet && n�o obrigat�rio
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
		lcMsg = "Data informada na propriedade DATA_ATIVACAO � inv�lida!"
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
		lcMsg = lcMsg + "Campo [Categoria] � obrigat�rio..."
	ENDIF
	
	** 2) valida campo Subcategoria
	IF EMPTY(NVL(v_produtos_00.cod_subcategoria,''))
		llRet = .f.
		lcMsg = lcMsg + CHR(13) + "Campo [Subcategoria] � obrigat�rio..."
	ENDIF

	** 3) valida tabela de pre�os preeenchida (campo Preco1)
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
		lcMsg = lcMsg + CHR(13) + "Obrigat�rio informar pre�o nas tabela(s) "+lcTabelas+"..."
	ENDIF
	


 	IF  INLIST(o_002006.p_tool_status,'I')
  	
	    		
		IF	o_002006.lx_Form1.lx_PageFrame1.Page3.opt_Padrao.Value  !=  o_002006.pp_tipo_codigo_barra       
		    	lcMsg = lcMsg + CHR(13) + "O C�digo de Barras deve ser o padr�o [OP��O: "+ALLTRIM(PADR(INT(o_002006.pp_tipo_codigo_barra),2,' ' ))+"]"
	    ENDIF
	    
		    		
	endif			    		

	***
	* VALIDA��ES PROJETO CUPS - INICIO 15-ABR-2015
	*/
	IF !EMPTY(NVL(v_produtos_00.ERP_CUPS_SEGMENTO,''))
	
		IF INLIST(v_produtos_00.ERP_CUPS_SEGMENTO,'000156','000157') && ATACADO ou VAREJO/ATACADO
 
			IF RECCOUNT("V_PRODUTOS_00_CORES_MAT")>o_002006.PP_QTD_CORES_ATACADO
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Quantidade m�xima de cores para segmento Atacado � "+ALLTRIM(TRANSFORM(o_002006.PP_QTD_CORES_ATACADO,"99"))
				**ELSE
				**WAIT WINDOW "OK - quantidade de cores adequada para o segmento"
			ENDIF
			
		ENDIF
		
		DO CASE
		CASE v_produtos_00.ERP_CUPS_SEGMENTO = '000155'	&& SOMENTE VAREJO
		
			IF ALLTRIM(v_produtos_00.tribut_origem) = '1'

				IF v_produtos_00.ENVIA_LOJA_ATACADO=.F.
					llRet = .f.
			    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO deve ser marcado para SEGMENTO VAREJO, pois origem � ESTRANGEIRA"
				ENDIF		
			
			ELSE
			
				IF v_produtos_00.ENVIA_LOJA_ATACADO=.T.
					llRet = .f.
			    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO n�o pode ser marcado para SEGMENTO VAREJO"
				ENDIF		
				
			ENDIF
			
			IF v_produtos_00.ENVIA_LOJA_VAREJO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_VAREJO deve ser marcado para SEGMENTO VAREJO"
			ENDIF		
		
		CASE v_produtos_00.ERP_CUPS_SEGMENTO = '000156'	&& SOMENTE ATACADO
		
			IF v_produtos_00.ENVIA_LOJA_VAREJO=.T.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_VAREJO n�o pode ser marcado para SEGMENTO ATACADO"
			ENDIF		
			
			IF v_produtos_00.ENVIA_LOJA_ATACADO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO deve ser marcado para SEGMENTO ATACADO"
			ENDIF		
		
			IF EMPTY(NVL(v_produtos_00.ERP_CUPS_STYLENUMBER,''))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigat�rio informar campo STYLENUMBER para SEGMENTO ATACADO"
			ENDIF
			
			
		CASE INLIST(v_produtos_00.ERP_CUPS_SEGMENTO,'000156','000157')	&& ATACADO/VAREJO - AMBOS
		
			IF v_produtos_00.ENVIA_LOJA_VAREJO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_VAREJO deve ser marcado para SEGMENTO ATACADO/VAREJO"
			ENDIF		
			
			IF v_produtos_00.ENVIA_LOJA_ATACADO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO deve ser marcado para SEGMENTO ATACADO/VAREJO"
			ENDIF		

			IF EMPTY(NVL(v_produtos_00.ERP_CUPS_STYLENUMBER,''))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigat�rio informar campo STYLENUMBER para SEGMENTO ATACADO"
			ENDIF

		ENDCASE

		
	ELSE
	
		llRet = .f.
    	lcMsg = lcMsg + CHR(13) + "Obrigat�rio informar o campo SEGMENTA��O..."
	
	ENDIF
	*\
	* VALIDA��ES PROJETO CUPS - FINAL 15-ABR-2015
	***

	
	 		
	SELECT (lnOldSelect)
	
	IF NOT EMPTY(lcMsg)
		MESSAGEBOX(lcMsg, 16,"Aviso")
	ELSE
		*** GERA��O DO C�DIGO DE BARRAS DO ATACADO
		*** SE ESTIVER COM O CAMPO ERP_CUPS_SEGMENTO VAZIO - GERA CODIGO DE BARRAS
		*** REGRA PARA GERAR O C�DIGO
		* SEGMENTO SER ATACADO OU ATACADO/VAREJO
		* ORIGEM DO PRODUTO = 1 - ESTRANGEIRA
		*/
		IF INLIST(v_produtos_00.ERP_CUPS_SEGMENTO,'000156','000157') OR ALLTRIM(v_produtos_00.tribut_origem) = '1'
			IF EMPTY(NVL(v_produtos_00.ERP_CUPS_CODEBAR_REF,''))
				IF "CUPS01" $ SET( "ClassLib" )
					** Ok, Registry carregado
				ELSE
					SET CLASSLIB TO CUPS01.vcx ADDITIVE
				ENDIF

				objCups = CREATEOBJECT("funcoes_cups")
				objCups.sequencial_codebar_ref = F_SEQUENCIAIS("PRODUTOS.ERP_CUPS_CODEBAR_REF", .t.)
				llRet = objCups.calcula_dv_ean13()
				
				IF !llRet
					MESSAGEBOX(objCups.err_message,16,"Aviso")
				ELSE
					lcCodebar_ref = objCups.codebar_ref_dv
					REPLACE v_produtos_00.ERP_CUPS_CODEBAR_REF WITH lcCodebar_ref
					REPLACE v_produtos_00.ERP_CUPS_CODEBAR_PB  WITH "1"+lcCodebar_ref
					REPLACE v_produtos_00.ERP_CUPS_CODEBAR_CX  WITH "9"+lcCodebar_ref
				ENDIF
			ENDIF
			
		ENDIF

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

DEFINE CLASS cPageImportado as Page

	PROCEDURE Activate
		thisform.refresh
	ENDPROC
	
ENDDEFINE

	
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
*!*		SET STEP ON 	
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
			
*****************>>>> ��������� DONA FOCA!!! QUE PREZEPADA HEIN! 						
*!*				TEXT TO lc_sql noshow
*!*					select distinct tab.CODIGO_TAB_PRECO, tab.tabela,  prd.PRODUTO, prd.PRECO1, prd.PRECO2,prd.PRECO3,prd.PRECO4, prd.ULT_ATUALIZACAO
*!*						from
*!*							PRODUTOS_PRECOS prd 
*!*					     LEFT JOIN TABELAS_PRECO tab
*!*					         ON PRD.CODIGO_TAB_PRECO = TAB.CODIGO_TAB_PRECO 
*!*								where prd.PRODUTO in
*!*								 ( select top 1 PRODUTO from PRODUTOS where DATA_CADASTRAMENTO  >= DATEADD(DAY,-1, GETDATE() ) )
*!*								and tab.INATIVO  = 0
*!*					ORDER BY 1			
*!*	            ENDTEXT

			*** CORRE��O DA QUERY -> PAULO DEVIDE -> 22-07-2015	
			TEXT TO lc_sql  NOSHOW TEXTMERGE
				select 
				   CODIGO_TAB_PRECO, tabela,  null as PRODUTO, cast(0 as numeric(14,2)) as PRECO1,  
				   	cast(0 as numeric(14,2)) as PRECO2, cast(0 as numeric(14,2)) as PRECO3, cast(0 as numeric(14,2)) as PRECO4, 
				   	getdate() as ULT_ATUALIZACAO
				from 
				  TABELAS_PRECO
				where
				  CODIGO_TAB_PRECO not in ('AT') AND INATIVO=0
			ENDTEXT
             
            f_select(lc_sql,"Preco_x" ) 
           
           IF RECCOUNT('Preco_x') < 1
*!*						TEXT TO lc_sql noshow
*!*							select distinct tab.CODIGO_TAB_PRECO, tab.tabela,  prd.PRODUTO, prd.PRECO1, prd.PRECO2,prd.PRECO3,prd.PRECO4, prd.ULT_ATUALIZACAO
*!*								from
*!*									PRODUTOS_PRECOS prd 
*!*							     LEFT JOIN TABELAS_PRECO tab
*!*							         ON PRD.CODIGO_TAB_PRECO = TAB.CODIGO_TAB_PRECO 
*!*										where prd.PRODUTO = '51020859'
*!*										and tab.INATIVO  = 0
*!*							ORDER BY 1			
*!*			            ENDTEXT

			TEXT TO lc_sql  NOSHOW TEXTMERGE
				select 
				   CODIGO_TAB_PRECO, tabela,  null as PRODUTO, cast(0 as numeric(14,2)) as PRECO1,  
				   	cast(0 as numeric(14,2)) as PRECO2, cast(0 as numeric(14,2)) as PRECO3, cast(0 as numeric(14,2)) as PRECO4, 
				   	getdate() as ULT_ATUALIZACAO
				from 
				  TABELAS_PRECO
				where
				  CODIGO_TAB_PRECO not in ('AT') AND INATIVO=0
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










