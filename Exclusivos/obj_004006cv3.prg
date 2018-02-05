*****************************************************************************
** SANDRA ONO - 27/05/2014
*****************************************************************************
*****************************************************************************
***  CONSISTENCIA DE ITENS DE PACK (Itens de Pedido x Itens de Pack)
***  Consiste grade de packs, qtdes e Itens de Pedido
******************************************************************************

******************************************************************************
** PAULO DEVIDE 15-08-2013
**  <uda o valor do campo DATA OTB na inclusão no caso de haver
**  alteração no campo entrega
******************************************************************************

******************************************************************************
*** PAULO DEVIDE - 14-08-2013
*** INCLUSÃO CAMPO DATA OTB
* REGRA -  NA OPERAÇÃO DE INCLUSÃO, O VALOR DO
* CAMPO DATA É IGUAL AO CAMPO DATA DE ENTREGA
******************************************************************************

******************************************************************************
** PAULO DEVIDE -> 21-05-2013 (botao pra imprimir pedido em inglês)
******************************************************************************
** PAULO DEVIDE -> 21-05-2013*** Inclui Campo Data OTB
******************************************************************************
** PAULO DEVIDE - muda o valor do campo DATA OTB na inclusão no caso de haver
******************************************************************************
** PAULO DEVIDE -> 22-05-2013 Pedido Excel
******************************************************************************
*******************************************************************************
****   Sandra Ono   -  20/04/2013
*********** Verfica a semana (compras)
**********  Solicita senha para alterar limite de entrega
*********** Senha de Diretor e seha de Gerente
********************************************************************************
*****************************************************************************************
****   ????   -  Anterior a   2013
*********** Solicita a senha para alterar Pedidos com alguma entrega mesmo que parcial
********************************************************************************


*- Definindo a classe do objeto de entrada que sera criado na Form.
Define Class obj_entrada As Custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	Procedure metodo_usuario
		Lparam xmetodo, xobjeto, xnome_obj

		**thisformset.lx_form1.lx_pageframe1.Page1.rotulo1.caption = xmetodo
		
		Do Case
			CASE Upper(xmetodo) == 'USR_REFRESH' && cups
				*** 
				* A regra abaixo foi suspensa.
				* Regra => Se v_compras_01.ERP_CUPS_EMBARQUE_LIBERADO = .T.
				* Na alteração Liberar acesso somente para cancelamento dos
				* Itens do pedido
				*/			
				IF .f.
					ThisFormSet.LX_Form1.Lockscreen=.T.
					IF ThisFormSet.p_Tool_Status="A" 
						IF v_compras_01.ERP_CUPS_EMBARQUE_LIBERADO
							FOR EACH oPages IN thisformset.lx_form1.lx_pageframe1.Pages		
								IF ALLTRIM(oPages.Caption) = [\<Cancelados]
									oPages.Enabled=.t.
									thisformset.lx_form1.lx_pageframe1.ActivePage=oPages.PageOrder
								ELSE
									oPages.Enabled=.f.
								ENDIF
							ENDFOR
						ENDIF
					ELSE	
						FOR EACH oPages IN thisformset.lx_form1.lx_pageframe1.Pages					
							IF INLIST(ALLTRIM(oPages.Caption),[Alocação],[Requisições])
								IF oPages.Caption = [Requisições]
									IF !INLIST(ThisFormSet.p_Tool_Status,"L","C","P")
										oPages.Enabled=.t.
									ELSE
										oPages.Enabled=.f.
									ENDIF
									
								ELSE
									oPages.Enabled=.f.
								ENDIF
							ELSE
								oPages.Enabled=.t.
							ENDIF
						ENDFOR
					ENDIF
					ThisFormSet.LX_Form1.Lockscreen=.F.
				ENDIF
				
			CASE Upper(xmetodo) == 'USR_INCLUDE_AFTER'
				thisformset.lx_form1.lx_pageframe1.Page1.tx_data_otb1.value = DATE() && Valor default para data OTB

				IF ThisFormSet.p_Tool_Status="I" && Somente na inclusão

					Select v_Compras_01
					Replace FILIAL_A_ENTREGAR With RTRIM(o_004006.pp_filial_padrao),;
						FILIAL_COBRANCA   With 'MATRIZ',;
						FILIAL_A_FATURAR  With RTRIM(o_004006.pp_filial_padrao)

					thisformset.lx_form1.lx_pageframe1.Page1.cmb_FILIAL_A_ENTREGAR.VALUE =  RTRIM(o_004006.pp_filial_padrao)
					thisformset.lx_form1.lx_pageframe1.Page1.cmb_FILIAL_A_FATURAR.VALUE =  RTRIM(o_004006.pp_filial_padrao)

				endif




				** PAULO DEVIDE - muda o valor do campo DATA OTB na inclusão no caso de haver
				** alteração no campo entrega - 15-08-2013
			CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TX_ENTREGA_UNICA'

				IF ThisFormSet.p_Tool_Status="I" && Somente na inclusão
					thisformset.lx_form1.lx_pageframe1.Page1.tx_data_otb1.value = xobjeto.value
				ENDIF


			CASE Upper(xmetodo) == 'USR_ALTER_BEFORE'
				** PAULO DEVIDE - 17-11-2014 - PROPRIEDADE PARA GUARDAR O VALOR DA CONDIÇÃO DE PAGAMENTO
				TRY 
					ADDPROPERTY(thisformset,"CONDICAO_PGTO_ANTES",v_compras_01.condicao_pgto)				
				CATCH TO err1
					WAIT WINDOW NOWAIT err1.message
				FINALLY
					thisformset.CONDICAO_PGTO_ANTES = v_compras_01.condicao_pgto
					WAIT clear
				ENDTRY

				Select v_compras_01_ent_prod
				=Requery()

				DO Case
						*CASE v_compras_01.status_aprovacao ='A'	 AND status_compra = '01'
					Case Reccount('v_compras_01_ent_prod') >= 1

						eMessageTitle = 'Atenção'
						eMessageText = 'Esse pedido de compra já foi recebido total ou parcialmente' +Chr(13)+;
							'Alterações permitidas apenas com Senha Gerencial.' +Chr(13)+'Deseja entra com senha de alteração ?'
						nDialogType = 4 + 16 + 256
						nAnswer = Messagebox(eMessageText, nDialogType, eMessageTitle)

						Do Case
							Case nAnswer = 6

								Local inppass
								*	Password (masked)
								inppass = rbInputBox( "Digite a Senha", "Senha para alteração de Pedido de Compra", "", , , "!", , "*")
								inppass = Alltrim(inppass )

								f_select("Select valor_atual from parametros where parametro = 'CAE_SENHA_COMPRAS' ","LISTAUT"	)

								Select LISTAUT
								CAEWHERE = LISTAUT.VALOR_ATUAL
								xaut = 0

								If Inlist(inppass  , &CAEWHERE  )
									xaut = xaut  +1
								Endif

								If xaut > 0
									Return .T.
								Else
									Messagebox("Senha incorreta ou não autorizada")
									Return .F.
								Endif

							Case nAnswer = 7
								Return .F.

						Endcase
				ENDCASE

				*** 
				* A regra abaixo foi suspensa.
				* Regra => Se v_compras_01.ERP_CUPS_EMBARQUE_LIBERADO = .T.
				* Na alteração Liberar acesso somente para cancelamento dos
				* Itens do pedido
				*/			
				IF .f.
					IF v_compras_01.ERP_CUPS_EMBARQUE_LIBERADO
						IF MESSAGEBOX("Pedido NÃO PODE mais ser alterado, o embarque já foi LIBERADO!"+REPLICATE(CHR(13),2)+;
										"Deseja CANCELAR este PEDIDO?",292,"Aviso")=7
							RETURN .f.
						ENDIF
					ENDIF
				ENDIF
				
			CASE Upper(xmetodo) == 'USR_INIT'
			
			
				******
				** PROJETO CUPS - INICIO
				** PAULO DEVIDE - ABR/15
				**/
				** Desabilita minimizar e maximizar para não desarrumar a tela no refresh
				thisformset.lx_form1.minbutton=.f.
				thisformset.lx_form1.maxbutton=.f.

				thisformset.lx_form1.lx_pageframe1.TabStretch = 0 && multiple rows (pageframe)
				lnLastPage = thisformset.lx_form1.lx_pageframe1.pagecount + 1
				lcLastPage = "pgAtacado"
				thisformset.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageAtacado") && classe cPageAtacado - definida neste objeto de entrada
				WITH thisformset.lx_form1.lx_pageframe1.pgAtacado
					.enabled=.t.
					lnPageIndex = .pageorder
				ENDWITH
				thisformset.lx_form1.lx_pageframe1.Activepage = lnPageIndex

				**
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
				
				*** Adiciona objetos na page 'Atacado'
				WITH thisformset.lx_form1.lx_pageframe1.pgAtacado

					.addobject('chk_mostruario1', 'chk_mostruario')
					WITH .chk_mostruario1
						.top = 20
						.left = 290
						.visible = .t.
						.controlsource = "v_compras_01.ERP_CUPS_PECA_MOSTRUARIO"
					ENDWITH
	
					.addobject('chk_embarque_liberado1', 'chk_embarque_liberado')
					WITH .chk_embarque_liberado1
						.top = 170
						.left = 25
						.visible = .t.
						.controlsource = "v_compras_01.ERP_CUPS_EMBARQUE_LIBERADO"
					ENDWITH

					.addobject('lbl_data_acordada', 'rotulo')
					.addobject('txt_data_acordada1', 'txt_data_acordada')
					WITH .txt_data_acordada1
						.top = 20
						.left = 117
						.controlsource = "v_compras_01.ERP_CUPS_DATA_ACORDADA"
						.visible = .t.
						.parent.lbl_data_acordada.caption = "Data Acordada"
						.parent.lbl_data_acordada.top = 23
						.parent.lbl_data_acordada.left = 25
						.parent.lbl_data_acordada.visible = .t.
					ENDWITH

					.addobject('lbl_embarque_atual', 'rotulo')
					.addobject('txt_embarque_atual1', 'txt_embarque_atual')
					WITH .txt_embarque_atual1
						.top = 50
						.left = 117
						.controlsource = "v_compras_01.ERP_CUPS_EMBARQUE_ATUAL"
						.visible = .t.
						.parent.lbl_embarque_atual.caption = "Embarque Atual"
						.parent.lbl_embarque_atual.top = 53
						.parent.lbl_embarque_atual.left = 25
						.parent.lbl_embarque_atual.visible = .t.
					ENDWITH

					.addobject('lbl_embarque_real', 'rotulo')
					.addobject('txt_embarque_real1', 'txt_embarque_real')
					WITH .txt_embarque_real1
						.top = 80
						.left = 117
						.controlsource = "v_compras_01.ERP_CUPS_EMBARQUE_REAL"
						.visible = .t.
						.parent.lbl_embarque_real.caption = "Embarque Real"
						.parent.lbl_embarque_real.top = 83
						.parent.lbl_embarque_real.left = 25
						.parent.lbl_embarque_real.visible = .t.
					ENDWITH

					.addobject('lbl_contrato', 'rotulo')
