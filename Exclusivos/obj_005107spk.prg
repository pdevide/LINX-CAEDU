**************************
** 26-fev-2015
** PAULO EDUARDO DEVIDE
**

*- Definindo a classe do objeto de entrada que sera criado na Form.
Define Class obj_entrada As Custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	Procedure metodo_usuario
		Lparam xmetodo, xobjeto, xnome_obj


		Do Case

			CASE Upper(xmetodo) == 'USR_INCLUDE_AFTER'

			CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TX_ENTREGA_UNICA'

			CASE Upper(xmetodo) == 'USR_ALTER_BEFORE'

			CASE Upper(xmetodo) == 'USR_INIT'
				
				SET CONSOLE off
				SET TALK off
				
			    thisformset.lx_FORM1.lx_pageframe1.activepage=6
			    
				ThisFormset.Lx_form1.Lx_pageframe1.Page6.addobject('bt_nfremessa1', 'bt_nfremessa')
				WITH ThisFormset.Lx_form1.Lx_pageframe1.Page6.bt_nfremessa1
					.height = 27
					.fontname = 'Arial'
					.Caption = 'Gerar NFe Remessa'
					.Left = 24
					.Top = 151
					.Width = 190
					.Visible = .T.
					.Enabled = .T.
					.anchor = 0
					.p_manter_baixo = .f.
					.p_manter_cima = .f.
					.p_manter_direita = .f.
					.p_manter_esquerda = .f.
					.p_muda_size = .f.

				ENDWITH


			CASE Upper(xmetodo) == 'USR_SAVE_BEFORE'


			CASE Upper(xmetodo) == 'USR_SAVE_AFTER' && PAULO DEVIDE --> 25/08/2014



		Endcase

	Endproc

Enddefine



** PAULO DEVIDE -> 26-02-2015
DEFINE CLASS bt_nfremessa as botao
	caption = 'Gerar NFe Remessa'
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
		*llRet = MESSAGEBOX("Deseja Gerar as NFe de Remessa para Armazenagem para o filtro escolhido?",292,"Aviso")=6

		PUBLIC frmChamada, lnRespInvoice

		lnRespInvoice = 1

		frmChamada = CreateObject ("TFormInicio")
		frmChamada.show(1) && 1-Modal /2-Modeless

		PUBLIC frmInvoice, llRespInvoice, llAgrupaPedido

		llRespInvoice =.f.
		llAgrupaPedido =.f.
		frmInvoice = CreateObject ("TForm")
		frmInvoice.show(1) && 1-Modal /2-Modeless

	ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC

ENDDEFINE
** FIM: 26-02-2015


