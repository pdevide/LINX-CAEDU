
**********************************************************
*        Ultimas alterações no Grupo Palma               *
**********************************************************
* Data :  27/05/2014
* Autor:  Sandra Ono
*              a) Inclusão Automatica de Tabelas com preço  Default
*              b) Validar se campo dá mensagem de Campo Inativo
*              c) Alteração para corrigir erro da linx para não alterar o preço liquido dos produtos


***  03/08/2013: Paulo Devide 
*!*					** VALIDAÇÃO DA PROPRIEDADE DATA_ATIVACAO (00027)
*!*				llOk=zvalida_prop_data_ativacao() &&PAULO DEVIDE - 03-09-2013
***         Verifica se a Data informada na propriedade DATA_ATIVACAO é válida!"



* 24-05-2013: Paulo Devide
*!*					** PAULO DEVIDE -> 24-05-2013
*!*					llOk=zvalida_campos_produto()
** 1) valida campo Categoria "Campo [Categoria] é obrigatório..."
** 2) valida campo Subcategoria "Campo [Subcategoria] é obrigatório..."
** 3) valida tabela de preços preeenchida (campo Preco1)


*!*	* 20/05/2014: Sandra Ono   
*!*	* Validação se o Produto esta devidamente cadastrado na Tabela NCM  (obrigação para calculo de imposto nas lojas)


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
	*- Nome do metodo/função que os objetos linx vão chamar.
	procedure metodo_usuario

		lparam xmetodo, xobjeto ,xnome_obj
		**SET STEP ON

		****
		* Quando clica em incluir, a pagina do Código de Barras, fica Enabled = .F. (desabilitada)
		* Ao cancelar ou salvar, volta o status ao normal, ThisFormSet.p_Tool_Status diferente de 'I'
		* 
		* PAULO DEVIDE - 06/04/16
		*/		
		IF !(ThisFormSet.p_Tool_Status == 'I')
			**
			thisformset.lx_form1.lx_pageframe1.page3.Enabled=.T.
			**
		ENDIF
		
		TRY 
			IF !(ThisFormSet.p_Tool_Status == 'A')
				**o_002006.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.T.
				ThisFormSet.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.T.
				ThisFormSet.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.Enabled=.T.
				ThisFormSet.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.ReadOnly=.F.
				
			ENDIF
				
		CATCH TO oErro1
			IF oErro1.errorno<>1925
				MESSAGEBOX(oErro1.message,16,"Aviso")
			ENDIF

		ENDTRY

				

		do case
		
			case UPPER(xmetodo) == 'USR_REFRESH'
					IF ThisFormSet.p_Tool_Status = "P" && modo pesquisa com dados na tela
						IF NOT thisformset.pp_palma_libera_bloq_produto
						
							TEXT TO lcSQL NOSHOW TEXTMERGE
								select pedido from COMPRAS_PRODUTO where produto = '<<ALLTRIM(V_PRODUTOS_00.PRODUTO)>>' and QTDE_ORIGINAL <> QTDE_ENTREGAR
							ENDTEXT
							F_SELECT(lcSQL,"tmpPedido01")

							IF RECCOUNT("tmpPedido01")>0 && existe pedido para este produto, não pode alterar as cores

								
								IF thisformset.pp_palma_bloq_botao_barcode=.T.
								
									WITH thisformset.lx_FORM1.lx_PAGEFRAME1.PAGE3 && Codigo de Barras
									
										llEnabled_Option = .opt_padrao.enabled
										llEnabled_spn_tam_pos = .spn_tam_pos.enabled
										llEnabled_botao1 = .botao1.enabled
										llEnabled_command1 = .command1.enabled
										llEnabled_ck_usa_cor = .ck_usa_cor.enabled
										llEnabled_ck_usa_tam = .ck_usa_tam.enabled
										
										.opt_padrao.enabled = .f.
										.spn_tam_pos.enabled = .f. 
										.botao1.enabled = .f.
										.command1.visible = .f.
										.ck_usa_cor.enabled = .f.
										.ck_usa_tam.enabled = .f.
										thisformset.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.p_tool_grid.Visible = .f.
										thisformset.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.Enabled = .f.
																		
									ENDWITH
														
							ELSE
								WITH thisformset.lx_FORM1.lx_PAGEFRAME1.PAGE3 && Codigo de Barras
								
									llEnabled_Option = .opt_padrao.enabled
									llEnabled_spn_tam_pos = .spn_tam_pos.enabled
									llEnabled_botao1 = .botao1.enabled
									llEnabled_command1 = .command1.enabled
									llEnabled_ck_usa_cor = .ck_usa_cor.enabled
									llEnabled_ck_usa_tam = .ck_usa_tam.enabled
									
									.opt_padrao.enabled = .t.
									.spn_tam_pos.enabled = .t. 
									.botao1.enabled = .t.
									.command1.visible = .t.
									.ck_usa_cor.enabled = .t.
									.ck_usa_tam.enabled = .t.

									thisformset.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.p_tool_grid.Visible = .T.
									thisformset.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.Enabled = .T.
																	
								ENDWITH

							ENDIF
							
						ENDIF && NOT thisformset.pp_palma_libera_bloq_produto --> paulo devide - 08-jun-2016
						
						
					ELSE