*!*						.addobject('txt_contrato1', 'txt_contrato')
*!*						WITH .txt_contrato1
*!*							.top = 110
*!*							.left = 340
*!*							.controlsource = "v_compras_01.ERP_CUPS_CONTRATO"
*!*							.visible = .t.
*!*							.parent.lbl_contrato.caption = "Contrato"
*!*							.parent.lbl_contrato.top = 113
*!*							.parent.lbl_contrato.left = 290
*!*							.parent.lbl_contrato.visible = .t.
*!*						ENDWITH

					.addobject('tv_contrato1', "tv_contrato")
					WITH .tv_contrato1
						.controlsource = "v_compras_01.ERP_CUPS_ID_CONTRATO"
						*.Height = 21
						.Left = 340
						.Top = 110
						*.Width = 120
						.Name = "tv_contrato1"
						.descricao = "NUM_CONTRATO"
						.lista_campos = "NUM_CONTRATO,ID_CONTRATO"
						.tabela_valida="CAEDU_CUPS_CONTRATOS"
						.ImgPesquisa.Stretch = 2
						.ImgPesquisa.picture = LOCFILE("lupa.gif","GIF","Localizar")
						
						.visible = .t.
						.parent.lbl_contrato.caption = "Contrato"
						.parent.lbl_contrato.top = 113
						.parent.lbl_contrato.left = 290
						.parent.lbl_contrato.visible = .t.
					ENDWITH	
									
					.addobject('lbl_data_chegada_porto', 'rotulo')
					.addobject('txt_data_chegada_porto1', 'txt_data_chegada_porto')
					WITH .txt_data_chegada_porto1
						.top = 110
						.left = 117
						.controlsource = "v_compras_01.ERP_CUPS_CHEGADA_PORTO"
						.visible = .t.
						.parent.lbl_data_chegada_porto.caption = "Chegada Porto"
						.parent.lbl_data_chegada_porto.top = 113
						.parent.lbl_data_chegada_porto.left = 25
						.parent.lbl_data_chegada_porto.visible = .t.
					ENDWITH
					
					.addobject('lbl_data_chegada_cd', 'rotulo')
					.addobject('txt_data_chegada_cd1', 'txt_data_chegada_cd')
					WITH .txt_data_chegada_cd1
						.top = 140
						.left = 117
						.controlsource = "v_compras_01.ERP_CUPS_CHEGADA_CD"
						.visible = .t.
						.parent.lbl_data_chegada_cd.caption = "Chegada CD"
						.parent.lbl_data_chegada_cd.top = 143
						.parent.lbl_data_chegada_cd.left = 25
						.parent.lbl_data_chegada_cd.visible = .t.
					ENDWITH

					.addobject('lbl_processo_ccf', 'rotulo')
					.addobject('txt_processo_ccf1', 'txt_processo_ccf')
					WITH .txt_processo_ccf1
						.top = 140
						.left = 340
						.controlsource = "v_compras_01.ERP_CUPS_PROCESSO_CCF_CCA"
						.visible = .t.
						.parent.lbl_processo_ccf.caption = "Processo/CCF"
						.parent.lbl_processo_ccf.top = 143
						.parent.lbl_processo_ccf.left = 256
						.parent.lbl_processo_ccf.visible = .t.
						.p_valida=.F. && 20-07-15 --> Não é mais obrigatório
					ENDWITH
					
					.addobject('lbl_incoterm', 'rotulo')
					.addobject('cbo_incoterm1', 'cbo_incoterm')
					WITH .cbo_incoterm1
						.top = 170
						.left = 340
						.controlsource = "v_compras_01.ERP_CUPS_INCOTERM"
						.visible = .t.
						.parent.lbl_incoterm.caption = "Incoterm"
						.parent.lbl_incoterm.top = 173
						.parent.lbl_incoterm.left = 283
						.parent.lbl_incoterm.visible = .t.
					ENDWITH						
								
				ENDWITH
				
				WITH thisformset.lx_form1.Lx_chkbox_encerrado1
				
					.parent.Label_PEDIDO.fontbold=.t.
					.parent.Label_PEDIDO.fontsize=11
					.parent.Label_PEDIDO.Left = .parent.Label_PEDIDO.Left - 27
					.parent.tx_PEDIDO.Left = .parent.tx_PEDIDO.Left - 35

					.parent.Label_FORNECEDOR.fontbold=.t.
					.parent.Label_FORNECEDOR.fontsize=11
					.parent.Label_FORNECEDOR.Left = .parent.Label_FORNECEDOR.Left - 80
					.parent.tv_FORNECEDOR.Left = .parent.tv_FORNECEDOR.Left - 88
					.parent.tx_CLIFOR.Left = .parent.tx_CLIFOR.Left - 88
					.parent.tx_CLIFOR.width = .parent.tx_CLIFOR.width - 17

					.Left  = .Left - 30
					.parent.addobject('CBO_tipo_pedido1','CBO_tipo_pedido')
					.parent.CBO_tipo_pedido1.Left = 580
					.parent.CBO_tipo_pedido1.Top = .Top+6
					.parent.CBO_tipo_pedido1.controlsource = "v_compras_01.ERP_CUPS_TIPO_PEDIDO"
					.parent.CBO_tipo_pedido1.Visible = .T.

					.parent.addobject('label_tipo_pedido','rotulo')
					.parent.label_tipo_pedido.Left = .parent.cbo_tipo_pedido1.Left - 40
					.parent.label_tipo_pedido.Top = .Top + 9
					.parent.label_tipo_pedido.forecolor = .parent.Label_FORNECEDOR.forecolor
					.parent.label_tipo_pedido.top = .parent.Label_FORNECEDOR.top
					.parent.label_tipo_pedido.fontsize = .parent.Label_FORNECEDOR.fontsize
					.parent.label_tipo_pedido.fontname = .parent.Label_FORNECEDOR.fontname
					.parent.label_tipo_pedido.fontbold = .T.
					
					.parent.label_tipo_pedido.Caption = "Tipo"
					
					.parent.label_tipo_pedido.autosize = .T.
					.parent.label_tipo_pedido.Visible = .T.

					.parent.addobject('label_segmento_pedido','rotulo')
					.parent.label_segmento_pedido.Left = 765
					.parent.label_segmento_pedido.Top = .Top - 5
					.parent.label_segmento_pedido.forecolor = .parent.Label_FORNECEDOR.forecolor
					.parent.label_segmento_pedido.fontsize = 8
					.parent.label_segmento_pedido.fontname = .parent.Label_FORNECEDOR.fontname
					.parent.label_segmento_pedido.fontbold = .T.
					
					.parent.label_segmento_pedido.Caption = "Segmento"
					
					.parent.label_segmento_pedido.autosize = .T.
					.parent.label_segmento_pedido.Visible = .T.		
					
					.parent.addobject('CBO_segmento_pedido1','CBO_segmento_pedido')
					.parent.CBO_segmento_pedido1.Left = 765
					.parent.CBO_segmento_pedido1.Top = .Top+11
					.parent.CBO_segmento_pedido1.controlsource = "v_compras_01.ERP_CUPS_SEGMENTO"
					.parent.CBO_segmento_pedido1.Visible = .T.
													
					.parent.Lx_frame_3d1.width = 699
				ENDWITH
				
				FOR EACH loPg IN thisformset.lx_form1.lx_pageframe1.pages
					
					IF UPPER(ALLTRIM(loPg.Caption)) = "CAEDU"
						lnPgOrder = loPg.pageorder
						lcPgName = loPg.name
						
						WITH loPg
							.text1.width = 50
							.label2.left = 202
							.text2.left = 304
							.text2.width = 80
							.label3.left = 399
							.text3.left = 465
							.text3.width = 80
							.addobject("txt_custo_fob1","txt_custo_fob")
							.txt_custo_fob1.top = .text1.top
							.txt_custo_fob1.left = 625
							.txt_custo_fob1.visible=.t.
							.txt_custo_fob1.VALUE = 0.00
							.addobject("lbl_custo_fob1","rotulo")
							.lbl_custo_fob1.caption = "Custo Fob"
							.lbl_custo_fob1.left = .txt_custo_fob1.left - 60
							.lbl_custo_fob1.top = .txt_custo_fob1.top + 3
							.lbl_custo_fob1.visible = .t.
							
							.addobject("txt_qtd_caixas1","txt_qtd_caixas")
							.txt_qtd_caixas1.top = .text1.top
							.txt_qtd_caixas1.left = 785
							.txt_qtd_caixas1.visible=.t.
							.txt_qtd_caixas1.value = 0
							.addobject("lbl_qtd_caixas1","rotulo")
							.lbl_qtd_caixas1.caption = "PACK p/CX."
							.lbl_qtd_caixas1.left = .txt_qtd_caixas1.left - 70
							.lbl_qtd_caixas1.top = .txt_qtd_caixas1.top + 3
							.lbl_qtd_caixas1.visible = .t.
							
						ENDWITH
						
					ENDIF
					**** 
					* paulo devide -> 30-07-2015 **
					*/
					IF UPPER(ALLTRIM(loPg.Caption)) = "\<ITENS"
						WITH loPg
							.addobject("txt_custo_fob1","txt_custo_fob")
							.txt_custo_fob1.top = 374
							.txt_custo_fob1.left = 97
							.txt_custo_fob1.visible=.t.
							.txt_custo_fob1.controlsource = "V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB"
							.addobject("lbl_custo_fob1","rotulo")
							.lbl_custo_fob1.caption = "Custo Fob"
							.lbl_custo_fob1.left = .txt_custo_fob1.left - 75
							.lbl_custo_fob1.top = .txt_custo_fob1.top + 3
							.lbl_custo_fob1.visible = .t.
							
							.addobject("txt_qtd_caixas1","txt_qtd_caixas")
							.txt_qtd_caixas1.top = 374
							.txt_qtd_caixas1.left = 481
							.txt_qtd_caixas1.visible=.t.
							.txt_qtd_caixas1.controlsource = "V_COMPRAS_01_PRODUTOS.ERP_CUPS_PACKS_POR_CAIXA"
							.addobject("lbl_qtd_caixas1","rotulo")
							.lbl_qtd_caixas1.caption = "PACK p/CX."
							.lbl_qtd_caixas1.left = .txt_qtd_caixas1.left - 70
							.lbl_qtd_caixas1.top = .txt_qtd_caixas1.top + 3
							.lbl_qtd_caixas1.visible = .t.
							
							.addobject("txt_custo_fob_minimo1","txt_custo_fob")
							.txt_custo_fob_minimo1.top = 404
							.txt_custo_fob_minimo1.left = 97
							.txt_custo_fob_minimo1.visible=.t.
							.txt_custo_fob_minimo1.controlsource = "V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB_MINIMO"
							.addobject("lbl_custo_fob_minino1","rotulo")
							.lbl_custo_fob_minino1.caption = "Fob Minimo"
							.lbl_custo_fob_minino1.left = .txt_custo_fob_minimo1.left - 75
							.lbl_custo_fob_minino1.top =  .txt_custo_fob_minimo1.top + 3
							.lbl_custo_fob_minino1.visible = .t.
							
							
							.addobject("cmdAtualizar1","cmdAtualizar")
							.cmdAtualizar1.visible = .t.
							
						ENDWITH
					
					ENDIF
					*****					 
				ENDFOR
				*\
				** PROJETO CUPS - FINAL
				** PAULO DEVIDE - ABR/15
				******
				
				

				** PAULO DEVIDE -> 21-05-2013 (botao pra imprimir pedido em inglês)
				PRIVATE ZZ_LISTA_CABIDES_CABILOG
				F_SELECT("select VALOR_ATUAL AS COMBO_LISTA_CABIDES from PARAMETROS WHERE PARAMETRO ='LISTA_CABIDES_CABILOG'","TMPLISTA_COMBO_CABIDES")
				ZZ_LISTA_CABIDES_CABILOG = alltrim(TMPLISTA_COMBO_CABIDES.COMBO_LISTA_CABIDES)
				
				
				thisformset.lx_form1.addobject('bt_pedido1', 'bt_pedido')
				WITH thisformset.lx_form1.bt_pedido1
					.height = 27
					.fontname = 'Arial'
					.Caption = 'Pedido'
					.Left = 644
					.Top = 31
					.Width = 50
					.Visible = .T.
					.Enabled = .T.
					.anchor = 0
					.forecolor = rgb(255,255,255)
					.p_manter_baixo = .f.
					.p_manter_cima = .f.
					.p_manter_direita = .f.
					.p_manter_esquerda = .f.
					.p_muda_size = .f.

				ENDWITH
				** FIM: 20-05-2013

				*** Inclui Campo Data OTB
				thisformset.lx_form1.lx_pageframe1.Page1.addobject('sh_OTB1', 'sh_OTB')
				WITH thisformset.lx_form1.lx_pageframe1.Page1.sh_OTB1
					.visible = .F.
					*!*				.Top = 342
					*!*				.Left = 4
					*!*				.Height = 40
				ENDWITH

				thisformset.lx_form1.lx_pageframe1.Page1.addobject('lb_data_otb1', 'lb_data_otb')
				WITH thisformset.lx_form1.lx_pageframe1.Page1.lb_data_otb1
					.visible = .t.
					.top = 182
					.Left = 8
					*!*				.Top = 348
					*!*				.Left = 18
				ENDWITH

				thisformset.lx_form1.lx_pageframe1.Page1.addobject('tx_data_otb1', 'tx_data_otb')
				WITH thisformset.lx_form1.lx_pageframe1.Page1.tx_data_otb1
					.visible = .t.
					.top = 182
					.left = 84
					*!*				.Top = 346
					*!*				.Left = 84
					.ControlSource = 'V_COMPRAS_01.CAEDU_DATA_OTB'
				ENDWITH
				*************************************************************

				If wacesso_esp_2 And Type("oCurrentFormSet.lx_form1.lx_pageframe1.page10") == "O" And ;
						Type("oCurrentFormSet.lx_form1.lx_pageframe1.page10.lx_compr_rolos_m_vol1") == "U"
					AddNewObject(oCurrentFormSet.lx_form1.lx_pageframe1.page10, "lx_compr_rolos_m_vol1", "lx_compr_rolos_m_vol")
					oCurrentFormSet.lx_form1.lx_pageframe1.page10.lx_compr_rolos_m_vol1.Top = 112
					oCurrentFormSet.lx_form1.lx_pageframe1.page10.lx_compr_rolos_m_vol1.Left = 556
					oCurrentFormSet.lx_form1.lx_pageframe1.page10.lx_compr_rolos_m_vol1.Visible = .T.
				Endif

				Create Cursor xUserSenha(usuario Varchar(25), motivo Varchar(25))

				** PAULO DEVIDE - 31-JUL-14 (INICIO)
				*
				* Rotina mudou para dentro do botão OK na aba CAEDU, pegando os cursores da tela NA inclusão
				thisformset.lx_form1.lx_pageframe1.Page5.addobject('bt_obs_pack1', 'bt_obs_pack')
				WITH thisformset.lx_form1.lx_pageframe1.Page5.bt_obs_pack1
					.visible = .t.
				ENDWITH
				*
				** PAULO DEVIDE - 31-JUL-14 (FIM)

				** PAULO DEVIDE - 09-SET-14 (INICIO) --> Pageframe Cabilog
				TRY
					* Page incluido no form 
					*thisformset.lx_form1.lx_pageframe1.pagecount = thisformset.lx_form1.lx_pageframe1.pagecount + 1 && inclusao dinamica cancelada
					lcPage = ALLTRIM(TRANSFORM(thisformset.lx_form1.lx_pageframe1.pagecount,"99"))

*!*						oManipulador = CREATEOBJECT("Manipulador")

					FOR EACH loPg IN thisformset.lx_form1.lx_pageframe1.pages
						IF "cabilog" $ LOWER(loPg.caption)

							**loPg.caption = "Cabilog"
							lcPgName = LOWER(ALLTRIM(loPg.name))

							*** Adiciona os objetos na page da Cabilog
							loPg.addobject("ck_cab_encabidado1","ck_cab_encabidado")
							loPg.ck_cab_encabidado1.visible=.t.

							loPg.addobject("lb_cod_cabide1","lb_cod_cabide")
							loPg.lb_cod_cabide1.visible=.t.

							loPg.addobject("cb_cod_cabide1","cb_cod_cabide")
							loPg.cb_cod_cabide1.visible=.t.

							loPg.addobject("lb_cab_cd_entrega1","lb_cab_cd_entrega")
							loPg.lb_cab_cd_entrega1.visible=.t.

							loPg.addobject("tx_cab_cd_entrega1","tx_cab_cd_entrega")
							loPg.tx_cab_cd_entrega1.visible=.t.

							loPg.addobject("lb_cab_status1","lb_cab_status")
							loPg.lb_cab_status1.visible=.t.

							loPg.addobject("tx_cab_status1","tx_cab_status")
							loPg.tx_cab_status1.visible=.t.

							loPg.addobject("lb_cab_localizacao1","lb_cab_localizacao")
							loPg.lb_cab_localizacao1.visible=.t.

							loPg.addobject("cb_cab_localizacao1","cb_cab_localizacao")
							loPg.cb_cab_localizacao1.visible=.t.

							loPg.addobject("lb_cab_qtdpecas1","lb_cab_qtdpecas")
							loPg.lb_cab_qtdpecas1.visible=.t.

							loPg.addobject("tx_cab_qtdpecas1","tx_cab_qtdpecas")
							loPg.tx_cab_qtdpecas1.visible=.t.

							loPg.addobject("LB_cab_envio1","LB_cab_envio")
							loPg.LB_cab_envio1.visible=.t.

							loPg.addobject("tx_cab_envio1","tx_cab_envio")
							loPg.tx_cab_envio1.visible=.t.

							loPg.addobject("lb_cab_tipo_pedido1","lb_cab_tipo_pedido")
							loPg.lb_cab_tipo_pedido1.visible=.t.

							loPg.addobject("tx_cab_tipo_pedido1","cb_cab_tipo_pedido")
							loPg.tx_cab_tipo_pedido1.visible=.t.
							
							loPg.refresh
							
						ENDIF
					ENDFOR
					
					thisformset.lx_form1.lx_pageframe1.activepage = 1 &&CAST(lcPage as Int)

				CATCH TO loErro
					MESSAGEBOX(loErro.Message,16,"Aviso")

				ENDTRY
				** PAULO DEVIDE - 09-SET-14 (FIM)


			CASE Upper(xmetodo) == 'USR_SAVE_BEFORE'
				llCancela = (RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0)
				
				** Se tiver dados de cancelamento, não validar nenhuma regra e permitir salvar o pedido
				IF llCancela 
					RETURN .t.
				ENDIF
				
				** PAULO DEVIDE --> 09-12-2014 (INICIO)
				IF !llCancela
					SELECT v_compras_01_produtos
					** PAULO DEVIDE --> 28-05-2015
					DIMENSION laMargem[IIF(RECCOUNT("v_compras_01_produtos")=0,1,RECCOUNT("v_compras_01_produtos")),3]
					FOR itt=1 TO ALEN(laMargem,1)
						laMargem[itt,1]="" 			&& produto
						laMargem[itt,2]="" 			&& cor produto
						laMargem[itt,3]=0.000000 	&& Margem
					ENDFOR
					
					lcMsgFollowUp = "" &&ALLTRIM(NVL(v_compras_01.ERP_FOLLOW_UP_MARGEM,""))
*!*						IF !EMPTY(lcMsgFollowUp)
*!*							lcMsgFollowUp = lcMsgFollowUp + CHR(13) + CHR(13) 
*!*						ENDIF
					
					PRIVATE lnMargem, lcOrigem
					lnMargem = 0
					lcOrigem = ""
					lcMsg1 = ""
					
					llOk = .t.
					** Alimenta o campo memo ==> ERP_FOLLOW_UP_MARGEM
					itt = 1
					SCAN
						
*!*							lcMsgFollowUp = lcMsgFollowUp + "Status = @@llStatus@@" + " | " 
*!*							lcMsgFollowUp = lcMsgFollowUp + "Data/Hora: " + TTOC(DATETIME()) + " | " 
*!*							lcMsgFollowUp = lcMsgFollowUp + "Usuário = " + wusuario + " | "  
*!*							lcMsgFollowUp = lcMsgFollowUp + "Pedido = " + v_compras_01_produtos.Pedido + " | "
*!*							lcMsgFollowUp = lcMsgFollowUp + "Produto = " + v_compras_01_produtos.Produto + " ==> " + ALLTRIM(v_compras_01_produtos.Desc_Produto) + " | " 
*!*							lcMsgFollowUp = lcMsgFollowUp + "Cor = " + v_compras_01_produtos.Cor_produto + " ==> " + ALLTRIM(v_compras_01_produtos.Desc_cor_produto) + " | " 
*!*							lcMsgFollowUp = lcMsgFollowUp + "Custo Informado = " + TRANSFORM(v_compras_01_produtos.custo1,"999,999.99") + " | " 
*!*							lcMsgFollowUp = lcMsgFollowUp + "Preço Custo Tab. 00 = @@lnCustoOriginal@@" + " | "  
*!*							lcMsgFollowUp = lcMsgFollowUp + "Preço Venda Tab. 01 = @@lnPrecoVenda@@" + " | " 
*!*							lcMsgFollowUp = lcMsgFollowUp + "Procedência = @@lcOrigem@@" +" | " 
*!*							lcMsgFollowUp = lcMsgFollowUp + "Margem % = @@lnMargem@@" 
*!*							lcMsgFollowUp = lcMsgFollowUp + CHR(13) + CHR(13)

						lnPercMargem = 0
						llStatus = zcalcula_margem(v_compras_01_produtos.produto,v_compras_01_produtos.custo1,@lcMsgFollowUp,@lnPercMargem)
						
						laMargem[itt,1]=v_compras_01_produtos.produto 			&& produto
						laMargem[itt,2]=v_compras_01_produtos.cor_produto		&& cor produto
						laMargem[itt,3]=lnPercMargem  							&& Margem
						
						** Compara com o valor da margem gravado no item, se for igual, não pede a senha
						IF ( ROUND(NVL(v_compras_01_produtos.ERP_PERC_MARGEM,0.000000),6) = ROUND(lnPercMargem,6) )
							llStatus = .t.
						ENDIF
						
						IF !llStatus

							lcMsg1 = CHR(13) + lcMsg1 + ;
							"Autorização para Margem mínima de produto "+ lcOrigem + " atingida ("+ ;
							ALLTRIM(TRANSFORM(lnPercMargem,"999,999.99"))+"%)" + CHR(13)
												
							llOk=.F.
						ENDIF
						
						SELECT v_compras_01_produtos
						itt = itt + 1
							
					ENDSCAN

					SELECT v_compras_01
					REPLACE v_compras_01.ERP_FOLLOW_UP_MARGEM WITH "" &&lcMsgFollowUp --> desabilitado pois estava estourando o tamanho max de 65536 bytes do campo
					
					SELECT v_compras_01_produtos
					GO TOP
					zz_produto = v_compras_01_produtos.produto
					*-- ERRO na validação da margem, pede a senha do DIRETOR, para dar o COMMIT
					IF !llOk