****************************
** PAULO DEVIDE - 26-02-2015
****************************
DEFINE CLASS Tform AS Form 

	ScaleMode = 3
	Height = 338
	Width = 500
	
	DoCreate = .T.
	AutoCenter = .T.
	Closable = .f.
	MinButton = .f.
	MaxButton = .f.
	
	Caption = "Gerar Notas Fiscais de Remessa para GPO Logistica"
	Name = "TForm"
	DataSession = 1


	ADD OBJECT cmdgerar AS botao WITH ;
		Top = 284, ;
		Left = 365, ;
		Height = 53, ;
		Width = 130, ;
		Caption = "Gerar NF-e Processadas", ;
		TabIndex = 6, ;
		Name = "cmdGerar"


	ADD OBJECT cmdCancel AS botao WITH ;
		Top = 284, ;
		Left = 230, ;
		Height = 53, ;
		Width = 130, ;
		Caption = "Cancelar", ;
		TabIndex = 3, ;
		Name = "cmdCancel"



	ADD OBJECT grid1 AS grid WITH ;
		Height = 239, ;
		Left = 3, ;
		TabIndex = 1, ;
		Top = 13, ;
		Width = 314, ;
		Name = "Grid1"


	PROCEDURE LOAD
		IF DODEFAULT()
			
			SET CONSOLE off
			SET TALK off
			
			SET DELETED ON
		 	PUBLIC MPEDIDO1
		    MPEDIDO1 = ""
		    
		    
		    IF USED("VTMP_ENTRADAS_00_ITENS")
		    	SELECT VTMP_ENTRADAS_00_ITENS
		    	USE
		    ENDIF
		    
			SELECT v_entradas_00
			GO top
			
			f_popula_filha('v_entradas_00','v_entradas_00_itens')
			f_wait()
			
			SELECT VTMP_ENTRADAS_00_ITENS
			INDEX on nome_clifor+nf_entrada+serie_nf_entrada TAG indX1
			SET ORDER TO tag indX1
			
		    IF USED("log_NFE_ENTRADA_GPO")
		    	SELECT log_NFE_ENTRADA_GPO
		    	USE
		    ENDIF
			
			CREATE cursor log_NFE_ENTRADA_GPO ;
			(NOME_CLIFOR C(25) null, ;
			NF_ENTRADA C(15) null, ;
			SERIE_NF_ENTRADA C(6) null, ;
			STATUS_UTILIZADO L null )

			
		    IF USED("v_notas_cd")
		    	SELECT v_notas_cd
		    	USE
		    ENDIF

			create cursor v_notas_cd (;
			reg_num int ,;
			nf_saida c(15) ,;
			produto C(12) ,;
			preco1 N(12,2) ,;
			valor_item N(12,2) ,;
			ESTOQUE N(10,0) )

			SELECT v_entradas_00
			GO TOP
			DO WHILE NOT EOF()
			
				IF lnRespInvoice = 1 && GPO-SP
					IF NOT INLIST(ALLTRIM(v_entradas_00.FILIAL),"CD REGIS","CD IMPORTACAO")
						SELECT v_entradas_00
						SKIP
						LOOP
					ENDIF
				ELSE && GPO-SC
					IF NOT INLIST(ALLTRIM(v_entradas_00.FILIAL),"CD ARAQUARI")
						SELECT v_entradas_00
						SKIP
						LOOP
					ENDIF
				ENDIF
				
				SELECT VTMP_ENTRADAS_00_ITENS
				LOCATE FOR nome_clifor	= v_entradas_00.nome_clifor and ;
					nf_entrada = v_entradas_00.nf_entrada and ;
					serie_nf_entrada = v_entradas_00.serie_nf_entrada

				IF FOUND("VTMP_ENTRADAS_00_ITENS")
					select log_NFE_ENTRADA_GPO
					append blank
					replace NOME_CLIFOR with ALLTRIM(v_entradas_00.nome_clifor)
					replace NF_ENTRADA  with ALLTRIM(v_entradas_00.nf_entrada)
					replace SERIE_NF_ENTRADA with ALLTRIM(v_entradas_00.serie_nf_entrada)
					replace STATUS_UTILIZADO with .t.
				ENDIF
				
				TEXT TO lcSQL NOSHOW TEXTMERGE
					SELECT * FROM CAEDU_CONTROLE_NFE_ENTRADA_GPO
					WHERE nome_clifor	= '<<alltrim(v_entradas_00.nome_clifor)>>' and 
					nf_entrada = '<<ALLTRIM(v_entradas_00.nf_entrada)>>' and 
					serie_nf_entrada = '<<ALLTRIM(v_entradas_00.serie_nf_entrada)>>'
					and STATUS_UTILIZADO = 1
				ENDTEXT
				
				f_select(lcSQL,"tmp_log_NFE_ENTRADA_GPO")
				
				IF RECCOUNT("tmp_log_NFE_ENTRADA_GPO")>0 && achou
					** Ignora esta nota - ja foi utilizada antes
					
				else
					
					SELECT VTMP_ENTRADAS_00_ITENS
					
					SCAN FOR nome_clifor = v_entradas_00.nome_clifor and ;
						nf_entrada = v_entradas_00.nf_entrada and ;
						serie_nf_entrada = v_entradas_00.serie_nf_entrada

						lnPreco_transf = zbusca_preco_item(VTMP_ENTRADAS_00_ITENS.codigo_item)
						SELECT v_notas_cd
						APPEND BLANK
						REPLACE reg_num WITH 0
						REPLACE nf_saida WITH ''
						REPLACE produto WITH VTMP_ENTRADAS_00_ITENS.codigo_item
						REPLACE preco1 WITH lnPreco_transf
						*REPLACE valor_item WITH (lnPreco_transf * VTMP_ENTRADAS_00_ITENS.qtde_item)
						REPLACE ESTOQUE WITH VTMP_ENTRADAS_00_ITENS.qtde_item
						
						SELECT VTMP_ENTRADAS_00_ITENS
						
					ENDSCAN
					
				ENDIF
				
				SELECT v_entradas_00
				SKIP
			ENDDO
			
			SELECT v_notas_cd
			
			
			SELECT v_notas_cd
			
			SELECT ;
				reg_num, ;
				nf_saida, ;
				produto, ;
				MAX(preco1) as preco1, ;
				MAX(preco1*estoque) as valor_item, ;
				SUM(estoque) as estoque ;
			from v_notas_cd ;
			group by reg_num, nf_saida, produto ;
			into cursor curEstoque_CD readwrite

			
			*** 
			* Define quantas NFe serão geradas.
			* Está limitado a 800 (antes era 300) itens por nota.
			*
			SELECT curEstoque_CD
			replace ALL reg_num WITH RECNO() ,;
						VALOR_ITEM WITH curEstoque_CD.PRECO1 * curEstoque_CD.ESTOQUE 

			lnTotReg = RECCOUNT()
			lnTotItensPorNota = 800 &&300			
			
			PUBLIC lnTotNFs
			lnTotNFs = CEILING(lnTotReg/lnTotItensPorNota)

			lnNota = 1
			SCAN 

				IF MOD(reg_num,lnTotItensPorNota)=0
					replace nf_saida WITH ALLTRIM(TRANSFORM(lnNota,"999999"))
					lnNota = lnNota + 1
				ELSE
					replace nf_saida WITH ALLTRIM(TRANSFORM(lnNota,"999999"))
				ENDIF
					
			ENDSCAN

		SELECT curEstoque_CD
		GO top

							
		ENDIF
		
	ENDPROC
	

	PROCEDURE cmdgerar.Click
		IF MESSAGEBOX("Confirma Geração de NF-e de Remessa para as notas de entrada selecionadas no Grid?",292,"Aviso")<>6
			RETURN
		ENDIF

		IF RECCOUNT("curEstoque_CD")=0
			MESSAGEBOX("Não há DADOS para gerar a Nota Fiscal, "+CHR(13)+;
						"ou as notas do período do filtro selecionado "+CHR(13)+;
						"já foram utilizadas anteriormente para gerar "+CHR(13)+;
						"NFe de Remessa para Armazenagem.",64, "Atenção")
			RETURN
			
		ENDIF
		
		IF "GPO" $ SET( "ClassLib" )
			** Ok, Registry carregado
		ELSE
			SET CLASSLIB TO GPO.vcx ADDITIVE
		ENDIF

		objGPO = CREATEOBJECT("FUNCOES_GPO")
		
		IF lnRespInvoice = 1 && GPO-SP
		
			objGPO.filial = "CD REGIS"
			objGPO.serie_nf_saida = "1"
			objGPO.operador_logistico = "GPO LOGISTICA SP"

		ELSE && GPO-SC

			objGPO.filial = "CD ARAQUARI"
			objGPO.serie_nf_saida = "02"
			objGPO.operador_logistico = "GPO LOGISTICA SC"
		
		ENDIF

		******************************************************************
		*** INICIO DO PROCESSAMENTO
		******************************************************************
		** Executa rotinas para geração de "n" notas de remessa de "n" itens

		objGPO.cria_cursores()
		lcMsg = ""
		FOR lnNota = 1 TO lnTotNFs 

			** Limpa os cursores
			objGPO.truncate_cursores()

			** Gera um número sequencial de NF de faturamento
			objGPO.nf_saida = F_SEQUENCIAIS_ESPECIAL("faturamento_sequenciais", "sequencial", "filial = ?objGPO.filial and serie_nf = ?objGPO.serie_nf_saida", .T.)
			
			lcMsg = lcMsg + objGPO.nf_saida + CHR(13)
			
			** Popula o cursor curFaturamento (tabela pai)
			objGPO.popula_nf_estoque_faturamento(objGPO.filial, objGPO.serie_nf_saida, objGPO.nf_saida, objGPO.operador_logistico)
			
			SELECT curEstoque_CD
			lcNota = ALLTRIM(TRANSFORM(lnNota,"9999")) 

			lnValor_item = 0
			lnQtdItens = 0

			lnItem = 1
			SCAN FOR ALLTRIM(curEstoque_CD.nf_saida)=lcNota

				lcMsgWait = "Processando NF "+objGPO.nf_saida+" item: "+PADL(lnItem,4,"0")
				f_wait(lcMsgWait)
				
				objGPO.busca_produto(curEstoque_CD.produto) && monta cursor curProdutos com os dados do produto lido
				
				** inclui 1 linha de faturamento_item para cada produto lido
				objGPO.popula_nf_estoque_faturamento_item(objGPO.filial, objGPO.serie_nf_saida, objGPO.nf_saida, lnItem)
				
				** Inclui 4 linhas com os impostos 1 - ICMS/ 2 - IPI/ 5 - PIS/ 6 - COFINS - para cada produto lido
				objGPO.popula_nf_estoque_faturamento_imposto(objGPO.filial, objGPO.serie_nf_saida, objGPO.nf_saida, lnItem)
				
				SELECT curEstoque_CD

				lnItem = lnItem + 1
				lnValor_item = lnValor_item + curEstoque_CD.valor_item && somatório dos valores dos itens	
				lnQtdItens = lnQtdItens + curEstoque_CD.estoque && somatório dos valores das quantidades
				
			ENDSCAN
			
			SELECT curFaturamento
			replace curFaturamento.VALOR_TOTAL WITH lnValor_item 
			replace curFaturamento.QTDE_TOTAL with lnQtdItens 
			replace curFaturamento.VOLUMES with (lnItem - 1)
			replace curFaturamento.MPADRAO_VALOR_SUB_ITENS with lnValor_item 
			replace curFaturamento.MPADRAO_VALOR_TOTAL with lnValor_item 
			replace curFaturamento.VALOR_SUB_ITENS with lnValor_item 
			
			** Descarrega cursor no SQL
			objGPO.inclui_nf_remessa() && persiste no banco SQL
			f_wait()

		ENDFOR

		*** Atualiza o log 	
		select log_NFE_ENTRADA_GPO
		SCAN

			TEXT TO lcSQL NOSHOW TEXTMERGE
				INSERT INTO CAEDU_CONTROLE_NFE_ENTRADA_GPO (NOME_CLIFOR,NF_ENTRADA,SERIE_NF_ENTRADA,STATUS_UTILIZADO)
				values ('<<log_NFE_ENTRADA_GPO.NOME_CLIFOR>>','<<log_NFE_ENTRADA_GPO.NF_ENTRADA>>','<<log_NFE_ENTRADA_GPO.SERIE_NF_ENTRADA>>',1)
			ENDTEXT
		 		
			f_execute(lcSQL)
			
			select log_NFE_ENTRADA_GPO
			
		ENDSCAN

		
		******************************************************************
		*** FINAL DO PROCESSAMENTO		
		******************************************************************
		MESSAGEBOX("Processo Concluído"+CHR(13)+"Notas geradas:"+CHR(13)+lcMsg,64,"Aviso")
		Thisform.release
	ENDPROC


	PROCEDURE cmdCancel.Click
		Thisform.release
	ENDPROC


	PROCEDURE grid1.Init
	
		lcCampos =  "reg_num;nf_saida;produto;preco1;estoque"
		lcHeaders = "#;NFe;Item;Valor R$;Qtde."
				
		SELECT curEstoque_CD
		GO top

		WITH this

			.ColumnCount = 5
			.ReadOnly = .t.
			.Enabled = .t.
			.DeleteMark= .F.
			.RecordSource = "curEstoque_CD"

			.anchor = 10
			.backcolor = RGB(255,249,234)
			.deletemark = .f.
			.fontname = "Tahoma"
			.fontsize = 8
			.gridLineColor = RGB(215,215,215)
			.GridLines = 2
			.HeaderHeight = 24
			.Height = 249
			.Width = 492
			.Highlightbackcolor = RGB(253,230,181)
			.HighLightForeColor = RGB(0,0,0)
			.HighLightStyle=2
			.Rowheight=16
			

			FOR iqq=1 TO 5
				WITH .Columns(iqq)
					.controlsource = "curEstoque_CD." + GETWORDNUM(lcCampos,iqq,";")
					.ReadOnly= .T.
					.Header1.Caption = GETWORDNUM(lcHeaders,iqq,";")
					.Header1.Alignment = 0
					.Width = 90
				ENDWITH
			ENDFOR
			


		ENDWITH
		THIS.REFRESH

	ENDPROC

	
ENDDEFINE

**************
DEFINE CLASS TformInicio As Form

	Width =200
	Height = 110
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Caption = "Notas GPO"
	DataSession = 1


	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=50, Left=34, Top=30, ;
		Caption="GPO-SP" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=50, Left=104, Top=30, ;
		Caption="GPO-SC", Default=.T.


	PROCEDURE cmd1.Click
		lnRespInvoice = 1
		ThisForm.Release
	ENDPROC

	PROCEDURE cmd2.Click
		lnRespInvoice = 2
		ThisForm.Release
	ENDPROC
	
ENDDEFINE

FUNCTION zbusca_preco_item
PARAMETERS lcProduto
f_select("select preco1 from produtos_precos where codigo_tab_preco = '02' and PRODUTO='"+lcProduto+"'","tmpPreco1")
RETURN tmpPreco1.preco1
ENDFUNC