*!*							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.ReadOnly=.f.
*!*							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.t.
*!*							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.enabled = .t.
*!*							o_toolbar.Botao_filhas_inserir.Enabled= .T.
*!*							o_toolbar.botao_filhas_deletar.Enabled= .T.

					ENDIF
						
					
				ENDIF
				
				IF ThisFormSet.p_Tool_Status = "L"	
					WITH thisformset.lx_FORM1.lx_PAGEFRAME1.PAGE3 && Codigo de Barras
					
						llEnabled_Option = .opt_padrao.enabled
						llEnabled_spn_tam_pos = .spn_tam_pos.enabled
						llEnabled_botao1 = .botao1.enabled
						llEnabled_command1 = .command1.enabled
						llEnabled_ck_usa_cor = .ck_usa_cor.enabled
						llEnabled_ck_usa_tam = .ck_usa_tam.enabled
						
						.opt_padrao.enabled = .t.
						.spn_tam_pos.enabled = .t. 
						.botao1.enabled = .t.
						.command1.visible = .t.
						.ck_usa_cor.enabled = .t.
						.ck_usa_tam.enabled = .t.

														
					ENDWITH
				ENDIF
				
			case UPPER(xmetodo) == 'USR_INIT'

				** 20-jun-16 - checkbox area jeans
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('chk_area_jeans1', 'chk_area_jeans')
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.chk_area_jeans1.visible=.t.

				***
				* PROJETO CUPS - PAULO DEVIDE 01/ABR/15
				* (INICIO)
				*/
				thisformset.lx_form1.minbutton=.t.
				thisformset.lx_form1.maxbutton=.f.
				
*!*					Thisformset.lx_FORM1.lx_PAGEFRAME1.page1.pgDadosProdutos.Page1.ck_TIPO_PP.caption = "Área JEANS"
*!*					Thisformset.lx_FORM1.lx_PAGEFRAME1.page1.pgDadosProdutos.Page1.ck_TIPO_PP.FontBold = .t.
				
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
*!*					thisformset.lx_form1.lx_pageframe1.top = thisformset.lx_form1.lx_pageframe1.top + 30
				thisformset.lx_FORM1.lx_pageframe1.Height = thisformset.lx_FORM1.lx_pageframe1.Height + 40
				lnAlturaPanel = ThisFormset.Lx_form1.Lx_frame_3d1.height 