*!*							lcMsg1 = ""
*!*							lcMsg1 = lcMsg1 + ;
*!*							"Autorização para Margem mínima de produto "+ lcOrigem + " atingida ("+ ;
*!*							ALLTRIM(TRANSFORM(lnMargem,"999,999.99"))+"%)"
						
						IF !ZVALIDA_SENHA("DIRETOR",lcMsg1)
							RETURN .F.
						ELSE

							SELECT v_compras_01_produtos
							GO top
							FOR itt=1 TO ALEN(laMargem,1)

								** localiza o registro e da um update na margem
								LOCATE FOR v_compras_01_produtos.produto = laMargem[itt,1] ;
									AND v_compras_01_produtos.cor_produto=laMargem[itt,2]
									
								IF FOUND()	
									REPLACE v_compras_01_produtos.ERP_PERC_MARGEM WITH laMargem[itt,3]
								ENDIF
							
							ENDFOR

							SELECT v_compras_01_produtos
							GO top

						ENDIF				

						lc_usuario = ALLTRIM(x_Diretor.usuario)	
						lcMsgFollowUp = ALLTRIM(NVL(v_compras_01.ERP_FOLLOW_UP_MARGEM,""))
						IF !EMPTY(lcMsgFollowUp)
							lcMsgFollowUp = lcMsgFollowUp + CHR(13)
						ENDIF
						lcMsgFollowUp = lcMsgFollowUp + "Autorizado por " + lc_usuario + " em " + TTOC(DATETIME())
						** atualiza followUp com informações do diretor que autorizou (login e data/hora da autorização)
						SELECT v_compras_01
						REPLACE v_compras_01.ERP_FOLLOW_UP_MARGEM WITH lcMsgFollowUp &&--> desabilitado pois estava estourando o tam max de 65536 bytes do campo
						
					ENDIF
				ENDIF
				
				** PAULO DEVIDE --> 09-12-2014 (FIM)
								

				** PAULO DEVIDE -> 23-05-2013
				IF INLIST(ThisFormSet.p_Tool_Status,'I','A')
					LOCAL llRet as Boolean
					PRIVATE pdEntrega, pdLimite
					pdEntrega = ThisFormSet.lx_form1.Lx_pageframe1.Page1.tx_ENTREGA_UNICA.value
					pdLimite = ThisFormSet.lx_form1.Lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.value


					SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
					SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
					SELECT v_Compras_01


					SELECT v_compras_01
					XyTOT1 = v_compras_01.tot_qtde_original
					SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
					GO top
					replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde WITH V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde
					XyTOT2 = V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde

					XPACKTOT = XyTOT1 / XyTOT2

					*!* SET STEP ON
					** CUPS >> QUERY ABAIXO SUBSTITUI VARIAVEL XPACKTOT (INICIO)
					SELECT produto,SUM(qtde_original) as qtde_original, 00000000.0000 as PACKTOTAL ;
					FROM v_compras_01_produtos WITH (BUFFERING=.T.) ;
					GROUP BY produto INTO CURSOR vcur_total_produto READWRITE
					** CUPS >> QUERY ABAIXO SUBSTITUI VARIAVEL XPACKTOT (FINAL)
										
					SELECT vcur_total_produto 
					GO TOP
					SCAN 
						SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
						LOCATE FOR ALLTRIM(PRODUTO)=ALLTRIM(vcur_total_produto.PRODUTO)
						IF FOUND()
							SELECT vcur_total_produto 					
							REPLACE vcur_total_produto.PACKTOTAL WITH vcur_total_produto.qtde_original / V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.QTDE
						ENDIF
						SELECT vcur_total_produto
					ENDSCAN

					SELECT v_compras_01
					llRet = zvalida_campos_pedido_pack()

					SELECT v_Compras_01
					*llRet = .t.
					IF NOT llRet
						RETURN .f.
					ENDIF
				ENDIF
				** Fim: 23-05-2013

				** PAULO DEVIDE - 08-09-2014
				IF .f. &&INLIST(Thisformset.p_Tool_Status,"I","A") --> não vai mais utilizar propriedades para CABILOG, campos na tabela compras, page especifica

					SELECT * FROM curpropcompras WITH (BUFFERING=.T.) ;
						WHERE ALLTRIM(PROPRIEDADE) >= "00069" AND  ALLTRIM(PROPRIEDADE) <= "00075" ;
						INTO CURSOR tmp_curpropcompras1


					IF RECCOUNT("tmp_curpropcompras1")>0

						SELECT tmp_curpropcompras1
						LOCATE FOR ALLTRIM(PROPRIEDADE)="00070"

						IF FOUND()
							IF UPPER(ALLTRIM(NVL(tmp_curpropcompras1.VALOR_PROPRIEDADE,"")))=="SIM"
								**MESSAGEBOX("A PROPRIEDADE CAB_ENCABIDADO ESTA IGUAL A SIM"+CHR(13)+NVL(curpropcompras.VALOR_PROPRIEDADE,""))
								** CAB_ENCABIDADO = "SIM" --> VARRER CURSOR E VERIFICAR SE TODAS AS PROPRIEDADE FORAM PREENCHIDAS CORRETAMENTE

								llOk=.t.
								lcMsgErr = ""

								DIMENSION laProp_Cabide[7]

								laProp_Cabide[1] = 'COD_CABIDE'	&&00069
								laProp_Cabide[2] = 'CAB_ENCABIDADO'	&&00070
								laProp_Cabide[3] = 'CAB_LOCALIZACAO'	&&00071
								laProp_Cabide[4] = 'CAB_QTDPECAS'	&&00072
								laProp_Cabide[5] = 'CAB_STATUS'	&&00073
								laProp_Cabide[6] = 'CAB_CD_ENTREGA'	&&00074
								laProp_Cabide[7] = 'CAB_TIPO_PEDIDO'	&&00075

								SELECT tmp_curpropcompras1
								FOR iw=69 TO 75
									LOCATE FOR ALLTRIM(propriedade) = PADL(iw,5,"0")
									IF NOT FOUND() OR EMPTY(NVL(tmp_curpropcompras1.VALOR_PROPRIEDADE,""))
										llOk=.f.
										lcMsgErr = lcMsgErr + "Propriedade "+laProp_Cabide[iw-68]+" não foi preenchida corretamente;"+CHR(13)
									ENDIF
								ENDFOR

								IF NOT llOk
									MESSAGEBOX("Pedido NÃO foi salvo, VERIFIQUE!!! Obrigatório preencher TODAS as propriedades"+;
										" do Grupo Encabidados!"+CHR(13)+CHR(13)+lcMsgErr,16,"Aviso")
									*thisformset.l_cancela()
									RETURN .f.
								ENDIF

							ELSE
								*--> MESSAGEBOX("A PROPRIEDADE CAB_ENCABIDADO ESTA DIFERENTE DE SIM"+CHR(13)+NVL(curpropcompras.VALOR_PROPRIEDADE,""))
								*>*) NÃO PRECISA VERIFICAR NADA, POIS É UM PEDIDO NÃO ENCABIDADO, PORTANTO NESTE CASO NÃO GERA ARQUIVO TEXTO PARA A CABILOG
							ENDIF
						ELSE
							** MESSAGEBOX("Não achou A PROPRIEDADE CAB_ENCABIDADO (1)")
							** NÃO FAZ NADA E NÃO GERA ARQUIVO TXT PARA A CABILOG PARA ESTE PEDIDO
						ENDIF

					ELSE

						**MESSAGEBOX("Não achou A PROPRIEDADE CAB_ENCABIDADO (2)")
						** NÃO FAZ NADA E NÃO GERA ARQUIVO TXT PARA A CABILOG PARA ESTE PEDIDO

					ENDIF

				ENDIF
				** FIM - 08-09-2014

				******************************************************************************************
				** PAULO DEVIDE --> 10-SET-14 (INICIO) --> ATUALIZA CAMPO ERP_CAB_STATUS - PROJETO CABILOG
				******************************************************************************************
				IF Inlist(Thisformset.p_Tool_Status, "A","I")
				
					** verifica se todos os campos foram preenchidos
					lcMsgErr = ""
					IF v_Compras_01.ERP_CAB_ENCABIDADO
						IF EMPTY(NVL(v_Compras_01.ERP_CAB_COD_CABIDE,""))
							lcMsgErr = lcMsgErr + "Obrigatório preencher o Código do Cabide (Aba - Cabilog);" + CHR(13)				
						ENDIF
						
						IF EMPTY(NVL(v_Compras_01.ERP_CAB_CD_ENTREGA,""))
							lcMsgErr = lcMsgErr + "Obrigatório preencher o Código do CD Entrega  (Aba - Cabilog);" + CHR(13)				
						ENDIF
						
						IF EMPTY(NVL(v_Compras_01.ERP_CAB_LOCALIZACAO,""))
							lcMsgErr = lcMsgErr + "Obrigatório preencher a Localização Cabide  (Aba - Cabilog);" + CHR(13)				
						ENDIF
						
						IF EMPTY(NVL(v_Compras_01.ERP_CAB_TIPO_PEDIDO,""))
							lcMsgErr = lcMsgErr + "Obrigatório preencher o Tipo de Pedido  (Aba - Cabilog);" + CHR(13)				
						ENDIF
						
					ENDIF
					
					IF NOT EMPTY(lcMsgErr)
						MESSAGEBOX(lcMsgErr, 16, "Aviso")
						RETURN .f.
					ENDIF

					lcCab_Status = "M"
					llData_Envio = .f.
					**SET STEP ON
					
					DO CASE
						CASE Thisformset.p_Tool_Status="A"		&& ATUALIZA PROPRIEDADE CAB_STATUS PARA 'M'

							IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
							
								IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
									lcCab_Status = "C" && pedido cancelado
									llData_Envio = .t.
								ELSE
									lcCab_Status = "A" && pedido cancelado
								ENDIF
								

							ELSE
							
								IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
									lcCab_Status = "M" && pedido Ok!
									llData_Envio = .t.
								ELSE
									lcCab_Status = "A" && pedido Ok!
								ENDIF

							ENDIF


							REPLACE v_Compras_01.ERP_CAB_STATUS WITH lcCab_Status
							replace v_Compras_01.ERP_CAB_QTDPECAS with ;
								CEILING(v_Compras_01.TOT_QTDE_ORIGINAL * (thisformset.pp_porcentagem_qtd_cabides/100)) 
							
							IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
								**WAIT WINDOW "Data de envio para Cabilog = NULL"
								replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
							ENDIF
							
							
						CASE Thisformset.p_Tool_Status="I"		&& ATUALIZA PROPRIEADE CAB_STATUS PARA 'A'

							IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
								IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
									lcCab_Status = "C" && pedido cancelado
									llData_Envio = .t.
								ELSE
									lcCab_Status = "A" && pedido cancelado
								ENDIF

*!*									lcCab_Status = "C" && pedido cancelado

							ELSE
								lcCab_Status = "A" && pedido Ok!

							ENDIF

							REPLACE v_Compras_01.ERP_CAB_STATUS WITH lcCab_Status
							replace v_Compras_01.ERP_CAB_QTDPECAS with ;
								CEILING(v_Compras_01.TOT_QTDE_ORIGINAL * (thisformset.pp_porcentagem_qtd_cabides/100)) 

							IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
								**WAIT WINDOW "Data de envio para Cabilog = NULL"
								replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
							ENDIF


						OTHERWISE

					ENDCASE
					
*!*						MESSAGEBOX("STATUS = " + v_Compras_01.ERP_CAB_STATUS + CHR(13) +;
*!*						"QTD PECAS = "+ TRANSFORM(v_Compras_01.ERP_CAB_QTDPECAS,"99999") + CHR(13) +;
*!*						"DATA ENVIO = " + DTOC(NVL(v_compras_01.ERP_CAB_DATA_ENVIO,CTOD(""))), 64,"CAMPOS DEPOIS DO SAVE")

					
				ENDIF
				******************************************************************************************
				** PAULO DEVIDE --> 10-SET-14 (FIM)
				******************************************************************************************
				
				If Inlist(Thisformset.p_Tool_Status, "A") AND RECCOUNT("V_COMPRAS_01_CANCELAMENTO")=0
					Select xUserSenha
					Zap
					Append Blank


					
					** PAULO DEVIDE --> 06-11-2014 *********************************************************
					** na alteração para mudar o campo condicao de pagamento, somente com a senha de Diretor
					IF not (thisformset.CONDICAO_PGTO_ANTES == v_compras_01.condicao_pgto) && alterado em 17-nov-14 
					*IF GETFLDSTATE("condicao_pgto","v_compras_01")<>1
						**MESSAGEBOX("USUÁRIO ALTEROU O VALOR DO CAMPO CONDIÇÃO DE PAGAMENTO",64,"Aviso")
***							e-MAIL Larissa Yumi Shimono 18/11/14
*!*							Bom dia,
*!*							Luciano, é isso mesmo, esta correto.
*!*							Paulo, apenas um detalhe, a senha para alteração de condição de pagamento, deve 
*!*							ser a senha de Gerente Geral, no caso, da Lais Bisordi e do Marcio Acciardo.
*!*							Fizemos um teste novamente agora, e não estamos conseguindo, aparece a mensagem abaixo:
***							Mudou de Diretor para Gerente em 18-11-14	
							** nao faz nada - o usuario esta cancelando
						IF !ZVALIDA_SENHA("GERENTE","Alterou condição de pagamento!")
							RETURN .F.
						ENDIF
					ENDIF
					****************************************************************************************

					Select v_Compras_01_Produtos
					Go Top
					************************************************
					****   Sandra Ono
					*********** Verfica a semana (compras)  *********
					lc_pedido = Alltrim(v_Compras_01_Produtos.pedido)
					ld_limite_entrega = Dtoc(v_Compras_01_Produtos.limite_entrega,1)
					TEXT TO lcsql noshow
	     		    select pedido, LIMITE_ENTREGA, DATEPART( wk , LIMITE_ENTREGA ) as semana,
	     		       ENTREGA,  DATEPART( wk , getdate() ) as semana_atual
					from
					COMPRAS_PRODUTO
					where pedido like ?lc_pedido
					ENDTEXT

					If Used("x_entreg_atu")
						Use In x_entreg_atu
					Endif
					f_select(lcsql,'x_entreg_atu')

					IF RECCOUNT("x_entreg_atu")  = 0 or;
							f_vazio(x_entreg_atu.entrega)
						RETURN .T.
					ENDIF

					If Thisformset.px_entrega.Value <> Ttod(x_entreg_atu.entrega)
						rbmotivo( "Motivo da alteração", "Motivo", "", , , "!", , "*")
					Endif

					If Ttod(x_entreg_atu.limite_entrega) != v_Compras_01_Produtos.limite_entrega
						LC_DATA_INI = Dtoc(Ttod(x_entreg_atu.limite_entrega),1)
						LC_DATA_FIM = Dtoc(Datetime(),1)

						*XWK_ENTEGA =  WEEK(Ttod(x_entreg_atu.limite_entrega))
						XWK_ENTEGA =  IIF( YEAR(x_entreg_atu.limite_entrega) > YEAR(date()), WEEK(Ttod(x_entreg_atu.limite_entrega)) +50 ,WEEK(Ttod(x_entreg_atu.limite_entrega)))

						XWK_ATUAL = WEEK(DATE( ))
						WKDIFF = XWK_ENTEGA - XWK_ATUAL
						ld_limite_entrega = Dtoc(v_Compras_01_Produtos.limite_entrega,1)
						If Used("x_entreg_new")
							Use In x_entreg_new
						Endif

						TEXT TO lcsql noshow
					 select  DATEDIFF ( wk , ?LC_DATA_FIM,  ?LC_DATA_INI )  as wk_dif
						ENDTEXT
						f_select(lcsql,'x_entreg_new')

						Do Case
							Case WKDIFF  <= 1 && 0

*********** Comentado por Paulo Devidé -> 13-11-2014 (inicio)
*!*	*!*	*!*									Local inppass
*!*	*!*	*!*									inppass = rbInputBox2( " Senha", "SENHA de [DIRETOR]", "", , , "!", , "*")
*!*	*!*	*!*									inppass = Alltrim(inppass)
*!*	*!*	*!*									ll_senha_OK  = .F.

*!*	*!*	*!*									TEXT TO lcsql noshow
*!*	*!*	*!*			 				  SELECT par.usuario FROM  PARAMETROS_USERS par
*!*	*!*	*!*				   	     	  WHERE parametro like 'PALMA_DIRETOR_CPA_ENT'
*!*	*!*	*!*	   		   		     	  and usuario like ?xUserSenha.usuario
*!*	*!*	*!*									ENDTEXT

*!*	*!*	*!*									If Used("x_Diretor")
*!*	*!*	*!*										Use In x_Diretor
*!*	*!*	*!*									Endif

*!*	*!*	*!*									f_select(lcsql,"x_Diretor")

*!*	*!*	*!*									If Reccount("x_Diretor") = 0
*!*	*!*	*!*										Messagebox("Usuario sem permissão de [diretor] p/ liberar alteração!",16,"Avisos")
*!*	*!*	*!*										Return .F.
*!*	*!*	*!*									Endif

*!*	*!*	*!*									Select x_Diretor
*!*	*!*	*!*									Scan
*!*	*!*	*!*										lc_usuario = Alltrim(x_Diretor.usuario)
*!*	*!*	*!*										f_select("select passw from users where usuario like ?lc_usuario ", 'X_CURSENHALINX')

*!*	*!*	*!*										If UPPER(inppass) = UPPER(F_DS_CR(Alltrim(X_CURSENHALINX.Passw)))
*!*	*!*	*!*											ll_senha_OK = .T.
*!*	*!*	*!*										ENDIF
*!*	*!*	*!*										SELECT x_Diretor
*!*	*!*	*!*									Endscan

*!*	*!*	*!*									If !ll_senha_OK
*!*	*!*	*!*										Messagebox("Senha não confere com Diretores cadastrados!!!",16,"Atenção")
*!*	*!*	*!*										Return .F.
*!*	*!*	*!*									Endif
*********** Comentado por Paulo Devidé -> 13-11-2014 (final)
								
								** (inicio) PAULO DEVIDE --> 13-NOV-14
								IF !ZVALIDA_SENHA("DIRETOR","Alterou Limite de entrega!")
									RETURN .F.
								ENDIF
								
								lcsql = ""
								lc_usuario = ALLTRIM(x_Diretor.usuario) && cursor aberto e usuario do diretor autenticado
								TEXT TO lcsql noshow
									INSERT INTO trigger_portal
									(id,login,pedido,entrega_antiga,entrega_nova,limite_entrega_antiga,	limite_entrega_nova,data_alteracao ,user_senha,	cargo_senha)
									VALUES	((select MAX(id)+1 from trigger_portal), ?wusuario, ?x_entreg_atu.pedido, ?x_entreg_atu.entrega, ?v_compras_01_produtos.entrega,
									  ?x_entreg_atu.limite_entrega, ?v_compras_01_produtos.limite_entrega, getdate(), ?lc_usuario, 'DIRETOR')
								ENDTEXT
								F_INSERT(lcsql)
								** (fim) PAULO DEVIDE --> 13-NOV-14
								
								*Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, tcFormat, tcInputMask, tcPasswordChar


							Case INLIST(WKDIFF  ,2)

*********** Comentado por Paulo Devidé -> 13-11-2014 (inicio)
*!*	*!*	*!*									Local inppass
*!*	*!*	*!*									inppass = rbInputBox2( "Digite a Senha", "SENHA de [GERENTE]", "", , , "!", , "*")
*!*	*!*	*!*									inppass = Alltrim(inppass)
*!*	*!*	*!*									ll_senha_OK  = .F.

*!*	*!*	*!*									If Used("x_Gerente")
*!*	*!*	*!*										Use In x_Gerente
*!*	*!*	*!*									Endif

*!*	*!*	*!*									TEXT TO lcsql noshow
*!*	*!*	*!*		   	     			  SELECT USUARIO FROM  PARAMETROS_USERS
*!*	*!*	*!*		   	     			  WHERE parametro like 'PALMA_GERENTE_CPA_ENT'
*!*	*!*	*!*		   	     			  and usuario like ?xUserSenha.usuario
*!*	*!*	*!*									ENDTEXT

*!*	*!*	*!*									f_select(lcsql,"x_Gerente")

*!*	*!*	*!*									If Reccount("x_Gerente") = 0
*!*	*!*	*!*										Messagebox("Usuario sem permissão de [gerente] p/ liberar alteração!",16,"Avisos")
*!*	*!*	*!*										Return .F.
*!*	*!*	*!*									Endif


*!*	*!*	*!*									Select x_Gerente
*!*	*!*	*!*									Scan
*!*	*!*	*!*										lc_usuario = Alltrim(x_Gerente.usuario)
*!*	*!*	*!*										f_select("select passw from users where usuario like ?lc_usuario ", 'X_CURSENHALINX')

*!*	*!*	*!*										If UPPER(inppass) = Upper(F_DS_CR(Alltrim(X_CURSENHALINX.Passw)))
*!*	*!*	*!*											ll_senha_OK = .T.
*!*	*!*	*!*										Endif

*!*	*!*	*!*										Select x_Gerente
*!*	*!*	*!*									Endscan

*!*	*!*	*!*									If !ll_senha_OK
*!*	*!*	*!*										Messagebox("Senha não confere com [GERENTES] cadastrados!!!",16,"Atenção")
*!*	*!*	*!*										Return .F.
*!*	*!*	*!*									Endif
*********** Comentado por Paulo Devidé -> 13-11-2014 (fim)

								llCancela = (RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0) && se .T. deixa passar direto
								
								IF !llCancela
									IF !ZVALIDA_SENHA("GERENTE","Alterou Limite de entrega!")
										RETURN .F.
									ENDIF

									lcsql = ""
									lc_usuario = ALLTRIM(x_Gerente.usuario) && cursor aberto e usuario do Gerente autenticado
									
									TEXT TO lcsql noshow
										INSERT INTO trigger_portal
											(id, login, pedido, entrega_antiga, entrega_nova, limite_entrega_antiga, limite_entrega_nova, data_alteracao, user_senha, cargo_senha)
											VALUES ((select MAX(id)+1 from trigger_portal), ?wusuario, ?x_entreg_atu.pedido, ?x_entreg_atu.entrega,
											  ?v_compras_01_produtos.entrega, ?x_entreg_atu.limite_entrega,  ?v_compras_01_produtos.limite_entrega,
											  getdate(),  ?lc_usuario, 'GERENTE')
									ENDTEXT
									F_INSERT(lcsql)
								ENDIF
								
						Endcase


					Endif

				ENDIF
				
				*** valida objetos Atacado (CUPS) - inicio - executa os metodos de validação dos objetos da 
				*** classe CUPS.VCX
				lcMsgErr_CUPS = ""
				FOR EACH objx IN thisformset.lx_form1.lx_pageframe1.pgAtacado.Controls
					IF LOWER(objx.baseclass)<>"label"
						IF objx.p_valida
							IF !objx.m_valida()
								lcMsgErr_CUPS = lcMsgErr_CUPS + objx.MsgErr_CUPS
							ENDIF
						ENDIF
					ENDIF
				ENDFOR
				IF !EMPTY(lcMsgErr_CUPS)
					MESSAGEBOX(lcMsgErr_CUPS,16,"Aviso")
					RETURN .f.
				ENDIF

				IF EMPTY(NVL(v_compras_01.ERP_CUPS_SEGMENTO,''))
					
					MESSAGEBOX("Campo SEGMENTO deve ser preenchido com VAREJO ou ATACADO",16,"Aviso")
					RETURN .f.
					
				ENDIF
				
				** {21-07-2015} -> VERIFICA SE O CAMPO ERP_CUPS_PACKS_POR_CAIXA esta preenchido
				IF .f.
					IF UPPER(ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,'')))="ATACADO"
						SELECT v_compras_01_produtos
						GO top
						llOk2=.t.
						lcMsgErr=""
						SCAN 					
							IF EMPTY(NVL(v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA,0))
								llOk2=.f.
								lcMsgErr=lcMsgErr+"Produto "+v_compras_01_produtos.PRODUTO+" com campo PACKS por Caixa em branco."+CHR(13)
							ENDIF
						ENDSCAN
						IF !llOk2
							MESSAGEBOX(lcMsgErr+CHR(13)+"Favor preencher antes de salvar",16,"Aviso")
							RETURN llOk2
						ENDIF
					ENDIF
				ENDIF
				**************************************************************************
				
				IF ZORIGEM_PEDIDO_IMPORTADO()=.t. AND !ZAUTORIZA_ATACADO()&& importado/estrangeiro 
					
					lcMsgErr=""
					llRet2=.t.

					IF EMPTY(NVL(v_compras_01.FILIAL_A_ENTREGAR,""))
						lcMsgErr = lcMsgErr + CHR(13) + "Obrigatório preencher FILIAL A ENTREGAR" + CHR(13)
						llRet2=.f.
					ENDIF
					
					IF EMPTY(NVL(v_compras_01.FILIAL_COBRANCA,""))
						lcMsgErr = lcMsgErr + CHR(13) + "Obrigatório preencher FILIAL COBRANÇA" + CHR(13)
						llRet2=.f.
					ENDIF
					
					IF EMPTY(NVL(v_compras_01.FILIAL_A_FATURAR,""))
						lcMsgErr = lcMsgErr + CHR(13) + "Obrigatório preencher FILIAL A FATURAR" + CHR(13)
						llRet2=.f.
					ENDIF
					
					IF EMPTY(NVL(v_compras_01.RATEIO_CENTRO_CUSTO,""))
						lcMsgErr = lcMsgErr + CHR(13) + "Obrigatório preencher RATEIO CENTRO DE CUSTO" + CHR(13)
						llRet2=.f.
					ENDIF
					
					IF EMPTY(NVL(v_compras_01.RATEIO_FILIAL,""))
						lcMsgErr = lcMsgErr + CHR(13) + "Obrigatório preencher RATEIO FILIAL" + CHR(13)
						llRet2=.f.
					ENDIF
					
					IF EMPTY(NVL(v_compras_01.ERP_CUPS_TIPO_PEDIDO,""))
						lcMsgErr = lcMsgErr + CHR(13) + "Obrigatório preencher TIPO DE PEDIDO (CCF/CCA)" + CHR(13)
						llRet2=.f.
					ENDIF
					
					IF EMPTY(NVL(v_compras_01.ERP_CUPS_DATA_ACORDADA,{}))
						lcMsgErr = lcMsgErr + CHR(13) + "Obrigatório preencher DATA ACORDADA" + CHR(13)
						llRet2=.f.
					ENDIF
					
					IF EMPTY(NVL(v_compras_01.ERP_CUPS_INCOTERM,""))
						lcMsgErr = lcMsgErr + CHR(13) + "Obrigatório preencher INCOTERM na aba IMPORTADO" + CHR(13)
						llRet2=.f.
					ENDIF
					
					IF EMPTY(NVL(v_compras_01.ERP_CUPS_ID_CONTRATO,""))
						lcMsgErr = lcMsgErr + CHR(13) + "Obrigatório preencher CONTRATO na aba IMPORTADO" + CHR(13)
						llRet2=.f.
					ENDIF

					SELECT v_compras_01_produtos
					GO top

					SCAN 					

						IF EMPTY(NVL(v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA,0))
							llRet2=.f.
							lcMsgErr = lcMsgErr + CHR(13) + "Campo PACKS por Caixa em branco." + CHR(13)
						ENDIF

						IF EMPTY(NVL(v_compras_01_produtos.ERP_CUPS_CUSTO_FOB,0))
							llRet2=.f.
							lcMsgErr = lcMsgErr + CHR(13) + "Campo CUSTO FOB em branco." + CHR(13)
						ENDIF
						
					ENDSCAN
					
					IF llRet2=.f.
						MESSAGEBOX(lcMsgErr,16,"Aviso")
						RETURN llRet2
					ENDIF

				 
				ENDIF
				
				*** valida objetos Atacado (CUPS) - final
				
				

			CASE Upper(xmetodo) == 'USR_SAVE_AFTER' && PAULO DEVIDE --> 25/08/2014
				***
				* PROJETO CUPS - ATUALIZAR DATA_PARA_TRANSFERENCIA DO CADASTRO DE PRODUTOS PARA SENSIBILIZAR O ENSEMBLE
				*/
				IF ALLTRIM(v_compras_01.ERP_CUPS_TIPO_PEDIDO)=="CCF"
					IF !USED("vcur_total_produto")
						SELECT produto,SUM(qtde_original) as qtde_original, 00000000.0000 as PACKTOTAL ;
						FROM v_compras_01_produtos WITH (BUFFERING=.T.) ;
						GROUP BY produto INTO CURSOR vcur_total_produto READWRITE
					ENDIF
					
					SELECT vcur_total_produto
					GO top
					SCAN
						f_execute("UPDATE PRODUTOS SET DATA_PARA_TRANSFERENCIA = GETDATE() WHERE PRODUTO=?vcur_total_produto.PRODUTO")
					ENDSCAN
				ENDIF
				
				** CUPS - ATUALIZA O CAMPO DATA_PARA_TRANSFERENCIA --------------------------------------------------
				F_EXECUTE("UPDATE COMPRAS SET DATA_PARA_TRANSFERENCIA = GETDATE() WHERE PEDIDO=?v_compras_01.PEDIDO")
				** --------------------------------------------------------------------------------------------------
				
				IF .f. && mudou a rotina, agora atualiza os campos na tabela compras --> 10-09-2014
					*MESSAGEBOX(XMETODO+CHR(13)+Thisformset.p_Tool_Status)
					F_SELECT("select * from PROP_COMPRAS where PROPRIEDADE='00073' AND PEDIDO=?v_Compras_01.PEDIDO","WTMP_PROPCOMPRAS")
					lcOp1 = IIF(RECCOUNT("WTMP_PROPCOMPRAS")>0,"A","I")
					lcCab_Status = "M"
					DO CASE
						CASE Thisformset.p_Tool_Status="A"		&& ATUALIZA PROPRIEADE CAB_STATUS PARA 'M'

							IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
								*MESSAGEBOX("TEM CANCELAMENTO",64,"AVISO")
								lcCab_Status = "C" && pedido cancelado

							ELSE
								*MESSAGEBOX("NÃO TEM CANCELAMENTO",64,"AVISO")
								lcCab_Status = "M" && pedido Ok!

							ENDIF

							IF lcOp1="I"

								TEXT TO lcSQL NOSHOW TEXTMERGE
							insert into PROP_COMPRAS (PROPRIEDADE,PEDIDO,ITEM_PROPRIEDADE,VALOR_PROPRIEDADE,DATA_PARA_TRANSFERENCIA)
							VALUES ('00073',?v_Compras_01.PEDIDO,'1',?lcCab_Status,NULL)
								ENDTEXT

							ELSE

								TEXT TO lcSQL NOSHOW TEXTMERGE
							UPDATE PROP_COMPRAS
							SET VALOR_PROPRIEDADE=?lcCab_Status
							WHERE PROPRIEDADE='00073' AND PEDIDO=?v_Compras_01.PEDIDO
								ENDTEXT

							ENDIF
							F_EXECUTE(lcSQL)

						CASE Thisformset.p_Tool_Status="I"		&& ATUALIZA PROPRIEADE CAB_STATUS PARA 'A'

							IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
								*MESSAGEBOX("TEM CANCELAMENTO",64,"AVISO")
								lcCab_Status = "C" && pedido cancelado

							ELSE
								*MESSAGEBOX("NÃO TEM CANCELAMENTO",64,"AVISO")
								lcCab_Status = "A" && pedido Ok!

							ENDIF

							IF lcOp1="I"

								TEXT TO lcSQL NOSHOW TEXTMERGE
							insert into PROP_COMPRAS (PROPRIEDADE,PEDIDO,ITEM_PROPRIEDADE,VALOR_PROPRIEDADE,DATA_PARA_TRANSFERENCIA)
							VALUES ('00073',?v_Compras_01.PEDIDO,'1',?lcCab_Status,NULL)
								ENDTEXT

							ELSE

								TEXT TO lcSQL NOSHOW TEXTMERGE
							UPDATE PROP_COMPRAS
							SET VALOR_PROPRIEDADE=?lcCab_Status
							WHERE PROPRIEDADE='00073' AND PEDIDO=?v_Compras_01.PEDIDO
								ENDTEXT

							ENDIF
							F_EXECUTE(lcSQL)


						OTHERWISE

					ENDCASE
				ENDIF


		Endcase

	Endproc

Enddefine

DEFINE CLASS cPageAtacado as Page

	caption = "Importado"
	PROCEDURE Activate
		thisform.refresh
	ENDPROC
	
ENDDEFINE

DEFINE CLASS sh_OTB AS lx_shape
	Top = 332
	Left = 4
	Height = 40
	Width = 342
	Name = "sh_OTB1"
ENDDEFINE


DEFINE CLASS lb_data_otb AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Data OTB:"
	Left = 54
	Top = 179
	Name = "lb_data_otb1"
ENDDEFINE


****
* DEFINIÇÃO CLASSE tv_contrato 
* baseado na classe fk_picklist
* PAULO DEVIDE -> 13-08-2015
*/					
DEFINE CLASS tv_contrato AS fk_picklist
	controlsource = "v_compras_01.ERP_CUPS_ID_CONTRATO"
	left = 340
	top = 110
	name = "tv_contrato1"
	descricao = "NUM_CONTRATO"
	lista_campos = "NUM_CONTRATO,ID_CONTRATO"
	tabela_valida = "CAEDU_CUPS_CONTRATOS"
	p_valida = .f.
	
	PROCEDURE m_valida
		RETURN .t.
	ENDPROC
	
	PROCEDURE tv_descricao.when
		LOCAL llOk1 as Boolean
		llOk1 = .t.
		IF Inlist(Thisformset.p_Tool_Status, "A", "I")
			llOk1 = (this.Parent.p_digita AND (v_compras_01.TOT_QTDE_ORIGINAL=v_compras_01.TOT_QTDE_ENTREGAR))
			IF (v_compras_01.TOT_QTDE_ORIGINAL <> v_compras_01.TOT_QTDE_ENTREGAR)
				MESSAGEBOX("Contrato não pode ser alterado, pois pedido já foi recebido!",16,"Aviso")
			ENDIF
		ENDIF
		RETURN llOk1
	ENDPROC
	
	PROCEDURE tv_descricao.valid
		LOCAL oPesq
		IF "CONTROLES" $ SET( "ClassLib" )
			** Ok, Registry carregado
		ELSE
			SET CLASSLIB TO CONTROLES.vcx ADDITIVE
		ENDIF
						
		oPesq=CREATEOBJECT("controles.tv_valida")
		oPesq.Pesquisa(this.Value, this.parent.lista_campos, this.parent.coluna_retorno, this.parent.tabela_valida, this.Parent.pwhere, this.Parent.p_expressao)

		this.parent.descricao = oPesq.resultado_foco
		this.parent.valor = oPesq.resultado
		
		lcSQL2 = "SELECT * FROM COMPRAS WHERE ERP_CUPS_CONTRATO = '"+oPesq.resultado_foco+"' "
		lcSQL2 = lcSQL2 + " AND PEDIDO <> '"+ALLTRIM(NVL(v_compras_01.PEDIDO,""))+"' AND ERP_CUPS_SEGMENTO <> '"
		lcSQL2 = lcSQL2 + ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,""))+"'"
		
		f_select(lcSQL2,"tmpValidaContrato")
		
		IF RECCOUNT("tmpValidaContrato")>0

			MESSAGEBOX("Este contrato já foi utilizado em outros Pedidos com SEGMENTO diferente deste.",16,"Aviso")

		ELSE
				
			this.Parent.tv_fkey.Value = oPesq.resultado
			this.Value = oPesq.resultado_foco

			IF this.Parent.atualiza_foco
				lcTabela_controle = ALLTRIM(GETWORDNUM(this.Parent.controlSource,1,"."))
				lcCampo_controle = ALLTRIM(GETWORDNUM(this.Parent.controlSource,2,"."))
				SELECT (lcTabela_controle)
				replace &lcCampo_controle. WITH this.parent.valor
			ENDIF
		ENDIF
			
		IF RECCOUNT("tmpValidaContrato")=0

			REPLACE v_compras_01.ERP_CUPS_CONTRATO WITH ALLTRIM(NVL(this.value,''))
		
			IF v_compras_01.TOT_QTDE_ORIGINAL=v_compras_01.TOT_QTDE_ENTREGAR && pedido ainda não recebido

				lcSQL1 = "select ID_CONTRATO,NUM_CONTRATO,CONDICAO_PAGAMENTO, B.DESC_COND_PGTO, B.TIPO_CONDICAO "
				lcSQL1 = lcSQL1 +" from CAEDU_CUPS_CONTRATOS A "
				lcSQL1 = lcSQL1 +" LEFT JOIN COND_ENT_PGTOS B ON B.CONDICAO_PGTO=A.CONDICAO_PAGAMENTO "
				lcSQL1 = lcSQL1 +" where ID_CONTRATO = '"+oPesq.resultado+"'"
				
				f_select(lcSQL1,"tmpCondicao1")
				
				replace v_compras_01.CONDICAO_PGTO WITH tmpCondicao1.CONDICAO_PAGAMENTO
				replace v_compras_01.DESC_COND_PGTO WITH tmpCondicao1.DESC_COND_PGTO
				replace v_compras_01.TIPO_CONDICAO WITH tmpCondicao1.TIPO_CONDICAO 
				
			ENDIF
		
		ENDIF

		this.Parent.p_digita=.f.
		This.Parent.Refresh	
		RELEASE oPesq
				
	ENDPROC	
	
	PROCEDURE tv_descricao.Refresh
		this.readonly = !this.Parent.p_digita
	ENDPROC
	
	
ENDDEFINE


*** 30-07-2015 -> paulo devide
DEFINE CLASS cmdAtualizar AS CommandButton

	Height = 54
	Left = 695
	Top = 374
	Width = 135
	Name = "cmdAtualizar"
	caption = "Atualizar Custo Fob / Packs p/Caixa"
	wordwrap = .t.
	
	PROCEDURE when
		If !Inlist(Thisformset.p_Tool_Status, "A")
			WAIT WINDOW "Atualização só permitida em modo ALTERAÇÃO" TIMEOUT 2
			RETURN .f.
		ENDIF
		
	ENDPROC

	PROCEDURE click

		SELECT V_COMPRAS_01_PRODUTOS
		lnRecAtual = recno("V_COMPRAS_01_PRODUTOS")
		lcProduto = V_COMPRAS_01_PRODUTOS.PRODUTO
		lnCusto_Fob = V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB
		lnCusto_Fob_Min = V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB_MINIMO
		lnPacks_Cxa = V_COMPRAS_01_PRODUTOS.ERP_CUPS_PACKS_POR_CAIXA

		UPDATE V_COMPRAS_01_PRODUTOS ;
		SET V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB = lnCusto_Fob, ; 
			V_COMPRAS_01_PRODUTOS.ERP_CUPS_PACKS_POR_CAIXA =lnPacks_Cxa, ;
			V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB_MINIMO = lnCusto_Fob_Min ; 
		WHERE V_COMPRAS_01_PRODUTOS.PRODUTO = lcProduto

		IF lnRecAtual>0
		   GO lnRecAtual
		ENDIF
		
		MESSAGEBOX("Atualizado!",64,"Aviso")
		
	ENDPROC
	
ENDDEFINE

DEFINE CLASS tx_data_otb AS lx_textbox_base
	Height = 21
	Left = 116
	Top = 179
	Width = 100
	Name = "tx_data_otb1"
	
	PROCEDURE when
		If !Inlist(Thisformset.p_Tool_Status, "A","I")
			WAIT WINDOW "alteração não permitida em modo consulta" TIMEOUT 2
			RETURN .f.
		ENDIF
		
	ENDPROC
	
ENDDEFINE

************************************************************************************************************************************************************
** (Inicio) PAULO DEVIDE - 09-SET-14  fook

DEFINE CLASS lb_cod_cabide AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Código Cabide:"
	Left = 18
	Top = 48
	Name = "lb_cod_cabide1"
ENDDEFINE

*** lista de código de cabides
*!*	3340010F (A43) - top
*!*	A38 - top
*!*	A33 - top
*!*	A26 - top
*!*	M35 - botton
*!*	M26 - botton
*!*	L660 - lingerie