*!*					ThisFormset.Lx_form1.Lx_frame_3d1.height = lnAlturaPanel + 35
				
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
					.parent.lbl_construcao.caption = "Construção"
					.parent.lbl_construcao.top = 145 - 30 
					.parent.lbl_construcao.left = 10
					.parent.lbl_construcao.visible = .t.
				ENDWITH				

				***
				* CAMPO COMPOSIÇÃO BOTTOM
				*/
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('lbl_composicao_bottom', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('cbo_composicao_bottom1', 'cbo_composicao')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.cbo_composicao_bottom1
					.top = 36
					.left = 82
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_COMPOSICAO_BOTTOM"
					.visible = .t.
					.parent.lbl_composicao_bottom.caption = "Composição"
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
					.parent.lbl_composicao.caption = "Composição"
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
					.parent.lbl_preco_custo_estimado1.caption = "Prç Custo Est"
					.parent.lbl_preco_custo_estimado1.top = 295 - 30
					.parent.lbl_preco_custo_estimado1.left = 10
					.parent.lbl_preco_custo_estimado1.visible = .F.
				ENDWITH					

				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('lbl_segmento', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('cbo_segmento1', 'cbo_segmento')
				WITH thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.cbo_segmento1
					.top = 425
					.left = 103
					.width = 100
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_SEGMENTO"
					.visible = .t.
					.parent.lbl_segmento.caption = "Segmentação"
					.parent.lbl_segmento.top = 425
					.parent.lbl_segmento.left = 20
					.parent.lbl_segmento.visible = .t.
				ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.Shape8.Height = ;
					thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.Shape8.Height + 25
					
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('lbl_stylenumber', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('txt_stylenumber1', 'txt_stylenumber_edit')
				WITH thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.txt_stylenumber1
					.top = 425
					.left = 300
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_STYLENUMBER"
					.visible = .t.
					.parent.lbl_stylenumber.caption = "Style Number"
					.parent.lbl_stylenumber.top = 425
					.parent.lbl_stylenumber.left = 220
					.parent.lbl_stylenumber.visible = .t.
				ENDWITH				
				


				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('lbl_qtdPack', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('spnQtdPack1', 'spnQtdPack')
				WITH thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.spnQtdPack1
					.top = 425
					.left = 575
					.controlsource = "V_PRODUTOS_00.ERP_QTD_PACK"
					.enabled = .t.
					.readonly = .f.
					.visible = .t.
					.parent.lbl_qtdPack.caption = "Qtd. Pack"
					.parent.lbl_qtdPack.top = 425
					.parent.lbl_qtdPack.left = 520
					.parent.lbl_qtdPack.visible = .t.
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


				**** REORGANIZAÇÃO DE CAMPOS NA TELA PRINCIPAL DE PRODUTOS ***************************
				*CAMPO		ORDEM TOP ATUAL		ORDEM  TOP NOVO	OBJETOS
				*=====================================================================================
				*LINHA		8	180/177		 1	 12/9	LABEL_LINHA/TVLINHA
				*GRIFFE		7	156/153		 2	 36/33	LABEL_GRIFFE/TVGRIFFE
				*GRUPO		1	 12/9		 3	 60/57	Label_GRUPO_PRODUTO/tvGrupoProduto
				*SUBGRUPO	2	 36/33       4	 84/81	Label_SUBGRUPO_PRODUTO/tvSubGrupoProduto
				*CATEGORIA	3	 60/57       5	108/105	Lx_label6/cmb_Categoria_produto
				*SUB CAT.	4	 84/81       6 	132/129	Lx_label16/cmb_SubCategoria_produto
				*TIPO		5	108/105      7	156/153	Label_TIPO_PRODUTO/tvTipoProduto
				*COLEÇÃO	6	132/129  	 8	180/177	Label_COLECAO/tv_Colecao
				*/
*** não funciona - o linx em operação de alteração/inclusão remonta os campos da forma antiga				
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
*!*						* Coleção
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
				
				****
				* Exporta cursor de codigo de barras para o Excel
				* Paulo Devide -> 11/05/2016
				* o_002006.lx_FORM1.lx_PAGEFRAME1.pAGE3
				*/				
						
				thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE3.addobject('bt_report1', 'bt_report')
				WITH thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE3.bt_report1
					.height = 27
					.fontname = 'Arial'
					.Caption = 'Relatório Excel'
					.Left = 453
					.Top = 2
					.Width = 95
					.Visible = .T.
					.Enabled = .T.
					.anchor = 0
					.p_manter_baixo = .f.
					.p_manter_cima = .f.
					.p_manter_direita = .f.
					.p_manter_esquerda = .f.
					.p_muda_size = .f.
				ENDWITH
				
				

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


					IF NOT thisformset.pp_palma_libera_bloq_produto
						***
						* PAULO DEVIDE
						* SE TIVER PEDIDO COM O PRODUTO, NAO DEIXAR ALTERAR CORES
						*/
						TEXT TO lcSQL NOSHOW TEXTMERGE
							select pedido from COMPRAS_PRODUTO where produto = '<<ALLTRIM(V_PRODUTOS_00.PRODUTO)>>' and QTDE_ORIGINAL <> QTDE_ENTREGAR
						ENDTEXT
						F_SELECT(lcSQL,"tmpPedido01")

						IF RECCOUNT("tmpPedido01")>0 && existe pedido para este produto, não pode alterar as cores

							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.ReadOnly=.t.
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.f.
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.enabled = .f.

							o_toolbar.Botao_filhas_inserir.Enabled= .F.
							o_toolbar.botao_filhas_deletar.Enabled= .F.
							
							IF thisformset.pp_palma_bloq_botao_barcode=.T.
							
								WITH thisformset.lx_FORM1.lx_PAGEFRAME1.PAGE3 && Codigo de Barras
								
									llEnabled_Option = .opt_padrao.enabled
									llEnabled_spn_tam_pos = .spn_tam_pos.enabled
									llEnabled_botao1 = .botao1.enabled
									llEnabled_command1 = .command1.enabled
									llEnabled_ck_usa_cor = .ck_usa_cor.enabled
									llEnabled_ck_usa_tam = .ck_usa_tam.enabled
									
									.opt_padrao.enabled = .f.
									.spn_tam_pos.enabled = .f. 
									.botao1.enabled = .f.
									.command1.enabled = .f.
									.ck_usa_cor.enabled = .f.
									.ck_usa_tam.enabled = .f.

																	
								ENDWITH
														
							ENDIF
							
						ELSE
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.ReadOnly=.f.
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.t.
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.enabled = .t.
							o_toolbar.Botao_filhas_inserir.Enabled= .T.
							o_toolbar.botao_filhas_deletar.Enabled= .T.

						ENDIF
						
					ENDIF && NOT thisformset.pp_palma_libera_bloq_produto --> paulo devide - 08-jun-16
					


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
					****
					* Quando clica em incluir, a pagina do Código de Barras, fica Enabled = .F. (desabilitada)
					* Ao cancelar ou salvar, volta o status ao normal, ThisFormSet.p_Tool_Status diferente de 'I'
					* 
					* PAULO DEVIDE - 06/04/16
					*/		
				
					**
					thisformset.lx_form1.lx_pageframe1.page3.Enabled=.F.
					**

					*****WAIT WINDOW 'inclusão de botão com preço default'
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
					* VALORES DEFAULT - INCLUSÃO
					* PROJETO CUPS - PAULO DEVIDE
					*/
					
					thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.cbo_segmento1.VALUE = '000155' && VAREJO
					thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.cbo_segmento1.valid()


				ENDIF	


	   		case UPPER(xmetodo) == 'USR_VALID'			
			
			
				*** Sandra Ono - 27/05/2014 ****
				**** Alteração para corrigir erro da linx para não alterar 
				**** o preço liquido dos produtos
				 
				IF 'TX_PRECO1'$UPPER(xnome_obj)
		    		IF  INLIST(ThisFormSet.p_tool_status,'I','A')
		    		
   	     	    		replace 	preco_liquido1 with 0, ;
	 					preco_liquido2 with 0, ;
						preco_liquido3 with 0, ;
						preco_liquido4 with 0  IN V_PRODUTOS_00_PRECOS

		    		
				    		
		    		ENDIF
				ENDIF    		
				

				

										

			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

				** VALIDAÇÃO DA PROPRIEDADE DATA_ATIVACAO (00027)
				IF USED("CURPROPPRODUTOS")
					llOk=zvalida_prop_data_ativacao() &&PAULO DEVIDE - 03-09-2013
					IF NOT llOk
						RETURN .f.
					ENDIF
				Endif	
				
				** PAULO DEVIDE -> 24-05-2013
				** alterado em 15/04/2015 
				** inclusão de regras de validação para page do Atacado - PROJETO CUPS
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
				   	
				   	   =MESSAGEBOX("O NCM (Classificação Fiscal) não foi encontrado na tabela Aliquota de Impostos das lojas. Verifique ! ",16,"Atenção")
				   	   
				   	   RETURN .F.
				 ENDIF
				   	
				
				
			otherwise
				return .t.
		endcase
	endproc
enddefine

***
* botão para exportar código de barras para excel
* 11/05/2016
*/
DEFINE CLASS bt_report as botao
	caption = 'Relatório Excel'
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
		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Exportar Relatório de Código de Barras para o Excel?",292,"Aviso")=6
		
		IF llRet
			f_wait("Exportando dados para o Excel...")
			LOCAL lcArquivo as String
			lcArquivo = SYS(2023)+"\Produtos_Codigo_Barras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"
			
			zExporta_Excel("V_PRODUTOS_00_BARRA")
			
			f_wait()	
		ENDIF
		

	ENDPROC
	
	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L") 
	ENDPROC
	
ENDDEFINE

DEFINE CLASS spnQtdPack as spinner
	WIDTH = 92
	top = 425
	left = 520
	HEIGHT =  24
	enabled = .F.
	visible  = .t.


	PROCEDURE when
		RETURN V_PRODUTOS_00.sortimento_tamanho
	ENDPROC
	
	PROCEDURE valid
		

	ENDPROC
	
*!*		PROCEDURE refresh
*!*			** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
*!*			this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L") 
*!*		ENDPROC
	
ENDDEFINE


***
* Função para exportar cursor para Excel
* 11/05/2016
*/
FUNCTION zExporta_Excel
PARAMETERS lcCursor
** Formata cursor no excel
lcOldPoint = SET("Point")
lcOldSeparator = SET("Separator")

SET SEPARATOR TO "."
SET POINT TO ","

LOCAL oExcel as Object
LOCAL lnVez as Integer
oExcel = CREATEOBJECT("Excel.application")
FOR lnVez=1 TO 1 && lcCursor1, lcCursor2, lcCursor3 (3 abas)

	WITH oExcel

		IF lnVez=1
			.Application.ErrorCheckingOptions.BackgroundChecking = .f.
			.SheetsInNewWorkbook = 1 &&4 && quantas sheets vai criar dentro do workbook = 1
			.workbooks.Add
			.Sheets(1).Name = lcCursor
		ENDIF

		lcTab = icase(lnVez=1,lcCursor,lnVez=2,lcCursor2,lcCursor3)
		
		SELECT (lcTab)
		.Sheets(lnVez).Select
		
		.visible = .f.
		
		** formata as celulas no excel, conforme se tipo no cursor
		lcColsDateFormat = ""
		lcColsNumeric = ""
		
		lnFields = AFIELDS(laFields,lcTab)
		FOR lnCount=1 TO ALEN(laFields,1)
			
			.Cells(1,lnCount).Select
			lcAdress = SUBSTR(.ActiveCell.Address,2,ATC("$",.ActiveCell.Address,2)-2)
			.Columns(lcAdress+":"+lcAdress).Select
			
			DO CASE
				CASE INLIST(laFields[lnCount,2],'C','M','V') && caracter
					.Selection.NumberFormat = "@" && formata a celula para TEXTO
					
				CASE laFields[lnCount,2] = 'Y' && moeda
					.Selection.NumberFormat = "_(* #,##0.00_);_(* (#,##0.00);_(* ""-""??_);_(@_)"
					
				CASE laFields[lnCount,2] = 'D' && Date
				    .Selection.NumberFormat = "@" &&"m/d/yyyy"
					lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";D," 

				CASE laFields[lnCount,2] = 'T' && Datetime
			    	.Selection.NumberFormat = "@" &&"d/m/yy h:mm;@"
					lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";T," 
			    	
				CASE laFields[lnCount,2] = 'B' && Double (Numeric)
					 lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
					 .Selection.NumberFormat = lcMascara

				CASE laFields[lnCount,2] = 'F' && Float (Numeric)
					 lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
					 .Selection.NumberFormat = lcMascara

				CASE laFields[lnCount,2] = 'I' && Inteiro
					.Selection.NumberFormat = "#,##0"
					
				CASE laFields[lnCount,2] = 'L' && Logico (Verdadeiro/Falso)
					.Selection.NumberFormat = "General"

				CASE laFields[lnCount,2] = 'N' && Numeric
					 lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
					 .Selection.NumberFormat = lcMascara
					  	
				OTHERWISE
					.Selection.NumberFormat = "General"
			ENDCASE

			IF INLIST(laFields[lnCount,2],"B","F","I","N") && ALINHAMENTO A DIREITA DA CELULA numericos
			
			    With .Selection
			        .HorizontalAlignment = -4152
			        .VerticalAlignment = -4107
			        .WrapText = .F.
			        .Orientation = 0
			        .AddIndent = .F.
			        .IndentLevel = 0
			        .ShrinkToFit = .F.
			        .ReadingOrder = -5002
			        .MergeCells = .F.
			    Endwith		
			    
			    lcColsNumeric = lcColsNumeric + lcAdress + "," 
			    
			ENDIF
					
			.cells(1,lnCount).Select
			.Selection.NumberFormat = "@" && Formata a célula de cabeçalho (nome da coluna) como texto
		    With .Selection.Interior
		        .Pattern = 1
		        .PatternColorIndex = -4105
		        .Color = 65535
		        .TintAndShade = 0
		        .PatternTintAndShade = 0
		    EndWith
		    .Selection.Font.Bold = .t.

			.cells(1,lnCount).value = PROPER(laFields[lnCount,1])
			
			
		ENDFOR

		SELECT (lcTab)
		lcArqtmp = "curtmp"+SYS(2015)+".txt"
		lcArqtmp = SYS(2023)+"\"+lcArqtmp
		COPY TO (lcArqtmp) DELIMITED WITH tab
		
		lcStrArq = FILETOSTR(lcArqtmp)
		_cliptext = lcStrArq
		
		.cells(2,1).select
		.ActiveSheet.Paste

		.Cells.Select
	    .Cells.EntireColumn.AutoFit
	    
	    .Cells(1,1).select
		.Application.WindowState = -4137    	
		
		DELETE FILE (lcArqtmp)
		_cliptext = ""

		** Formatação de campo Date e Datetime
		IF NOT EMPTY(lcColsDateFormat)
			lcColsDateFormat = LEFT(lcColsDateFormat,LEN(lcColsDateFormat)-1) && tira a ultima virgula
			lnCols = GETWORDCOUNT(lcColsDateFormat,",")
			FOR lnCount=1 TO lnCols 
				lcInfoColuna = GETWORDNUM(lcColsDateFormat,lnCount,",")
				lcColuna = GETWORDNUM(lcInfoColuna,1,";")
				lcTipoColuna = GETWORDNUM(lcInfoColuna,2,";")
				.Columns(lcColuna+":"+lcColuna).Select		

				DO CASE
					CASE lcTipoColuna = "D"			
						.Selection.NumberFormat = "m/d/yyyy"
					CASE lcTipoColuna = "T"			
						.Selection.NumberFormat = "d/m/yy h:mm;@"
				ENDCASE
				
			ENDFOR
		ENDIF
		
		** Tratamento das colunas numéricas
		IF NOT EMPTY(lcColsNumeric)
			lcColsNumeric = LEFT(lcColsNumeric ,LEN(lcColsNumeric)-1) && tira a ultima virgula
			lnCols = GETWORDCOUNT(lcColsNumeric,",")
			FOR lnCount=1 TO lnCols 
				lcColuna = GETWORDNUM(lcColsNumeric,lnCount,",")
				
				lnLinhaI = 2
				lnLinhaF = RECCOUNT(lcTab)+1

				FOR lnLinhaI = 2 TO lnLinhaF 
					lnCelula = .RANGE(lcColuna+ALLTRIM(TRANSFORM(lnLinhaI))).VALUE 
	  				.RANGE(lcColuna+ALLTRIM(TRANSFORM(lnLinhaI))).VALUE = val(ALLTRIM(TRANSFORM(lnCelula)))
				ENDFOR
							
			ENDFOR
		ENDIF
		

		lnLinhaI = 2
		lnLinhaF = RECCOUNT(lcTab)+1

		FOR lnLinhaI = 2 TO lnLinhaF 
		
			lcCelula = .RANGE("A"+ALLTRIM(TRANSFORM(lnLinhaI))).VALUE 
			IF lcCelula = "P" && parcela - pinta a linha de cinza
			    .RANGE("A"+ALLTRIM(TRANSFORM(lnLinhaI))).select
			    .Application.Goto("R"+ALLTRIM(TRANSFORM(lnLinhaI))+"C1:R"+ALLTRIM(TRANSFORM(lnLinhaI))+"C102")
			    With .Selection.Interior
			        .Pattern = 1
			        .PatternColorIndex = -4105
			        .Color = 15395562
			        .TintAndShade = 0
			        .PatternTintAndShade = 0
			    Endwith
			ENDIF
			
		ENDFOR
		
		.cells(1,1).select	

	    .Range("A1").Select
	    .Selection.AutoFilter
	    .Range("A2").Select
	    .ActiveWindow.FreezePanes = .t.

	ENDWITH
	
ENDFOR


oExcel.visible = .t.

SET SEPARATOR TO &lcOldSeparator.
SET POINT TO &lcOldPoint.
RELEASE oExcel

RETURN
ENDFUNC


****
* PAULO DEVIDE - 04/08/2015
* override da classe pai (original)
* modificação de métodos originais da .vcx
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
					** WAIT WINDOW "Style Number não pode mais ser alterado." &&"Não é necessário o preenchimento deste campo para o segmento VAREJO"
					*** Danilo precisa alterar la no VMulti				
					
					WAIT WINDOW "OK!" nowait
					RETURN .T.
					**RETURN .f.					
					
				ENDIF
				

			ELSE
				IF INLIST(ThisFormSet.p_tool_status,'A')
					IF !EMPTY(NVL(this.Value,''))
*!*							WAIT WINDOW "Style Number não pode mais ser alterado."
*!*							RETURN .f.
						WAIT WINDOW "OK!" nowait
						RETURN .T.
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
				
				IF ThisFormSet.p_Tool_Status = "I" && inclusão
					** Não deveria existir, pois produto esta em modo inclusão
					** e produto não foi incluido no banco
					IF RECCOUNT("tmp_valida_StyleNumber")>0
						lcMsgErr = "(I)-Style Number já tem um PRODUTO associado" + CHR(13) + ;
									"PRODUTO = "+ALLTRIM(tmp_valida_StyleNumber.PRODUTO)
						llOk = .f.
					ENDIF
				ENDIF
				
				IF ThisFormSet.p_Tool_Status = "A" && alteração
					** Não deveria existir, pois produto esta em modo inclusão
					** e produto não foi incluido no banco
					IF RECCOUNT("tmp_valida_StyleNumber")>0
						SELECT tmp_valida_StyleNumber
						SCAN 			
							IF !(ALLTRIM(tmp_valida_StyleNumber.PRODUTO) == ALLTRIM(V_PRODUTOS_00.PRODUTO))
								lcMsgErr = "(A)-Style Number já tem um PRODUTO associado" + CHR(13) + ;
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
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")	
	ENDPROC
	
	PROCEDURE m_valida
		RETURN .t.
	ENDPROC
	
			
ENDDEFINE

** 20-jun-16 checkbox area jeans
DEFINE CLASS chk_area_jeans as checkbox
	caption = 'Área Jeans?'
	autosize = .T.
	WIDTH = 192
	top = 397
	left = 520
	HEIGHT =  27
	enabled = .t.
	controlsource = "V_PRODUTOS_00.ERP_AREA_JEANS"
	visible  = .t.
	**backcolor =  RGB(64,128,128)

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")	
	ENDPROC
		
ENDDEFINE
** 20-jun-16 checkbox area jeans

***
* CHECKBOX PARA SELECIONAR SE É CONJUNTO OU NÃO
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
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")	
	ENDPROC
		
ENDDEFINE
				
				
DEFINE CLASS btdefprice as botao
	caption = 'Definir Preço Default'
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

			inppass3 = rbInputBox3( "Valor Default", "Preço Default para Tabelas", "", , , "!", , "")
			inppass3 = ALLTRIM(inppass3 )
			
		Endif	
		

	ENDPROC
	
ENDDEFINE		
		



DEFINE CLASS bt_estfilial as botao
	caption = 'Liberar Alteração de Preço'
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
*!*			inppass = rbInputBox( "Digite a Senha", "Senha para alteração de Pedido de Compra", "", , , "!", , "*")
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
*!*				MESSAGEBOX("Senha incorreta ou não autorizada")
*!*				RETURN .f.
*!*			endif


	inppass = rbInputBox( "Digite a Senha", "Senha para alteração de Pedido de Compra", "", , , "!", , "*")
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

			inppass3 = rbInputBox3( "Valor Default", "Preço Default para Tabelas", "", , , "!", , "")
			inppass3 = ALLTRIM(inppass3 )
			
		Endif	
		
		
		RETURN .t.
	ELSE
		MESSAGEBOX("Senha incorreta ou não autorizada")
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
		return llRet && não obrigatório
	Endif
	
	select CURPROPPRODUTOS
	locate for propriedade='00027'

	if !found() 
		select (zold_area)
		return llRet && não obrigatório
	endif

	if empty(CURPROPPRODUTOS.valor_propriedade)
		select (zold_area)
		return llRet && não obrigatório
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
		lcMsg = "Data informada na propriedade DATA_ATIVACAO é inválida!"
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
	
	****
	* PAULO DEVIDE - 06/ABR/16
	* VALIDAÇÃO DOS CAMPOS FABRICANTE E REFERENCIA DO FABRICANTE
	*/
	IF NVL(v_produtos_00.revenda,.f.)=.t.
		IF EMPTY(NVL(v_produtos_00.FABRICANTE,''))
			llRet = .f.
			lcMsg = lcMsg + CHR(13) + "Campo [FABRICANTE] é obrigatório para REVENDA..."
		ENDIF
		IF EMPTY(NVL(v_produtos_00.REFER_FABRICANTE,''))
			llRet = .f.
			lcMsg = lcMsg + CHR(13) + "Campo [REFERÊNCIA FABRICANTE] é obrigatório para REVENDA..."
		ENDIF
	ENDIF
	
	** 1) valida campo Categoria
	IF EMPTY(NVL(v_produtos_00.cod_categoria,''))
		llRet = .f.
		lcMsg = lcMsg + CHR(13) + "Campo [Categoria] é obrigatório..."
	ENDIF
	
	** 2) valida campo Subcategoria
	IF EMPTY(NVL(v_produtos_00.cod_subcategoria,''))
		llRet = .f.
		lcMsg = lcMsg + CHR(13) + "Campo [Subcategoria] é obrigatório..."
	ENDIF

	** 3) valida tabela de preços preeenchida (campo Preco1)
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
		lcMsg = lcMsg + CHR(13) + "Obrigatório informar preço nas tabela(s) "+lcTabelas+"..."
	ENDIF
	


 	IF  INLIST(o_002006.p_tool_status,'I')
  	
	    		
		IF	o_002006.lx_Form1.lx_PageFrame1.Page3.opt_Padrao.Value  !=  o_002006.pp_tipo_codigo_barra       
		    	lcMsg = lcMsg + CHR(13) + "O Código de Barras deve ser o padrão [OPÇÃO: "+ALLTRIM(PADR(INT(o_002006.pp_tipo_codigo_barra),2,' ' ))+"]"
	    ENDIF
	    
		    		
	endif			    		

	***
	* VALIDAÇÕES PROJETO CUPS - INICIO 15-ABR-2015
	*/
	
	****
	* obrigatório informar campo UNIDADE
	*/				
	IF EMPTY(NVL(v_produtos_00.UNIDADE,''))
		llRet = .f.
    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo UNIDADE"
	ENDIF				
	
	IF EMPTY(NVL(v_produtos_00.tribut_origem,""))	
		llRet = .f.
    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo ORIGEM"
	ENDIF



	IF !EMPTY(NVL(v_produtos_00.ERP_CUPS_SEGMENTO,''))
	
		IF INLIST(v_produtos_00.ERP_CUPS_SEGMENTO,'000156','000157') && ATACADO ou VAREJO/ATACADO
 
			IF RECCOUNT("V_PRODUTOS_00_CORES_MAT")>o_002006.PP_QTD_CORES_ATACADO
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Quantidade máxima de cores para segmento Atacado é "+ALLTRIM(TRANSFORM(o_002006.PP_QTD_CORES_ATACADO,"99"))
				**ELSE
				**WAIT WINDOW "OK - quantidade de cores adequada para o segmento"
			ENDIF
			
		ENDIF
		
		DO CASE
		CASE v_produtos_00.ERP_CUPS_SEGMENTO = '000155'	&& SOMENTE VAREJO
		
			IF ALLTRIM(v_produtos_00.tribut_origem) = '1'

				IF !ZAUTORIZA_PRODUTO()
					IF v_produtos_00.ENVIA_LOJA_ATACADO=.F.
						llRet = .f.
				    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO deve ser marcado para SEGMENTO VAREJO, pois origem é ESTRANGEIRA"
					ENDIF	
					
					****
					* obrigatório informar STYLE NUMBER para produtos de origem estrangeira, vai ter contrato {10-09-2015}
					*/				
					IF EMPTY(NVL(v_produtos_00.ERP_CUPS_STYLENUMBER,''))
						llRet = .f.
				    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo STYLENUMBER para SEGMENTO ATACADO"
					ENDIF	
					
					****
					* obrigatório informar campo PESO
					*/				
					IF EMPTY(NVL(v_produtos_00.PESO,0))
						llRet = .f.
				    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo PESO"
					ENDIF					
				ENDIF
												
			
			ELSE
			
				IF v_produtos_00.ENVIA_LOJA_ATACADO=.T.
					llRet = .f.
			    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO não pode ser marcado para SEGMENTO VAREJO"
				ENDIF		
				
			ENDIF
			
			IF v_produtos_00.ENVIA_LOJA_VAREJO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_VAREJO deve ser marcado para SEGMENTO VAREJO"
			ENDIF		
		
		CASE v_produtos_00.ERP_CUPS_SEGMENTO = '000156'	&& SOMENTE ATACADO
		
			IF v_produtos_00.ENVIA_LOJA_VAREJO=.T.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_VAREJO não pode ser marcado para SEGMENTO ATACADO"
			ENDIF		
			
			IF v_produtos_00.ENVIA_LOJA_ATACADO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO deve ser marcado para SEGMENTO ATACADO"
			ENDIF		
		
			IF EMPTY(NVL(v_produtos_00.ERP_CUPS_STYLENUMBER,''))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo STYLENUMBER para SEGMENTO ATACADO"
			ENDIF

			****
			* obrigatório informar campo PESO
			*/				
			IF EMPTY(NVL(v_produtos_00.PESO,0))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo PESO"
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
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo STYLENUMBER para SEGMENTO ATACADO"
			ENDIF
			
			****
			* obrigatório informar campo PESO
			*/				
			IF EMPTY(NVL(v_produtos_00.PESO,0))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo PESO"
			ENDIF				
			

		ENDCASE

		
	ELSE
	
		llRet = .f.
    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar o campo SEGMENTAÇÃO..."
	
	ENDIF
	
	
	*** 
	* CAMPOS DA ABA IMPORTADO que são obrigatórios para Integrar com o Sistema IMPORT SYS
	*/
	IF llRet AND ALLTRIM(v_produtos_00.tribut_origem) = '1' 
		
		lcMsg = ""
		IF !ZAUTORIZA_PRODUTO()
			** PESO
			IF EMPTY(NVL(v_produtos_00.PESO,0))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo PESO"
			ENDIF		
			
			** STYLE NUMBER
			IF EMPTY(NVL(v_produtos_00.ERP_CUPS_STYLENUMBER,''))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo STYLENUMBER para SEGMENTO ATACADO"
			ENDIF	

			DIMENSION laDominio0[5,2]
			laDominio0[1,1]="PRODUTO"
			laDominio0[2,1]="CONSTRUCAO"
			laDominio0[3,1]="COMPRIMENTO"
			laDominio0[4,1]="FORRO"
			laDominio0[5,1]="COMPOSICAO"
			
			laDominio0[1,2]=NVL(v_produtos_00.ERP_CUPS_PRODUTO,"")
			laDominio0[2,2]=NVL(v_produtos_00.ERP_CUPS_CONTRUCAO,"")
			laDominio0[3,2]=NVL(v_produtos_00.ERP_CUPS_COMPRIMENTO,"")
			laDominio0[4,2]=NVL(v_produtos_00.ERP_CUPS_FORRO,"")
			laDominio0[5,2]=NVL(v_produtos_00.ERP_CUPS_COMPOSICAO,"")
			
			FOR iqq=1 TO 5
				IF EMPTY(laDominio0[iqq,2])
					llRet = .f.
					lcMsg = lcMsg + CHR(13) + "Obrigatório preencher o campo "+PROPER(laDominio0[iqq,1])+" na aba Importado" + CHR(13)
				ENDIF
			ENDFOR		
			
			** GRIFFE
			tcGriffe = ALLTRIM(NVL(v_produtos_00.GRIFFE,""))
			F_SELECT("select * from produtos_griffes where griffe = '"+tcGriffe+"'","tmpGriffe01")
			
			IF RECCOUNT("tmpGriffe01")=0
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Valor do campo GRIFFE não localizado"
			ENDIF	
			
			
			** LINHA
			tcLinha = ALLTRIM(NVL(v_produtos_00.LINHA,""))
			F_SELECT("select * from produtos_linhas where linha = '"+tcLinha+"'","tmpLinha01")
			
			IF RECCOUNT("tmpLinha01")=0
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Valor do campo LINHA não localizado"
			ENDIF	
			
			** GRADE
			tcGrade = ALLTRIM(NVL(v_produtos_00.GRADE,""))
			F_SELECT("select * from produtos_tamanhos where grade = '"+tcGrade+"'","tmpGrade01")
			
			IF RECCOUNT("tmpGrade01")=0
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Grade não localizada. Obrigatório selecionar um Tamanho/Grade"
			ENDIF	
			
			** SUPPLIER
			tcSupplier = ALLTRIM(NVL(v_produtos_00.ERP_CUPS_SUPPLIER,""))
			F_SELECT("select * from fornecedores where clifor = '"+tcSupplier+"'","tmpSupplier01")
			
			IF RECCOUNT("tmpSupplier01")=0
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Fabricante/Supplier não localizado."
			ENDIF	
		ENDIF
						
	ENDIF
	
	
	
	*** 
	* Se estiver tudo OK, verifica se foram preenchidos as Descrições para uso na DI para produtos importados
	*/
	
	IF llRet AND ALLTRIM(v_produtos_00.tribut_origem) = '1'
		lcMsg = ""
		IF !ZAUTORIZA_PRODUTO()
			DIMENSION laDominio1[7,2]
			laDominio1[1,1]="GRIFFE"
			laDominio1[2,1]="LINHA"
			laDominio1[3,1]="PRODUTO"
			laDominio1[4,1]="CONSTRUCAO"
			laDominio1[5,1]="COMPRIMENTO"
			laDominio1[6,1]="FORRO"
			laDominio1[7,1]="COMPOSICAO"
			*
			laDominio1[1,2]=NVL(v_produtos_00.GRIFFE,"")
			laDominio1[2,2]=NVL(v_produtos_00.LINHA,"")
			laDominio1[3,2]=NVL(v_produtos_00.ERP_CUPS_PRODUTO,"")
			laDominio1[4,2]=NVL(v_produtos_00.ERP_CUPS_CONTRUCAO,"")
			laDominio1[5,2]=NVL(v_produtos_00.ERP_CUPS_COMPRIMENTO,"")
			laDominio1[6,2]=NVL(v_produtos_00.ERP_CUPS_FORRO,"")
			laDominio1[7,2]=NVL(v_produtos_00.ERP_CUPS_COMPOSICAO,"")
			
			FOR iqq=1 TO 7
				IF !zverifica_descricao_importado(laDominio1[iqq,1],laDominio1[iqq,2])
					llRet = .f.
					lcMsg = lcMsg + CHR(13) + "Obrigatório preencher o campo Descrição de Importado para "+laDominio1[iqq,1]+" = "+laDominio1[iqq,2] + CHR(13)
				ENDIF
			ENDFOR
		ENDIF
		
	ENDIF
	
	*\
	* VALIDAÇÕES PROJETO CUPS - FINAL 15-ABR-2015
	***

	
	 		
	SELECT (lnOldSelect)
	
	IF NOT EMPTY(lcMsg)
		MESSAGEBOX(lcMsg, 16,"Aviso")
	ELSE
		*** GERAÇÃO DO CÓDIGO DE BARRAS DO ATACADO
		*** SE ESTIVER COM O CAMPO ERP_CUPS_SEGMENTO VAZIO - GERA CODIGO DE BARRAS
		*** REGRA PARA GERAR O CÓDIGO
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

FUNCTION zverifica_descricao_importado
	PARAMETERS tcDominio, tcValor
	LOCAL llOk as Boolean, lnArea as Integer, lcSQL as String
	lnArea = SELECT()
	llOk = .t.

	lcSQL = ""
	
	DO CASE
	CASE tcDominio = "GRIFFE"
		lcSQL = "SELECT ERP_CUPS_DESCRICAO_IMPORTACAO FROM PRODUTOS_GRIFFES WHERE GRIFFE = '"+ALLTRIM(tcValor)+"'"
	CASE tcDominio = "LINHA"
		lcSQL = "SELECT ERP_CUPS_DESCRICAO_IMPORTACAO FROM PRODUTOS_LINHAS WHERE LINHA = '"+ALLTRIM(tcValor)+"'"
	CASE INLIST(tcDominio,"PRODUTO","CONSTRUCAO","COMPRIMENTO","FORRO","COMPOSICAO")
		lcSQL = "SELECT ERP_CUPS_DESCRICAO_IMPORTACAO FROM CAEDU_LISTA_COMBO WHERE codigo = '"+ALLTRIM(tcValor)+"' and desc_dominio='"+tcDominio+"'"

	ENDCASE
	
	IF EMPTY(lcSQL)
		llOk = .f.
	ELSE
		f_select(lcSQL,"tmpDescImportado")
		
		** Se estiver vazio ou nulo, retorna False 
		IF EMPTY(NVL(tmpDescImportado.ERP_CUPS_DESCRICAO_IMPORTACAO,""))
			llOk = .f.
		ENDIF
		 
	ENDIF
	
	
	SELECT (lnArea)
	
	RETURN llOk
ENDFUNC


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
			
*****************>>>> ÉÉÉÉÉÉÉÉÉ DONA FOCA!!! QUE PREZEPADA HEIN! 						
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

			*** CORREÇÃO DA QUERY -> PAULO DEVIDE -> 22-07-2015	
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

FUNCTION ZAUTORIZA_PRODUTO
	lnArea = SELECT()
	SELECT * FROM CURPROPPRODUTOS WITH (BUFFERING=.T.) ;
		WHERE ALLTRIM(PROPRIEDADE) = "00078" ;
		INTO CURSOR tmp_autoriza
	llRet = UPPER(ALLTRIM(NVL(tmp_autoriza.valor_propriedade,"")))=="SIM"		
	SELECT (lnArea)
	IF llRet
		WAIT WINDOW NOWAIT "Autorização para Transferência Atacado foi liberada!"
	ENDIF
	
	RETURN llRet
ENDFUNC