DEFINE CLASS cb_cod_cabide AS lx_combobox
	Height = 21
	Left = 110
	Top = 48
	Width = 84
	Name = "tx_cod_cabide1"

	RowSourceType = 1
	RowSource = ZZ_LISTA_CABIDES_CABILOG

	ControlSource = "v_compras_01.ERP_CAB_COD_CABIDE"
	p_tipo_dado = "EDITA"
ENDDEFINE

DEFINE CLASS lb_cab_cd_entrega AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Cód. CD Entrega:"
	Left = 218
	Top = 48
	Name = "lb_cab_cd_entrega1"
ENDDEFINE


DEFINE CLASS tx_cab_cd_entrega AS lx_textbox_base
	Height = 21
	Left = 318
	Top = 48
	Width = 42
	Name = "tx_cab_cd_entrega1"
	ControlSource = "v_compras_01.ERP_CAB_CD_ENTREGA"
	p_tipo_dado = "MOSTRA"
ENDDEFINE

DEFINE CLASS lb_cab_status AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Status:"
	Left = 18
	Top = 73
	Name = "lb_cab_status1"
ENDDEFINE


DEFINE CLASS tx_cab_status AS lx_textbox_base
	Height = 21
	Left = 110
	Top = 73
	Width = 21
	Name = "tx_cab_status1"
	ControlSource = "v_compras_01.ERP_CAB_STATUS"
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		WAIT WINDOW NOWAIT "Campo não editável"
		RETURN .f. && campo é somente leitura, conteudo é formula
	ENDPROC


ENDDEFINE

DEFINE CLASS lb_cab_localizacao AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Localização:"
	Left = 218
	Top = 73
	Name = "lb_cab_localizacao1"
ENDDEFINE


DEFINE CLASS cb_cab_localizacao AS lx_combobox
	Height = 21
	Left = 318
	Top = 73
	Width = 84
	Name = "cb_cab_localizacao1"
	RowSourceType = 1
	RowSource = "PAREDE,SOLO,TABLE"
	ControlSource = "v_compras_01.ERP_CAB_LOCALIZACAO"
	p_tipo_dado = "MOSTRA"

ENDDEFINE

DEFINE CLASS lb_cab_qtdpecas AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Qtd. Peças:"
	Left = 18
	Top = 98
	Name = "lb_cab_qtdpecas1"
ENDDEFINE


DEFINE CLASS tx_cab_qtdpecas AS lx_textbox_base
	Height = 21
	Left = 110
	Top = 98
	Width = 84
	Name = "tx_cab_qtdpecas1"
	ControlSource = "v_compras_01.ERP_CAB_QTDPECAS"
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		WAIT WINDOW NOWAIT "Campo não editável"
		RETURN .f. && campo é somente leitura, conteudo é formula
	ENDPROC

ENDDEFINE

DEFINE CLASS lb_cab_tipo_pedido AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Tipo Pedido:"
	Left = 218
	Top = 98
	Name = "lb_cab_tipo_pedido1"
ENDDEFINE


DEFINE CLASS cb_cab_tipo_pedido AS lx_combobox
	Height = 21
	Left = 318
	Top = 98
	Width = 100
	Name = "cb_cab_tipo_pedido1"
	RowSourceType = 1
	RowSource = "NORMAL,IMPORTAÇÃO,BONIFICAÇÃO,AMOSTRA"
	ControlSource = "v_compras_01.ERP_CAB_TIPO_PEDIDO"
	p_tipo_dado = "MOSTRA"

ENDDEFINE

DEFINE CLASS ck_cab_encabidado AS lx_checkbox
	Height = 21
	Left = 36
	Top = 20
	Width = 84
	Alignment = 1
	FontBold = .T.
	Caption = "Encabidado?"+SPACE(6)
	Name = "ck_cab_encabidado1"
	ControlSource = "v_compras_01.ERP_CAB_ENCABIDADO"
	p_tipo_dado = "EDITA"

ENDDEFINE

DEFINE CLASS lb_cab_envio AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Data Envio:"
	Left = 18
	Top = 131
	Name = "lb_cab_envio1"
ENDDEFINE

DEFINE CLASS tx_cab_envio AS lx_textbox_base
	Height = 21
	Left = 110
	Top = 128
	Width = 84
	Name = "tx_cab_envio1"
	ControlSource = "v_compras_01.ERP_CAB_DATA_ENVIO"
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		WAIT WINDOW NOWAIT "Campo não editável"
		RETURN .f. && campo é somente leitura, conteudo é formula
	ENDPROC

ENDDEFINE
** (Fim) PAULO DEVIDE - 09-SET-14
************************************************************************************************************************************************************

** (Inicio) PAULO DEVIDE - 31-JUL-14
DEFINE CLASS bt_obs_pack as botao
	caption = 'Preenche OBS'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 162
	top = 3
	left = 85
	HEIGHT =  18
	enabled = .t.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		LOCAL lcObs, lnArea
		lnArea = SELECT()
		IF !INLIST(ThisFormSet.p_Tool_Status,"A")
			MESSAGEBOX("Para editar observação entre em modo de Alteração do Pedido",64,"Aviso")
			SELECT (lnArea)
			RETURN
		ENDIF

		IF "PACK:" $ UPPER(ALLTRIM(V_COMPRAS_01.OBS))
			MESSAGEBOX("Apague manualmente a observação antes de executar a rotina de preenchimento do PACK na observação do pedido",64,"Aviso")
			SELECT (lnArea)
			RETURN
		ENDIF

		lcObs = ALLTRIM(V_COMPRAS_01.OBS)+CHR(13)+CHR(13)+;
			'PACK:'+CHR(13)+;
			REPLICATE('-',120)+ ' ' + CHR(13)
		SELECT v_caedu_compras_produtos_packs
		SCAN
			TEXT TO lcSQL NOSHOW TEXTMERGE
				exec pr_grade_produto_cor ?v_caedu_compras_produtos_packs.pedido,
					?v_caedu_compras_produtos_packs.produto,?v_caedu_compras_produtos_packs.cor_produto
			ENDTEXT
			f_execute(lcSQL,"tmpPack")
			lcObs = lcObs + tmpPack.descricao_grade+CHR(13)
		ENDSCAN

		SELECT V_COMPRAS_01
		IF NOT EMPTY(lcObs)
			replace V_COMPRAS_01.OBS WITH lcObs
		ENDIF
		thisformset.lx_form1.lx_pageframe1.Page5.ed_obs.refresh

		SELECT (lnArea)


	ENDPROC

	*!*		PROCEDURE refresh
	*!*			** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
	*!*			this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	*!*		ENDPROC

ENDDEFINE
** (fim) PAULO DEVIDE - 31-JUL-14

*** PAULO DEVIDE
*** (Inicio) --> 12-09-2014
DEFINE CLASS Tform As Form

	Width = 300
	Height = 110
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Caption = "Exportar Pedido para Excel"

	ADD OBJECT chk As Checkbox WITH;
		Width=100, Height=24, Left=22, Top=30,;
		Caption="Agrupar Pedidos na Planilha?", Autosize=.t., ControlSource = 'llAgrupaPedido'

	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=164, Top=70, ;
		Caption="Cancel" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=234, Top=70, ;
		Caption="Ok", Default=.T.


	PROCEDURE cmd1.Click
		llRespInvoice=.f.
		ThisForm.Release
	ENDPROC

	PROCEDURE cmd2.Click
		llRespInvoice=.t.
		ThisForm.Release
	ENDPROC
	
ENDDEFINE
*** PAULO DEVIDE
*** (Final) --> 12-09-2014

** PAULO DEVIDE -> 22-05-2013
DEFINE CLASS bt_pedido as botao
	caption = 'Pedido Excel'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 502
	HEIGHT =  27
	enabled = .f.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		
		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Formatar Pedido no Excel em Inglês?",292,"Aviso")=6


		IF llRet AND ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,''))<> "ATACADO"

			PUBLIC frmInvoice, llRespInvoice, llAgrupaPedido

			llRespInvoice =.f.
			llAgrupaPedido =.f.
			frmInvoice = CreateObject ("Tform")
			frmInvoice.show(1)
			
			IF llRespInvoice && clicou OK
			
				PUBLIC oExcel as Object
				oExcel = CREATEOBJECT("Excel.Application")
				** Define o nome do arquivo XLSX a ser criado
				lcSQL = "select codigo_modelo,descricao_modelo,imagem_modelo "+;
					"from CAE_MODELOS_EXCEL where codigo_modelo='0001'"

				** Pega o modelo (template em branco) para gerar o Excel do relatório
				f_select(lcSQL,"vCAE_Modelos")

				** Converte a imagem para arquivo binário
				lcTmpArqxls = CAST(vCAE_Modelos.imagem_modelo as blob)

				LOCAL lcArquivo as String
				lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

				STRTOFILE(lcTmpArqxls,lcArquivo) && grava modelo na pasta temporária do usuário
				WITH oExcel				
					.workbooks.open(lcArquivo)
					.Sheets(1).Name = "matriz"
					.visible = .T.
					.DisplayAlerts = .F. && Excel não apresenta caixa de dialogo que solicita confirmação

					** Pega a matriz em branco e duplica "n" vezes a quantidade de registro selecionada na pesquisa						
					IF llAgrupaPedido AND RECCOUNT("v_compras_01")>1
					
						FOR ixx=1 TO RECCOUNT("v_compras_01")
							.Sheets(1).Copy( , .Sheets(ixx))
							.ActiveSheet.name = ALLTRIM(TRANSFORM(ixx,"9999"))
						ENDFOR
						
					ENDIF
					
				ENDWITH

				IF !llAgrupaPedido
					f_wait("Exportando dados para o Excel...")
					LOCAL lcArquivo as String
					lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

					zPedido_Excel(lcArquivo, oExcel)

					f_wait()
				ELSE
					LOCAL lcArquivo as String
					lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

					SELECT V_COMPRAS_01
					GO top
					
					
					lnSheet = 1
					SCAN 					

						f_wait("Exportando dados do Pedido "+V_COMPRAS_01.pedido+"para o Excel...")

						zPedido_Excel(lcArquivo, oExcel, lnSheet)

						f_wait()
						
						lnSheet = lnSheet + 1

					ENDSCAN
					** Exclui planilha matriz em branco
				    oExcel.Sheets("matriz").Select
				    oExcel.ActiveWindow.SelectedSheets.Delete
					oExcel.DisplayAlerts = .T. && volta status Default - Excel solicita confirmação para Salvar, Excluir, etc.
				ENDIF
				
			
			ENDIF
			
			RELEASE frmInvoice, llRespInvoice, oExcel
			SELECT v_compras_01
			GO top
			
		ELSE
		
			IF llRet
			
				IF ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,'')) = "ATACADO"		
					*** chamada do PEDIDO INGLÊS PARA ATACADO
					*** 1 produto por ABA no Excel

					PUBLIC oExcel as Object
					oExcel = CREATEOBJECT("Excel.Application")
					** Define o nome do arquivo XLSX a ser criado
					lcSQL = "select codigo_modelo,descricao_modelo,imagem_modelo "+;
						"from CAE_MODELOS_EXCEL where codigo_modelo='0001'"

					** Pega o modelo (template em branco) para gerar o Excel do relatório
					f_select(lcSQL,"vCAE_Modelos")
					** SET STEP ON
					** Converte a imagem para arquivo binário
					lcTmpArqxls = CAST(vCAE_Modelos.imagem_modelo as blob)

					LOCAL lcArquivo as String
					lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

					STRTOFILE(lcTmpArqxls,lcArquivo) && grava modelo na pasta temporária do usuário

					SELECT distinct PRODUTO ;
					FROM v_compras_01_produtos ;
					INTO CURSOR tmpProdutos1

					WITH oExcel				
						.workbooks.open(lcArquivo)
						.Sheets(1).Name = "matriz"
						.visible = .T.
						.DisplayAlerts = .F. && Excel não apresenta caixa de dialogo que solicita confirmação

						** Pega a matriz em branco e duplica "n" vezes a quantidade de registro selecionada na pesquisa						
						IF RECCOUNT("tmpProdutos1")>1
						
							FOR ixx=1 TO RECCOUNT("tmpProdutos1")
								.Sheets(1).Copy( , .Sheets(ixx))
								.ActiveSheet.name = ALLTRIM(TRANSFORM(ixx,"9999"))
							ENDFOR
							
						ENDIF
						
					ENDWITH


					LOCAL lcArquivo as String
					lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

					SELECT tmpProdutos1
					GO top


					lnSheet = 1
					SCAN 					

						f_wait("Exportando dados do Pedido "+V_COMPRAS_01.pedido+"para o Excel...")

						zPedido_Excel_Atc(lcArquivo, oExcel, lnSheet)

						f_wait()
						
						lnSheet = lnSheet + 1

					ENDSCAN
					** Exclui planilha matriz em branco

					IF oExcel.worksheets(1).name = "matriz"
						oExcel.Sheets("matriz").Select
						oExcel.ActiveWindow.SelectedSheets.Delete
					ENDIF
						
					oExcel.DisplayAlerts = .T. && volta status Default - Excel solicita confirmação para Salvar, Excluir, etc.
					

					RELEASE oExcel

					SELECT v_compras_01
					GO top
					
				ENDIF
				
			ENDIF
				
		ENDIF


	ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC

ENDDEFINE
** FIM: 22-05-2013


FUNCTION ZORIGEM_PEDIDO_IMPORTADO
** VERIFICA OS PRODUTOS NO CAMPO TRIBUT_ORIGEM, SE ENCONTRAR PELO MENOS UM PRODUTO COM VALOR = '1' ENTÃO ORIGEM É ESTRANGEIRA
** RETORNA .T. SE FOR ESTRANGEIRO E .F. SE NÃO FOR
LOCAL lnArea as Integer, llRet as Boolean
llRet = .f.
lnArea = SELECT()

SELECT DISTINCT PRODUTO ;
FROM V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL ;
WITH (BUFFERING = .T.) ;
INTO CURSOR WPRODUTOS1

SELECT WPRODUTOS1
SCAN 
	F_SELECT("SELECT TRIBUT_ORIGEM FROM PRODUTOS WHERE PRODUTO = '"+ALLTRIM(WPRODUTOS1.PRODUTO)+"'","tmpTributOrigem")
	IF ALLTRIM(NVL(tmpTributOrigem.TRIBUT_ORIGEM,""))="1"
		llRet = .T.
		EXIT
	ENDIF
ENDSCAN

SELECT (lnArea)
RETURN llRet

ENDFUNC



*************************************
* (INICIO) PAULO DEVIDÉ -> 09/12/14
* lnMargem, passado por referencia '@'
FUNCTION zcalcula_margem
PARAMETERS lcProduto, lnCustoInformado, lcMsgFollowUp, lnMargem 
LOCAL lnArea
lnArea = SELECT()
**SET STEP ON
** AINDA NÃO FORAM DEFINADAS REGRAS DE MARGEM PARA O ATACADO - CUPS - MAIO/15
IF ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,'')) = "ATACADO"
	
	RETURN .t.
	
ELSE
	
	IF USED("tmpMargem")
		SELECT tmpMargem
		USE
	ENDIF
		
	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT PRODUTOS_PRECOS.PRODUTO,PRODUTOS_PRECOS.CODIGO_TAB_PRECO,
		PRODUTOS_PRECOS.PRECO1,PRODUTOS.TRIBUT_ORIGEM
		FROM PRODUTOS_PRECOS
		INNER JOIN PRODUTOS ON PRODUTOS.PRODUTO=PRODUTOS_PRECOS.PRODUTO
		WHERE PRODUTOS_PRECOS.CODIGO_TAB_PRECO IN ('00','01')
		AND PRODUTOS_PRECOS.PRODUTO = '<<lcProduto>>'
	ENDTEXT

	f_select(lcSQL,"tmpMargem")

	** localiza o preço de custo
	SELECT tmpMargem
	LOCATE FOR tmpMargem.CODIGO_TAB_PRECO = '00'
	lnCustoOriginal = tmpMargem.PRECO1

	lcMsgFollowUp = "" &&STRTRAN(lcMsgFollowUp,"@@lnCustoOriginal@@",TRANSFORM(lnCustoOriginal,"999,999.99"))  

	** localiza o preço de custo
	SELECT tmpMargem
	LOCATE FOR tmpMargem.CODIGO_TAB_PRECO = '01'
	lnPrecoVenda = tmpMargem.PRECO1

	lcMsgFollowUp = "" &&STRTRAN(lcMsgFollowUp,"@@lnPrecoVenda@@",TRANSFORM(lnPrecoVenda,"999,999.99"))  

	SELECT (lnArea)
	lnMargem = ((lnPrecoVenda-lnCustoInformado)/lnPrecoVenda)*100

	lcMsgFollowUp = "" &&STRTRAN(lcMsgFollowUp,"@@lnMargem@@",TRANSFORM(lnMargem,"999,999.99"))  

	lcOrigem = IIF(ALLTRIM(tmpMargem.TRIBUT_ORIGEM)='0',"Nacional","Importado")
	lcMsgFollowUp = "" &&STRTRAN(lcMsgFollowUp,"@@lcOrigem@@",lcOrigem)  

	llStatus = .T.
	IF (ALLTRIM(tmpMargem.TRIBUT_ORIGEM)='0') && Nacional = 51% (margem minima)

		IF lnMargem < o_004006.pp_palma_margem_minima_nac
			llStatus = .f.
		ENDIF
		
	ELSE && importado = 62% (margem minima)

		IF lnMargem < o_004006.pp_palma_margem_minima_imp
			llStatus = .f.
		ENDIF

	ENDIF

	lcMsgFollowUp = "" &&STRTRAN(lcMsgFollowUp,"@@llStatus@@",IIF(llStatus," OK","NOK"))  

	RETURN llStatus
	
ENDIF

ENDFUNC
*
* (FIM) PAULO DEVIDÉ -> 09/12/14
********************************

*********************************** 
* (INICIO) PAULO DEVIDÉ -> 06/11/14
*
FUNCTION ZVALIDA_SENHA(tcCargo, tcMensagem) 
	IF PCOUNT()<2
		tcMensagem=""
	ENDIF
	
	IF UPPER(ALLTRIM(SYS(0))) = "NOTE-JUNIOR # ROBERTO"
		MESSAGEBOX(tcMensagem+CHR(13)+"Senha para NOTE-JUNIOR # ROBERTO está Ok!",64,"Aviso")
		RETURN .t.
	ENDIF
	
	PUBLIC frmLoginWindows
	PUBLIC gcLogin, gcPwd, llOk_ad
	
	llOk_ad = .f.
	gcLogin = ""
	gcPwd = ""
	
	IF EMPTY(NVL(tcMensagem,""))
		tcMensagem = "..."
	ENDIF
	
	frmLoginWindows = CreateObject ("TformLoginWindows")
	frmLoginWindows.Caption = frmLoginWindows.Caption + "["+tcCargo+"]"
	frmLoginWindows.lblMensagem.Caption = SUBSTR(ALLTRIM(tcMensagem),1,250)	
	frmLoginWindows.show(1)						

	IF llOk_ad
		
		lcUsuario = "CCP\"+ALLTRIM(UPPER(gcLogin))
		
		IF UPPER(tcCargo)="DIRETOR"
			TEXT TO lcsql NOSHOW TEXTMERGE
				  SELECT par.usuario FROM  PARAMETROS_USERS par
			    	  WHERE parametro like 'PALMA_DIRETOR_CPA_ENT'
			 		     	  and usuario = ?lcUsuario
			ENDTEXT

			If Used("x_Diretor")
				Use In x_Diretor
			Endif

			f_select(lcsql,"x_Diretor")
			
			If Reccount("x_Diretor") = 0
				Messagebox("Usuario sem permissão de [diretor] p/ liberar alteração!",16,"Avisos")
				Return .F.
			ELSE
				WAIT WINDOW "Validado!" TIMEOUT 1	
			ENDIF
		ENDIF
		
		IF UPPER(tcCargo)="GERENTE"
			TEXT TO lcsql NOSHOW TEXTMERGE
				  SELECT par.usuario FROM  PARAMETROS_USERS par
			    	  WHERE parametro like 'PALMA_GERENTE_CPA_ENT'
			 		     	  and usuario = ?lcUsuario
			ENDTEXT

			If Used("x_Gerente")
				Use In x_Gerente
			Endif

			f_select(lcsql,"x_Gerente")
			
			If Reccount("x_Gerente") = 0
				Messagebox("Usuario sem permissão de [GERENTE] p/ liberar alteração!",16,"Avisos")
				Return .F.
			ELSE
				WAIT WINDOW "Validado!" TIMEOUT 1	
			ENDIF
		ENDIF
		
		RETURN .T.
	ELSE
		RETURN .f.
	ENDIF
	
ENDFUNC
*
* (FIM) PAULO DEVIDÉ -> 06/11/14
******************************** 

** PAULO DEVIDE -> 23-05-2013
FUNCTION zvalida_campos_pedido_pack
	LOCAL llOk as Boolean, lcMsg as String
	LOCAL lnTotReg1 as Integer, lnTotReg2 as Integer

	llOk = .t.
	lcMsg = ""
	SELECT v_caedu_compras_produtos_packs
	lnTotReg1 = RECCOUNT("v_caedu_compras_produtos_packs")
	SELECT v_caedu_compras_produtos_packs_total
	lnTotReg2 = RECCOUNT("v_caedu_compras_produtos_packs_total")

	SELECT v_compras_01
	** 1) Tipo de compra
	IF EMPTY(NVL(v_compras_01.tipo_compra,''))
		llOk=.f.
		lcMsg = lcMsg + "Campo [Tipo de Compra] é obrigatório..."
	ENDIF

	** 2) Requerido por:
	IF EMPTY(NVL(v_compras_01.requerido_por,''))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Requerido por] é obrigatório..."
	ENDIF

	** 3) Aprovado/Reprovado:
	IF EMPTY(NVL(v_compras_01.aprovador_por,''))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Aprovado/Reprovado] é obrigatório..."
	ENDIF

	** 4) Natureza Entrada:
	IF EMPTY(NVL(v_compras_01.natureza_entrada,''))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Natureza entrada] é obrigatório..."
	ENDIF

	** 5) Data de Entrega:
	IF EMPTY(NVL(pdEntrega,CTOD('')))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Data de Entrega] é obrigatório..."
	ENDIF

	** 6) Data de Limite de Entrega:
	IF EMPTY(NVL(pdLimite,CTOD('')))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Limite de Entrega] é obrigatório..."
	ENDIF

	** 7) Observação:
*!*		IF EMPTY(NVL(v_compras_01.OBS,''))
*!*			llOk=.f.
*!*			lcMsg = lcMsg + CHR(13)+ "Campo [Observação] é obrigatório..."
*!*		ENDIF

	** 8) Validar se existe itens cadastrados e com quantidade/valor:
	IF EMPTY(NVL(v_compras_01.tot_valor_original,0))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "É obrigatório informar os itens do pedido..."
	ENDIF

	** 9) Validar se os grid´s da aba PACK contem registro
	IF lnTotReg1=0
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "É obrigatório informar os itens na aba PACKs..."
	ENDIF

	IF lnTotReg2=0
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "É obrigatório ter registro totalizador na aba PACKs..."
	ENDIF


	*********************************************
	***          SANDRA ONO - 27/05/2014     ****
	*********************************************
	****************** INICIO********************
	*********************************************
	*** Formula	 DA CONSISTENCIA DE ITENS DE PACK
	*********************************************
	*!*	D 	Item do Pedido
	*!*	A	Qtde total do Pedido
	*!*	B	Qtde total do item do Pack
	*!*	C	Item do Pack
	*!*	D = (A/B)*C
	*********************************************

	*checagem de cor

	SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
	GO top
	scan
		SELECT v_compras_01_produtos
		GO top
		LOCATE FOR ALLTRIM(v_compras_01_produtos.produto)+ALLTRIM(v_compras_01_produtos.cor_produto) = ;
			ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto) + ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto)

		IF !FOUND()
			llOk=.f.
			MESSAGEBOX("Erro na cor:"+V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto + " Verifique",16,"Aviso")
		ENDIF
		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
	endscan

	SELECT v_compras_01_produtos
	GO top
	scan
		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
		GO top
		LOCATE FOR ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto) + ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto) = ;
			ALLTRIM(v_compras_01_produtos.produto)+ALLTRIM(v_compras_01_produtos.cor_produto)
		IF !FOUND()
			llOk=.f.
			MESSAGEBOX("Erro na cor:"+v_compras_01_produtos.cor_produto + " Verifique",16,"Aviso")
		ENDIF

		SELECT v_compras_01_produtos
	endscan
	*!*		A = v_compras_01_produtos.QTDE_ORIGINAL
	*!*		D = "v_compras_01_produtos.CO"+ALLTRIM(PADR(ind,2," "))


	*!* SET STEP ON

	*!*		SELECT v_compras_01
	*!*		XTOT1 = v_compras_01.tot_qtde_original
	*!*		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
	*!*		XTOT2 = V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde
	*!*
	*!*		XPACKTOT = XTOT1   / XTOT2
	*** SET STEP ON
	
	SELECT v_compras_01_produtos
	GO top
	scan
		FOR IND = 1 TO 48
			Itab = "v_compras_01_produtos.CO"+ALLTRIM(PADR(ind,2," "))
			ptab = "V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q"+ALLTRIM(PADR(ind,2," "))

			XPACKTOT = ZCALC_TOTPACK(v_compras_01_produtos.produto)
			
			XVALORCOL = &Itab. / XPACKTOT

			SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
			GO top
			LOCATE FOR ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto) + ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto) = ;
				ALLTRIM(v_compras_01_produtos.produto)+ALLTRIM(v_compras_01_produtos.cor_produto)

			IF !FOUND()
				llOk=.f.
				MESSAGEBOX("Erro na cor:"+v_compras_01_produtos.cor_produto + " Verifique",16,"Aviso")
			ELSE
				IF &ptab. <> XVALORCOL
					llOk=.f.
					MESSAGEBOX("Erro na cor:"+v_compras_01_produtos.cor_produto + " Verifique",16,"Aviso")
				endif
			endif

		ENDFOR


		SELECT v_compras_01_produtos
	ENDSCAN

	Ln_erro_pack = .F.


	SELECT v_compras_01_produtos
	GO top
	scan
		FOR IND = 1 TO 48
			A = v_compras_01_produtos.QTDE_ORIGINAL
			D = "v_compras_01_produtos.CO"+ALLTRIM(PADR(ind,2," "))
			SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
			LOCATE FOR V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.produto = v_compras_01_produtos.produto
			*AND V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.cor_produto = v_compras_01_produtos.cor_produto

			IF !FOUND()
				lcMsg = "A cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] não está cadastrada no Total geral de packs (LISTA ABAIXO)"
				Ln_erro_pack = .T.
				LN_ITEM = IND
				EXIT

			ELSE
				IF  !Ln_erro_pack
					K = "V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q"+ALLTRIM(PADR(ind,2," "))
					J = "V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q"+ALLTRIM(PADR(ind,2," "))
					SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
					SUM &K. TO LNTotal1
					SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
					SUM &J. TO LNTotal2

					if LNTotal1 != LNTotal2
						lcMsg = "O TAMANHO POSICAO ["+ALLTRIM(PADL(IND,2,"0"))+ "] está com problemas na soma do Total geral de packs (LISTA ABAIXO)"
						Ln_erro_pack = .T.
						LN_ITEM = IND
						EXIT
					ENDIF
				Endif

				IF  !Ln_erro_pack
					if V_CAEDU_COMPRAS_PRODUTOS_PACKS.Qtde != V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Qtde
						lcMsg = "A cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] está com problemas na soma do Total geral de packs (LISTA ABAIXO)"
						Ln_erro_pack = .T.
						LN_ITEM = IND
						EXIT

					ENDIF
				Endif
			ENDIF

			IF  !Ln_erro_pack

				SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
				LOCATE FOR V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto = v_compras_01_produtos.produto  and;
					V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto = v_compras_01_produtos.cor_produto

				IF FOUND()
					B = V_CAEDU_COMPRAS_PRODUTOS_PACKS.Qtde
					C = "V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q"+ALLTRIM(PADR(ind,2," "))
					Total_D = (A/B)*&C.
					IF Total_D != &D.
						Ln_erro_pack = .T.
						LN_ITEM = IND
						lcMsg = "Quantidades dos tamanhos dos itens do Pedido da cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] não estão compativeis com a quantidade dos itens dos packs."
						EXIT
					ENDIF
				ELSE
					Ln_erro_pack = .T.
					LN_ITEM = IND
					lcMsg ="Quantidades dos tamanhos dos itens do Pedido da cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] não estão compativeis com a quantidade dos itens dos packs."
					EXIT
				Endif
			Endif
		ENDFOR
		IF Ln_erro_pack
			llOk=.f.
			***lcMsg =  "Quantidades dos tamanhos dos itens do Pedido da cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] não estão compativeis com a quantidade dos itens dos packs."
			****MESSAGEBOX(lcMsg,16,"Aviso")
			exit
		ENDIF
		SELECT v_compras_01_produtos
	Endscan

	*********************************************
	***          SANDRA ONO - 27/05/2014     ****
	*********************************************
	***************   FIM       *****************
	*********************************************



	IF NOT EMPTY(lcMsg)
		MESSAGEBOX(lcMsg,16,"Aviso")
	ENDIF

	RETURN llOk
ENDFUNC
** Fim: 23-05-2013



** PAULO DEVIDE -> 22-05-2013 --> alterado em 15-set-14 impressao de varios pedidos
FUNCTION zPedido_Excel
	PARAMETERS tcArquivo, oExcel, lnSheet

	IF PARAMETERS()<3
		lnSheet = 0 && imprime só um pedido 
	ENDIF
	
	** Querys de dados do relatório
	SELECT v_compras_01_produtos
	=REQUERY("v_compras_01_produtos")
	GO top
	MPRODUTO = ALLTRIM(v_compras_01_produtos.produto)

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM produtos
		where produto = ?v_compras_01_produtos.produto
	ENDTEXT
	f_select(lcSQL,"cur_produtos")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select RAZAO_SOCIAL AS buyer
		,RTRIM(LTRIM(ENDERECO))+' - '+RTRIM(LTRIM(COMPLEMENTO))+
		' - '+RTRIM(LTRIM(BAIRRO))+' - '+RTRIM(LTRIM(CIDADE))+' - '+RTRIM(LTRIM(UF)) AS adress
		,CEP AS zip_code ,CGC_CPF as CNPJ
		from CADASTRO_CLI_FOR where CLIFOR = '000040'
	ENDTEXT
	f_select(lcSQL,"cur_filial40")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select COLECAO,DESC_COLECAO
		from COLECOES where COLECAO=?v_compras_01_produtos.colecao
	ENDTEXT
	f_select(lcSQL,"cur_colecao")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select MATERIAIS_COMPOSICAO.COMPOSICAO,  MATERIAIS_COMPOSICAO.DESC_COMPOSICAO
		From PRODUTOS
		LEFT JOIN MATERIAIS_COMPOSICAO ON MATERIAIS_COMPOSICAO.COMPOSICAO = PRODUTOS.COMPOSICAO
		WHERE PRODUTOS.PRODUTO=?v_compras_01_produtos.produto
	ENDTEXT
	f_select(lcSQL,"cur_composicao")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM prop_compras WHERE pedido=?v_compras_01.pedido
	ENDTEXT
	f_select(lcSQL,"cur_prop_compras")
	**

	f_select("select * from produtos_precos where produto = ?v_compras_01_produtos.produto and codigo_tab_preco='40'","cur_preco_venda")


	WITH oExcel && objeto publico passado de parametro para esta função
		IF lnSheet = 0
			.Sheets(1).Name = ALLTRIM(v_compras_01.pedido)
		ELSE
    		.Sheets(ALLTRIM(TRANSFORM(lnSheet,"9999"))).Select
		    .ActiveSheet.Name = ALLTRIM(v_compras_01.pedido)
		ENDIF

		m.request_no = v_compras_01.pedido
		m.article_no = v_compras_01_produtos.produto

		m.buyer = ALLTRIM(NVL(cur_filial40.buyer,''))
		m.adress = ALLTRIM(NVL(cur_filial40.adress,''))
		m.zip_code = TRANSFORM(ALLTRIM(NVL(cur_filial40.zip_code,'')),"@R 99999-999")
		m.cnpj = TRANSFORM(ALLTRIM(NVL(cur_filial40.cnpj,'')),"@R 99.999.999/9999-99")

		m.collection1 = ALLTRIM(NVL(cur_colecao.desc_colecao,''))
		m.depto = v_compras_01_produtos.griffe
		m.line1 = v_compras_01_produtos.linha
		m.composition = ALLTRIM(NVL(cur_composicao.desc_composicao,''))
		m.type1 = ALLTRIM(NVL(cur_produtos.tipo_produto,''))

		** CUPS --> Propriedade 00068 é AGORA produtos.ERP_CUPS_STYLENUMBER
		*m.supp_ref = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00068',cur_prop_compras.propriedade),'') &&ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))
		m.supp_ref = ALLTRIM(NVL(cur_produtos.ERP_CUPS_STYLENUMBER,'')) &&+ "/V"

		m.sizes = ALLTRIM(NVL(cur_produtos.grade,''))
		** PAULO DEVIDE --> 06/10/2014
		**m.supp_ref = ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))

*!*			m.cust_fob = STRTRAN(ALLTRIM(NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00030',cur_prop_compras.propriedade),'')),",",".")
*!*			m.cust_fob = CAST(m.cust_fob as numeric(14,2))

		m.amount = '=H17*M17'
		m.sales_price = cur_preco_venda.preco1 &&V_COMPRAS_01_PRODUTOS.custo1

		m.profoma_invoice = v_compras_01.ERP_CUPS_CONTRATO &&NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00028',cur_prop_compras.propriedade),'')
		
		** PROJETO CUPS - MUDOU PARA CAMPO COMPRAS.ERP_CUPS_EMBARQUE_ATUAL
		** m.shipment_date = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00029',cur_prop_compras.propriedade),'')

		SET CENTURY ON
		SET DATE BRITISH
		m.shipment_date = v_compras_01.ERP_CUPS_DATA_ACORDADA &&DTOC(v_compras_01.ERP_CUPS_DATA_ACORDADA)
		
		IF NOT EMPTY(m.shipment_date)
			** Data convertida para formato numérico do Excel
			m.shipment_date = (Val(Sys(11, NVL(m.shipment_date,CTOD("")))) - Val(Sys(11, {30/12/1899})))
		ENDIF

*!*			m.packs_of = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00031',cur_prop_compras.propriedade),0)
*!*			m.quantity_of_packs = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00032',cur_prop_compras.propriedade),0)

		** Cursor detalhe (itens do pedido)
		IF USED("cur_itens_pedido")
			SELECT cur_itens_pedido
			USE
		ENDIF

		CREATE CURSOR cur_itens_pedido ( ;
			PRODUTO C(12) NULL,;
			INDICE INT NULL,;
			CODIGO_BARRA C(25) NULL,;
			DESCRICAO C(40) NULL,;
			COR C(40) NULL,;
			TAMANHO C(8) NULL,;
			QTD INT NULL )

		SELECT v_compras_01_produtos
		GO top
		
		** PROJETO CUPS --> agora pega no item do pedido
		m.cust_fob = v_compras_01_produtos.ERP_CUPS_CUSTO_FOB


		LOCAL lnCont as Integer
		m.quantity_of_packs = 0
		SCAN
			
			FOR lnCont=1 TO 48
				lcCampo = "v_compras_01_produtos.co"+ALLTRIM(TRANSFORM(lnCont,"99"))
				lnCampo_value = NVL(EVALUATE(lcCampo),0)
				IF NOT EMPTY(lnCampo_value)

					TEXT TO lcSQL NOSHOW TEXTMERGE
						select PRODUTOS_BARRA.*
						from PRODUTOS
						LEFT JOIN PRODUTOS_BARRA ON PRODUTOS_BARRA.PRODUTO = PRODUTOS.PRODUTO
						WHERE PRODUTOS.PRODUTO = '<<v_compras_01_produtos.produto>>'
							AND COR_PRODUTO = '<<v_compras_01_produtos.cor_produto>>'
							and TAMANHO = <<lnCont>>
					ENDTEXT
					f_select(lcSQL,"cur_produto_barra")

					SELECT cur_itens_pedido
					APPEND BLANK
					REPLACE PRODUTO WITH v_compras_01_produtos.produto
					REPLACE INDICE WITH lnCont
					REPLACE CODIGO_BARRA WITH ALLTRIM(cur_produto_barra.CODIGO_BARRA)
					REPLACE DESCRICAO WITH ALLTRIM(v_compras_01_produtos.DESC_PRODUTO)
					REPLACE COR WITH v_compras_01_produtos.DESC_COR_PRODUTO
					REPLACE TAMANHO WITH cur_produto_barra.GRADE
					REPLACE QTD WITH lnCampo_value

				ENDIF

			ENDFOR

			m.packs_of = v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA 
			m.quantity_of_packs = m.quantity_of_packs + v_compras_01_produtos.QTDE_ORIGINAL

		ENDSCAN

		
		*** Pega o Pack total agrupado do produto - Paulo Devide -> 20-07-2015
		lnArea = SELECT()
		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		=REQUERY("V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL")
		LOCATE FOR ALLTRIM(produto) = MPRODUTO 
		SELECT (lnArea)
		
		M.PACKS_OF = V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde
		
		IF m.packs_of>0
			m.quantity_of_packs = m.quantity_of_packs/m.packs_of
		ELSE
			m.quantity_of_packs = 0
		ENDIF
		
		
		SELECT cur_itens_pedido
		INDEX on PRODUTO+COR+STR(INDICE,2,0) TAG IND01
		SET ORDER TO TAG IND01
		GO TOP

		.range("N2").value = m.request_no
		.range("N4").value = m.article_no

		.range("C8").value = m.buyer
		.range("C9").value = m.adress
		.range("C11").value = m.zip_code
		.range("C12").value = m.cnpj

		.range("C15").value = m.collection1
		.range("C16").value = m.depto
		.range("C17").value = m.line1
		.range("C18").value = m.composition
		.range("C19").value = m.type1

		.range("H15").value = m.sizes
		.range("H16").value = m.supp_ref
		.range("H17").value = m.cust_fob
		.range("H18").value = m.amount
		.range("H19").value = m.sales_price

		.range("M15").value = m.profoma_invoice
		.range("M16").value = m.shipment_date
		.range("M17").value = m.packs_of
		.range("M18").value = m.quantity_of_packs

    	.Range("L19").value = "Order:"
	    .Range("L19").Select
	    .Selection.Font.Bold = .t.
    	.Range("N19").value = "RETAIL" && varejo
    
		*** Formatação dos Itens do Pedido
		IF RECCOUNT("cur_itens_pedido")>0

			lnLinha = 24
			FOR lnRec = 1 TO RECCOUNT("cur_itens_pedido")
				.Rows("24:24").Select
				.Selection.Copy
				lcLinha = ALLTRIM(TRANSFORM(lnLinha+lnRec,"9999"))
				.Rows(lcLinha+":"+lcLinha).Select
				.Selection.Insert(-4121)
			ENDFOR

			SELECT cur_itens_pedido
			SCAN

				lcLinha = ALLTRIM(TRANSFORM(lnLinha,"9999"))
				.range("B"+lcLinha).value = "'"+ALLTRIM(NVL(cur_itens_pedido.CODIGO_BARRA,''))
				.range("D"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.DESCRICAO,''))
				.range("I"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.COR,''))
				.range("L"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.TAMANHO,''))
				.range("N"+lcLinha).value = cur_itens_pedido.QTD

				lnLinha = lnLinha + 1
			ENDSCAN

			lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+3 as char(4)))
			.Range("N"+lcLinhaFormula).Select
			.ActiveCell.FormulaR1C1 = "=SUM(R[-"+ALLTRIM(TRANSFORM(RECCOUNT("cur_itens_pedido")+3,"9999"))+"]C:R[-4]C)"

			lnQtdTotal = CAST(.Range("N"+lcLinhaFormula).Value as Int)
			.range("H18").value = m.cust_fob * lnQtdTotal

			lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+6 as char(4)))
			.Range("B"+lcLinhaFormula).value = ALLTRIM(v_compras_01.obs)
		ENDIF

		.range("A1").select
		.ActiveWorkbook.Save

	ENDWITH

	SELECT v_compras_01_produtos
	GO top

ENDFUNC
** Fim: 22-05-2013

FUNCTION zPedido_Excel_Atc
	PARAMETERS tcArquivo, oExcel, lnSheet

	IF PARAMETERS()<3
		lnSheet = 0 && imprime só um produto do pedido 
	ENDIF
	
	** Querys de dados do relatório
	SELECT v_compras_01_produtos
	=REQUERY("v_compras_01_produtos")
	GO top

	LOCATE FOR PRODUTO = tmpProdutos1.PRODUTO
	
	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM produtos
		where produto = ?tmpProdutos1.produto
	ENDTEXT
	f_select(lcSQL,"cur_produtos")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select RAZAO_SOCIAL AS buyer
		,RTRIM(LTRIM(ENDERECO))+' - '+RTRIM(LTRIM(COMPLEMENTO))+
		' - '+RTRIM(LTRIM(BAIRRO))+' - '+RTRIM(LTRIM(CIDADE))+' - '+RTRIM(LTRIM(UF)) AS adress
		,CEP AS zip_code ,CGC_CPF as CNPJ
		from CADASTRO_CLI_FOR where CLIFOR = '000040'
	ENDTEXT
	f_select(lcSQL,"cur_filial40")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select COLECAO,DESC_COLECAO
		from COLECOES where COLECAO=?v_compras_01_produtos.colecao
	ENDTEXT
	f_select(lcSQL,"cur_colecao")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select MATERIAIS_COMPOSICAO.COMPOSICAO,  MATERIAIS_COMPOSICAO.DESC_COMPOSICAO
		From PRODUTOS
		LEFT JOIN MATERIAIS_COMPOSICAO ON MATERIAIS_COMPOSICAO.COMPOSICAO = PRODUTOS.COMPOSICAO
		WHERE PRODUTOS.PRODUTO=?tmpProdutos1.produto
	ENDTEXT
	f_select(lcSQL,"cur_composicao")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM prop_compras WHERE pedido=?v_compras_01.pedido
	ENDTEXT
	f_select(lcSQL,"cur_prop_compras")
	**

	f_select("select * from produtos_precos where produto = ?tmpProdutos1.produto and codigo_tab_preco='AT'","cur_preco_venda")


	WITH oExcel && objeto publico passado de parametro para esta função
		IF lnSheet = 0
			.Sheets(1).Name = ALLTRIM(tmpProdutos1.PRODUTO) &&ALLTRIM(v_compras_01.pedido)
		ELSE
			***
			* {Paulo Devidé - 20-07-15}
			*/
			IF .Sheets.Count>1
    			.Sheets(ALLTRIM(TRANSFORM(lnSheet,"9999"))).Select
    		ELSE
	    		.Sheets("matriz").Select
    		ENDIF
		    .ActiveSheet.Name = ALLTRIM(tmpProdutos1.PRODUTO) &&ALLTRIM(v_compras_01.pedido)
		ENDIF

		m.request_no = v_compras_01.pedido
		m.article_no = tmpProdutos1.PRODUTO &&v_compras_01_produtos.produto

		m.buyer = ALLTRIM(NVL(cur_filial40.buyer,''))
		m.adress = ALLTRIM(NVL(cur_filial40.adress,''))
		m.zip_code = TRANSFORM(ALLTRIM(NVL(cur_filial40.zip_code,'')),"@R 99999-999")
		m.cnpj = TRANSFORM(ALLTRIM(NVL(cur_filial40.cnpj,'')),"@R 99.999.999/9999-99")

		m.collection1 = ALLTRIM(NVL(cur_colecao.desc_colecao,''))
		m.depto = v_compras_01_produtos.griffe
		m.line1 = v_compras_01_produtos.linha
		m.composition = ALLTRIM(NVL(cur_composicao.desc_composicao,''))
		m.type1 = ALLTRIM(NVL(cur_produtos.tipo_produto,''))

		** CUPS --> Propriedade 00068 é AGORA produtos.ERP_CUPS_STYLENUMBER
		*m.supp_ref = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00068',cur_prop_compras.propriedade),'') &&ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))
		m.supp_ref = ALLTRIM(NVL(cur_produtos.ERP_CUPS_STYLENUMBER,'')) &&+ "/A"

		m.sizes = ALLTRIM(NVL(cur_produtos.grade,''))
		** PAULO DEVIDE --> 06/10/2014
		**m.supp_ref = ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))

*!*			m.cust_fob = STRTRAN(ALLTRIM(NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00030',cur_prop_compras.propriedade),'')),",",".")
*!*			m.cust_fob = CAST(m.cust_fob as numeric(14,2))

		m.amount = '=H17*M17'
		m.sales_price = cur_preco_venda.preco1 &&V_COMPRAS_01_PRODUTOS.custo1
		
		m.profoma_invoice = v_compras_01.ERP_CUPS_CONTRATO &&NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00028',cur_prop_compras.propriedade),'')
		
		** PROJETO CUPS - MUDOU PARA CAMPO COMPRAS.ERP_CUPS_EMBARQUE_ATUAL
		** m.shipment_date = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00029',cur_prop_compras.propriedade),'')
		SET CENTURY ON
		SET DATE BRITISH
		m.shipment_date = v_compras_01.ERP_CUPS_DATA_ACORDADA &&DTOC(v_compras_01.ERP_CUPS_DATA_ACORDADA) &&DTOC(v_compras_01.ERP_CUPS_EMBARQUE_ATUAL)
		
		IF NOT EMPTY(m.shipment_date)
			** Data convertida para formato numérico do Excel
			m.shipment_date = (Val(Sys(11, NVL(m.shipment_date,CTOD("")))) - Val(Sys(11, {30/12/1899})))
		ENDIF

*!*			m.packs_of = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00031',cur_prop_compras.propriedade),0)
*!*			m.quantity_of_packs = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00032',cur_prop_compras.propriedade),0)

		** Cursor detalhe (itens do pedido)
		IF USED("cur_itens_pedido")
			SELECT cur_itens_pedido
			USE
		ENDIF

		CREATE CURSOR cur_itens_pedido ( ;
			PRODUTO C(12) NULL,;
			INDICE INT NULL,;
			CODIGO_BARRA C(25) NULL,;
			DESCRICAO C(40) NULL,;
			COR C(40) NULL,;
			TAMANHO C(8) NULL,;
			QTD INT NULL )


		SELECT produto,SUM(qtde_original) as qtde_original ;
		FROM v_compras_01_produtos WITH (BUFFERING=.T.) ;
		WHERE PRODUTO = tmpProdutos1.PRODUTO ;
		GROUP BY produto INTO CURSOR vtotal_produto1
		
					
		SELECT v_compras_01_produtos
		LOCATE FOR PRODUTO = tmpProdutos1.PRODUTO
		
		*GO top 

		** PROJETO CUPS --> agora pega no item do pedido
		m.cust_fob = v_compras_01_produtos.ERP_CUPS_CUSTO_FOB

		SELECT vtotal_produto1
		LOCAL lnCont as Integer
		m.quantity_of_packs = 0

		DIMENSION laBarCode[3,2]
		laBarCode[1,1] = NVL(cur_produtos.ERP_CUPS_CODEBAR_REF,'')
		laBarCode[2,1] = NVL(cur_produtos.ERP_CUPS_CODEBAR_PB,'')
		laBarCode[3,1] = NVL(cur_produtos.ERP_CUPS_CODEBAR_CX,'')
		**------------------------------------------------------------------**
		*** Pega o Pack total agrupado do produto - Paulo Devide -> 20-07-2015
		lnArea = SELECT()
		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		LOCATE FOR produto = v_compras_01_produtos.produto
		SELECT (lnArea)
		
		laBarCode[1,2] = 0 &&V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde &&v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA * vtotal_produto1.qtde_original 
		laBarCode[2,2] = 0 &&vtotal_produto1.qtde_original
		laBarCode[3,2] = 0 &&IIF(v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA>0,CEILING(vtotal_produto1.qtde_original / v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA),0)
		
		lcDescr_Peca = "Piece;Master Polybag;Carton"

		FOR lnCont=1 TO 3

				SELECT cur_itens_pedido
				APPEND BLANK
				REPLACE PRODUTO WITH vtotal_produto1.produto
				REPLACE INDICE WITH lnCont
				REPLACE CODIGO_BARRA WITH laBarCode[lnCont,1]
				REPLACE DESCRICAO WITH ALLTRIM(cur_Produtos.DESC_PRODUTO)
				REPLACE COR WITH GETWORDNUM(lcDescr_Peca,lnCont,";")
				REPLACE TAMANHO WITH ''
				REPLACE QTD WITH laBarCode[lnCont,2]


		ENDFOR

		m.packs_of = V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde &&v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA 
		IF V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde>0
			m.quantity_of_packs = vtotal_produto1.QTDE_ORIGINAL / V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde &&m.quantity_of_packs + v_compras_01_produtos.QTDE_ORIGINAL
		ELSE
			m.quantity_of_packs = 0
		ENDIF

		
*!*			IF m.packs_of>0
*!*				m.quantity_of_packs = m.quantity_of_packs/m.packs_of
*!*			ELSE
*!*				m.quantity_of_packs = 0
*!*			ENDIF
		
		
		SELECT cur_itens_pedido
*!*			INDEX on PRODUTO+COR+STR(INDICE,2,0) TAG IND01
		INDEX on PRODUTO+STR(INDICE,2,0) TAG IND01
		SET ORDER TO TAG IND01
		GO TOP

		.range("N2").value = m.request_no
		.range("N4").value = m.article_no

		.range("C8").value = m.buyer
		.range("C9").value = m.adress
		.range("C11").value = m.zip_code
		.range("C12").value = m.cnpj

		.range("C15").value = m.collection1
		.range("C16").value = m.depto
		.range("C17").value = m.line1
		.range("C18").value = m.composition
		.range("C19").value = m.type1

		.range("H15").value = m.sizes
		.range("H16").value = m.supp_ref
		.range("H17").value = m.cust_fob
		.range("H18").value = m.amount
		.range("H19").value = m.sales_price

		.range("M15").value = m.profoma_invoice
		.range("M16").value = m.shipment_date
		.range("M17").value = m.packs_of
		.range("M18").value = m.quantity_of_packs

    	.Range("L19").value = "Order:"
	    .Range("L19").Select
	    .Selection.Font.Bold = .t.
    	.Range("N19").value = "WHOLESALE" && atacado

		*** Formatação dos Itens do Pedido
		IF RECCOUNT("cur_itens_pedido")>0

			lnLinha = 24
			FOR lnRec = 1 TO RECCOUNT("cur_itens_pedido")
				.Rows("24:24").Select
				.Selection.Copy
				lcLinha = ALLTRIM(TRANSFORM(lnLinha+lnRec,"9999"))
				.Rows(lcLinha+":"+lcLinha).Select
				.Selection.Insert(-4121)
			ENDFOR

			SELECT cur_itens_pedido
			SCAN

				lcLinha = ALLTRIM(TRANSFORM(lnLinha,"9999"))
				.range("B"+lcLinha).value = "'"+ALLTRIM(NVL(cur_itens_pedido.CODIGO_BARRA,''))
				.range("D"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.DESCRICAO,''))
				.range("I"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.COR,''))
				.range("L"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.TAMANHO,''))
				.range("N"+lcLinha).value = '' &&cur_itens_pedido.QTD

				lnLinha = lnLinha + 1
			ENDSCAN

			lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+3 as char(4)))
			.Range("N"+lcLinhaFormula).Select
			.ActiveCell.FormulaR1C1 = '' &&"=SUM(R[-"+ALLTRIM(TRANSFORM(RECCOUNT("cur_itens_pedido")+3,"9999"))+"]C:R[-4]C)"
			.Range("K"+lcLinhaFormula).value = ''
			
			lnQtdTotal = CAST(.Range("N"+lcLinhaFormula).Value as Int)
			.range("H18").value = m.cust_fob * lnQtdTotal

			lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+6 as char(4)))
			.Range("B"+lcLinhaFormula).value = ALLTRIM(v_compras_01.obs)
		ENDIF

		.range("A1").select
		.ActiveWorkbook.Save

	ENDWITH

	SELECT v_compras_01_produtos
	GO top

ENDFUNC


*--------------------------------------------------------
* Function Name.: rbInputBox()
*
* Author........: Rick Borup
*                 Information Technology Associates
*                 Champaign, IL U.S.A.
*                 http://www.ita-software.com
*                 rborup@ita-software.com
*
* Date Written..: March 20, 2000
*
* Date Released.: April 27, 2000
*
* Date Revised..: January 30, 2003
*
* Abstract......: A simple, general-purpose input box for Visual FoxPro.
*
* Parameters....: (All parameters are optional.)
*
*    tcPrompt - the prompt that the user sees.
*               The default is "Enter the value".
*
*    tcTitle - the title for the form.
*              The default is "InputBox".
*
*    txDefaultValue - default value.
*              This parameter can be a character, date, numeric, or
*              currency data type. If this parameter is omitted, an
*              empty textbox is displayed and the data type is character.
*              The data type of the return value is the same as the
*              data type of the default value.
*
*    tnLeft - the form's Left position
*
*    tnTop - the form's Top position.
*
*            If Left and Top are omitted or are not numeric, rbInputBox()
*            is auto-centered.
*
*    tcFormat - a value for the Format property of the textbox
*
*    tcInputMask - a value for the InputMask property of the textbox
*
*    tcPasswordChar - a value for the textbox's PasswordChar value
*                     (the default is blank)
*
* Returns.......: Character, Date, Numeric, or Currency depending
*                 on the data type of the default value
*
*                 If the Cancel button is chosen, rbInputBox() returns
*                 an empty value of the appropriate data type.
*
* Copyright.....: Copyright (c) Information Technology Associates, 2000-2003
*
* License.......: rbInputBox() is freeware. You may include rbInputBox()
*                 royalty-free inside a compiled Visual FoxPro APP or EXE
*                 that you create for your own use or for distribution to
*                 a third party.
*
*                 You may redistribute the rbInputBox() distribution
*                 package, INPUTBOX.ZIP, as long as (a) you distribute
*                 INPUTBOX.ZIP in its entirety and without modifications,
*                 and (b) you do not charge anything for it.
*
* Warranty......: NONE. This code is released AS IS without warranty
*                 of any kind. The user assumes all responsibility and
*                 liability for its use.
*
* Support.......: NONE, but your comments and suggestions for improvements
*                 are welcome. Please e-mail rborup@ita-software.com or
*                 reach me via the Universal Thread at
*                 http://www.universalthread.com.
*
* Release History:January 30, 2003 - Renamed as "rbInputBox" to avoid conflict
*                                    with the native InputBox() function in
*                                    VFP 7.0 and later.
*                                  - Added tcPasswordChar as 8th parameter
*
*                 May 2, 2000 - Corrected errata in the readme.txt file.
*
*                 April 27, 2000 - Original Release
*
* Known Limitations:
*                 The original release of rbInputBox does not automatically
*                 resize the form or any of its controls. The current
*                 sizes are designed to be adequate for most simple input
*                 functions. There is no arbitrary limitations, other than
*                 VFP's own inherent limitations, on the size of the return
*                 value. However, long titles, prompts, or entered values may
*                 appear truncated on the form.
*
Function rbInputBox
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	Private pcReturnValue
	pcReturnValue = txDefaultValue
	Local oInputBox
	oInputBox = Createobject("rbInputBox", tcPrompt, tcTitle, ;
		txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar)
	oInputBox.Show()
	Return pcReturnValue



Function rbInputBox2
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	Private pcReturnValue
	pcReturnValue = txDefaultValue
	Local oInputBox
	oInputBox = Createobject("rbInputBox2", tcPrompt, tcTitle, ;
		txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar)
	oInputBox.Show()
	Return pcReturnValue


Function rbMotivo
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar

	Private pcReturnValue
	pcReturnValue = txDefaultValue

	Local oInputBox
	oInputBox = Createobject("rbMotivo", tcPrompt, tcTitle, ;
		txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar)
	oInputBox.Show()

	Return pcReturnValue




	**************************************************
	*-- Class:        rbinputbox
	*-- ParentClass:  form
	*-- BaseClass:    form
	*-- Time Stamp:   01/29/03 01:03:14 PM
	*
Define Class rbInputBox As Form


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


	Add Object lblinputbox As Label With ;
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


	Add Object txtinputbox As TextBox With ;
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


	Add Object cmdok As CommandButton With ;
		Top = 72, ;
		Left = 84, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 3, ;
		Name = "cmdOK"


	Add Object cmdcancel As CommandButton With ;
		Top = 72, ;
		Left = 172, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		TabIndex = 4, ;
		Name = "cmdCancel"


	Procedure Unload
		With Thisform
			If Type(".xReturnValue") = "C"
				.xreturnvalue = Rtrim( .xreturnvalue)
			Endif
			pcReturnValue = .xreturnvalue
		Endwith
	Endproc


	Procedure Init
		Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
			tcFormat, tcInputMask, tcPasswordChar
		If Type("tcPrompt") <> "C"
			tcPrompt = "Enter the value"
		Endif
		If Type("tcTitle") <> "C"
			tcTitle = "Input Box"
		Endif
		If !( Type("txDefaultValue") $ "CDNY")
			*	Valid input data types are C, D, N, and Y
			txDefaultValue = ""	&& default to character data type
		Endif
		If Type("tcFormat") <> "C"
			tcFormat = ""
		Endif
		If Type("tcInputMask") <> "C"
			tcInputMask = ""
		Endif
		If Type("tcPasswordChar") <> "C"
			tcPasswordChar = ""
		Endif
		If Len( Alltrim( tcPasswordChar)) > 1
			tcPasswordChar = Left( tcPasswordChar, 1)
		Endif
		Local llAutoCenter
		If Pcount() < 5	&& Top and Left parameters were not passed
			tnLeft = 0
			tnTop = 0
		Else	&& Top and left parameters were passed but may not be numeric
			If Type("tnTop") = "N" And Type("tnLeft") = "N"		&& both are numeric
				llAutoCenter = .F.
			Else	&& one or both is not numeric, so AutoCenter the form
				tnLeft = 0
				tnTop = 0
				llAutoCenter = .T.
			Endif
		Endif

		With Thisform
			**!* SET STEP ON
			.lblinputbox.Caption = Alltrim( tcPrompt)
			.Caption = Alltrim( tcTitle)
			.xdefaultvalue = txDefaultValue
			.xreturnvalue = .xdefaultvalue
			.txtinputbox.Value = .xdefaultvalue
			.txtinputbox.Format = Alltrim( tcFormat)
			.txtinputbox.InputMask = Alltrim( tcInputMask)
			.txtinputbox.maxlength = 0
			.txtinputbox.PasswordChar = tcPasswordChar
			.Top = tnTop
			.Left = tnLeft
			.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

			Do Case
				Case Type("txDefaultValue") = "D"
					.xemptyvalue = {}
				Case Type("txDefaultValue") = "N"
					.xemptyvalue = 0
				Case Type("txDefaultValue") = "Y"
					.xemptyvalue = $0
				Otherwise
					.xemptyvalue = ""
			Endcase
		Endwith
	Endproc


	Procedure cmdok.Click
		With Thisform
			.xreturnvalue = .txtinputbox.Value
			.Release()
		Endwith
	Endproc


	Procedure cmdcancel.Click
		*
		*	If Cancel was chosen, return the empty value of the correct data type.
		*
		With Thisform
			.xreturnvalue = .xemptyvalue
			.Release()
		Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************












Define Class lx_compr_rolos_m_vol As Container


	Width = 162
	Height = 47
	Name = "lx_compr_rolos_m_vol1"
	BorderWidth = 0
	BackStyle = 0


	Add Object tx_marca_volume As lx_textbox_base With ;
		ControlSource = "v_compras_01.marca_volumes", ;
		Height = 21, ;
		Left = 104, ;
		TabIndex = 11, ;
		Top = 26, ;
		Width = 58, ;
		Name = "tx_marca_volume"


	Add Object lx_label5 As lx_label With ;
		AutoSize = .F., ;
		Caption = "Marca Volumes", ;
		Height = 15, ;
		Left = 0, ;
		Top = 29, ;
		Width = 100, ;
		TabIndex = 46, ;
		Name = "Lx_label5"


	Add Object tx_cmprimento_rolos As lx_textbox_base With ;
		ControlSource = "v_compras_01.comprimento_de_rolos", ;
		Height = 22, ;
		InputMask = "999.9999", ;
		Left = 104, ;
		TabIndex = 10, ;
		Top = 0, ;
		Width = 58, ;
		Name = "tx_cmprimento_rolos"


	Add Object lx_label4 As lx_label With ;
		AutoSize = .F., ;
		Caption = "Comprimento", ;
		Height = 15, ;
		Left = 0, ;
		Top = 4, ;
		Width = 100, ;
		TabIndex = 45, ;
		p_muda_size = .F., ;
		Name = "Lx_label4"


	Procedure tx_marca_volume.l_desenhista_recalculo
		If v_Compras_01.Marca_Volumes > 100

			f_Msg(['Marca volumes não deve passar de 100% !', 0+48, 'Atenção'])
			Return .F.

		Endif

		Return .T.
	Endproc


	Procedure tx_cmprimento_rolos.l_desenhista_recalculo
		If v_Compras_01.Comprimento_de_Rolos > 100

			f_Msg(['O comprimento não deve passar de 100% !', 0+48, 'Atenção'])
			Return .F.

		Endif

		Return .T.
	Endproc


Enddefine




**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
Define Class rbInputBox2 As Form


	Height = 113
	Width = 378
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


	Add Object lbluser As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Usuário", ;
		Height = 20, ;
		Left = 6, ;
		Top = 16, ;
		Width = 190, ;
		TabIndex = 1, ;
		Name = "lblUser"


	Add Object txtUser As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 2, ;
		Top = 12, ;
		Width = 140, ;
		Name = "txtUser"
	ControlSource = "xUserSenha.Usuario"


	Add Object lblinputbox As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Enter the value", ;
		Height = 20, ;
		Left = 6, ;
		Top = 46, ;
		Width = 190, ;
		TabIndex = 3, ;
		Name = "lblInputBox"


	Add Object txtinputbox As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 4, ;
		Top = 42, ;
		Width = 140, ;
		Name = "txtInputBox"


	Add Object cmdok As CommandButton With ;
		Top = 72, ;
		Left = 184, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 5, ;
		Name = "cmdOK"


	Add Object cmdcancel As CommandButton With ;
		Top = 72, ;
		Left = 272, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		TabIndex = 6, ;
		Name = "cmdCancel"


	Procedure Unload
		With Thisform
			If Type(".xReturnValue") = "C"
				.xreturnvalue = Rtrim( .xreturnvalue)
			Endif
			pcReturnValue = .xreturnvalue
		Endwith
	Endproc


	Procedure Init
		Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
			tcFormat, tcInputMask, tcPasswordChar
		If Type("tcPrompt") <> "C"
			tcPrompt = "Enter the value"
		Endif
		If Type("tcTitle") <> "C"
			tcTitle = "Input Box"
		Endif
		If !( Type("txDefaultValue") $ "CDNY")
			*     Valid input data types are C, D, N, and Y
			txDefaultValue = ""     && default to character data type
		Endif
		If Type("tcFormat") <> "C"
			tcFormat = ""
		Endif
		If Type("tcInputMask") <> "C"
			tcInputMask = ""
		Endif
		If Type("tcPasswordChar") <> "C"
			tcPasswordChar = ""
		Endif
		If Len( Alltrim( tcPasswordChar)) > 1
			tcPasswordChar = Left( tcPasswordChar, 1)
		Endif
		Local llAutoCenter
		If Pcount() < 5   && Top and Left parameters were not passed
			tnLeft = 0
			tnTop = 0
		Else  && Top and left parameters were passed but may not be numeric
			If Type("tnTop") = "N" And Type("tnLeft") = "N"            && both are numeric
				llAutoCenter = .F.
			Else  && one or both is not numeric, so AutoCenter the form
				tnLeft = 0
				tnTop = 0
				llAutoCenter = .T.
			Endif
		Endif

		With Thisform
			.lblinputbox.Caption = Alltrim( tcPrompt)
			.Caption = Alltrim( tcTitle)
			.xdefaultvalue = txDefaultValue
			.xreturnvalue = .xdefaultvalue
			.txtinputbox.Value = .xdefaultvalue
			.txtinputbox.Format = Alltrim( tcFormat)
			.txtinputbox.InputMask = Alltrim( tcInputMask)
			.txtinputbox.PasswordChar = tcPasswordChar
			.Top = tnTop
			.Left = tnLeft
			.AutoCenter = llAutoCenter         && Set AutoCenter last so it overrides Top and Left if .T.

			Do Case
				Case Type("txDefaultValue") = "D"
					.xemptyvalue = {}
				Case Type("txDefaultValue") = "N"
					.xemptyvalue = 0
				Case Type("txDefaultValue") = "Y"
					.xemptyvalue = $0
				Otherwise
					.xemptyvalue = ""
			Endcase
		Endwith
	Endproc


	Procedure cmdok.Click
		With Thisform

			IF f_vazio(.txtUser.Value)
				MESSAGEBOX("Informe o Usuário!")
				RETURN
			endif

			.xreturnvalue = .txtinputbox.Value

			*!*               Select xUserSenha
			*!*               Zap
			*!*               Append Blank
			Replace usuario With Alltrim(.txtUser.Value) IN xUserSenha



			.Release()
		Endwith
	Endproc




	Procedure cmdcancel.Click
		*
		*     If Cancel was chosen, return the empty value of the correct data type.
		*
		With Thisform
			.xreturnvalue = .xemptyvalue
			.Release()
		Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************




**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
Define Class rbMotivo As Form


	Height = 113
	Width = 318
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Motivo"
	ControlBox = .F.
	WindowType = 1
	Name = "frmMotivoAlt"

	*-- empty value to return if Cancel is chosen; data type depends on data type of txValueIn
	xemptyvalue = .F.

	*-- the default value (if any)
	xdefaultvalue = .F.

	*-- the return value
	xreturnvalue = .F.


	Add Object lblMotivo As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "MOTIVO", ;
		Height = 20, ;
		Left = 35, ;
		Top = 6, ;
		Width = 60, ;
		TabIndex = 1, ;
		Name = "lblUser"


	Add Object cboMotivo As Combobox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 50, ;
		TabIndex = 2, ;
		Top = 22, ;
		Width = 250, ;
		style = 2,;
		Name = "cboMotivo"



	Add Object cmdok As CommandButton With ;
		Top = 72, ;
		Left = 230, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "OK", ;
		TabIndex = 6, ;
		Name = "cmdOK"



	Procedure Unload
		With Thisform
			If Type(".xReturnValue") = "C"
				.xreturnvalue = Rtrim( .xreturnvalue)
			Endif
			pcReturnValue = .xreturnvalue
		Endwith
	Endproc


	Procedure Init

		Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
			tcFormat, tcInputMask, tcPasswordChar
		If Type("tcPrompt") <> "C"
			tcPrompt = "Enter the value"
		Endif
		If Type("tcTitle") <> "C"
			tcTitle = "Input Box"
		Endif
		If !( Type("txDefaultValue") $ "CDNY")
			*	Valid input data types are C, D, N, and Y
			txDefaultValue = ""	&& default to character data type
		Endif
		If Type("tcFormat") <> "C"
			tcFormat = ""
		Endif
		If Type("tcInputMask") <> "C"
			tcInputMask = ""
		Endif
		If Type("tcPasswordChar") <> "C"
			tcPasswordChar = ""
		Endif
		If Len( Alltrim( tcPasswordChar)) > 1
			tcPasswordChar = Left( tcPasswordChar, 1)
		ENDIF

		Local llAutoCenter
		If Pcount() < 5	&& Top and Left parameters were not passed
			tnLeft = 0
			tnTop = 0
		Else	&& Top and left parameters were passed but may not be numeric
			If Type("tnTop") = "N" And Type("tnLeft") = "N"		&& both are numeric
				llAutoCenter = .F.
			Else	&& one or both is not numeric, so AutoCenter the form
				tnLeft = 0
				tnTop = 0
				llAutoCenter = .T.
			Endif
		Endif

		With Thisform
			*!*
			*!*			.lblinputbox.Caption = Alltrim( tcPrompt)
			.Caption = "Motivo da Alteração de Entrega"
			*!*			.xdefaultvalue = txDefaultValue
			*!*			.xreturnvalue = .xdefaultvalue
			*!*			.txtinputbox.Value = .xdefaultvalue
			*!*			.txtinputbox.Format = Alltrim( tcFormat)
			*!*			.txtinputbox.InputMask = Alltrim( tcInputMask)
			*!*			.txtinputbox.PasswordChar = tcPasswordChar

			.cbomotivo.rowsourcetype  = 1
			.cbomotivo.rowsource = "Alteração compras,Alteração Fornecedor"
			.cbomotivo.requery()

			.Top = tnTop
			.Left = tnLeft
			.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

			Do Case
				Case Type("txDefaultValue") = "D"
					.xemptyvalue = {}
				Case Type("txDefaultValue") = "N"
					.xemptyvalue = 0
				Case Type("txDefaultValue") = "Y"
					.xemptyvalue = $0
				Otherwise
					.xemptyvalue = ""
			ENDCASE


		Endwith
	Endproc


	Procedure cmdok.Click
		With Thisform

			IF f_vazio(.cboMotivo.Value)
				MESSAGEBOX("Informe o MOTIVO!")
				RETURN
			endif



			xmot = .cboMotivo.Value

			Replace motivo With Alltrim(xmot) IN xUserSenha



			f_insert("insert into CAEDU_COMPRAS_ENTREGA_LOG (PEDIDO, DATA_ALTERACAO_ENTREGA, DATA_ENTREGA, DATA_ENTREGA_NOVA, MOTIVO, USUARIO ) "+;
				" values (?V_COMPRAS_01.PEDIDO, getdate(), ?x_entreg_atu.entrega , ?v_compras_01_produtos.entrega, ?xmot, ?wusuario )")

			=REQUERY('V_CAEDU_LOG_ENTRADA')

			thisform.Visible = .f.


			.Release()

		Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************


DEFINE CLASS TformLoginWindows As Form

	Width = 350
	Height = 380
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Caption = "Login e Senha da Rede Windows - "

	gcLogin = ""
	gcPwd = ""

	ADD OBJECT lblLogin as Label WITH;
		Width=200, Height=25, Left=20, Top=35, Caption = "Login"
	
	ADD OBJECT lblSenha as Label WITH;
		Width=200, Height=25, Left=20, Top=65, Caption = "Password"

	ADD OBJECT txtLogin as Textbox WITH;
		Width=200, Height=25, Left=100, Top=30, controlsource = "gcLogin"
	
	ADD OBJECT txtSenha as Textbox WITH;
		Width=200, Height=25, Left=100, Top=60, controlsource = "gcPwd", Passwordchar = "*"

	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=218, Top=350, ;
		Caption="Cancel" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=284, Top=350, ;
		Caption="Ok", Default=.T.

	ADD OBJECT lblMensagem as Label WITH;
		Width=300, Height=200, Left=10, Top=90, Caption = "", Autosize = .f., Wordwrap = .T.

	PROCEDURE init
		=CAPSLOCK(.F.)
		WAIT WINDOW "CAPSLOCK is off" TIMEOUT 0.5		
	ENDPROC
	
	PROCEDURE cmd1.Click
		ThisForm.Release
	ENDPROC

	PROCEDURE cmd2.Click
		llOk_ad = zvalida_login(gcLogin, gcPwd)
		IF llOk_ad
			MESSAGEBOX("Login Autenticado com sucesso!",64,"Aviso")
		ELSE
			MESSAGEBOX("Falha na Autenticação do Login!",64,"Aviso")
		ENDIF
		
		ThisForm.Release
	ENDPROC
	
ENDDEFINE

***
* PAULO DEVIDE - 12-NOV-2014
* OBJETIVO: VALIDA CONTRA O Active Directory (AD) do Windows, se o Login e a Senha
* 			informado pelo usuário está correto.
*/
FUNCTION zvalida_login
***********************
PARAMETERS tcLogin, tcPwd
DSODomaine = GetObject("LDAP:")
STRUSER=ALLTRIM(tcLogin)
STRCLAVE=ALLTRIM(tcPwd)
STRDOMAIN="CCP"
ADS_SECURE_AUTHENTICATION=1

TRY 

	DSOContainer = DSODomaine.OpenDSObject("LDAP://"+STRDOMAIN,STRUSER,STRCLAVE,ADS_SECURE_AUTHENTICATION)
	llOk = .t.

	
CATCH TO err
	*MESSAGEBOX(err.message,16,"Aviso")
	llOk = .f.
	
	
ENDTRY

RETURN llOk
ENDFUNC

***
* PROJETO CUPS
*/
FUNCTION zcalc_totpack
PARAMETERS tcProduto
lnArea = SELECT()
SELECT vcur_total_produto
LOCATE FOR vcur_total_produto.produto = tcProduto

SELECT (lnArea)

RETURN ( vcur_total_produto.PACKTOTAL )


***
* data_excel - retorna data no formato numerico do Excel
* parametros varialvel_data no formato Date do foxpro
* PAULO DEVIDE - 27-07-2015
*/
FUNCTION data_excel
PARAMETERS tcData1
RETURN CAST(SYS(11,tcData1) as int) - CAST(SYS(11,{30/12/1899}) as int)
ENDFUNC


FUNCTION ZAUTORIZA_ATACADO
	lnArea = SELECT()
	SELECT * FROM curpropcompras WITH (BUFFERING=.T.) ;
		WHERE ALLTRIM(PROPRIEDADE) = "00077" ;
		INTO CURSOR tmp_autoriza
	llRet = UPPER(ALLTRIM(NVL(tmp_autoriza.valor_propriedade,"")))=="SIM"		
	SELECT (lnArea)
	IF llRet
		MESSAGEBOX("Autorização para Transferência Atacado foi liberada!",48,"Aviso")
	ENDIF
	
	RETURN llRet
ENDFUNC
