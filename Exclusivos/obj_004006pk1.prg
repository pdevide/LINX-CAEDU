***************************************************************************
** PAULO EDUARDO DEVID�
** 18/08/2016 
** OBJETIVO:
** =========
** OBJETO DE ENTRADA TELA DE PEDIDO DE COMPRAS
** UTILIZANDO O PACK DO CADASTRO DE PRODUTOS
***************************************************************************
** ALTERA��ES DA TELA (NOME DO ARQUIVO/DATA/DESCRI��O DA CUSTOMIZA��O)
***************************************************************************
** 004006PK0 - 18/08/2016
** ADEQUA��O DA TELA DE PEDIDOS ORIGINAL DA LINX PARA UTILIZAR 
** OS CONTROLES DE PACK DO CADASTRO DE PRODUTOS
**
** IMPORTA��O DAS CUSTOMIZA��ES DO PROGRAMA 004006PD1 PARA A NOVA TELA 
** DE PEDIDO DE COMPRAS
**
**
***************************************************************************

DEFINE CLASS obj_entrada As Custom

	PROCEDURE metodo_usuario
	LPARAMETERS xmetodo, xobjeto, xnome_obj

	**WAIT WINDOW NOWAIT xmetodo+CHR(13)+NVL(xnome_obj,"...")
	***
	* DEFINE O ROWSOURCE DOS COMBOBOX
	* CABIDES E MOEDAS
	*/
	PRIVATE ZZ_LISTA_CABIDES_CABILOG, ZZ_LISTA_MOEDAS
	
	F_SELECT("select VALOR_ATUAL AS COMBO_LISTA_CABIDES from PARAMETROS WHERE PARAMETRO ='LISTA_CABIDES_CABILOG'","TMPLISTA_COMBO_CABIDES")
	ZZ_LISTA_CABIDES_CABILOG = alltrim(TMPLISTA_COMBO_CABIDES.COMBO_LISTA_CABIDES)

	F_SELECT("select VALOR_ATUAL AS COMBO_LISTA_MOEDAS from PARAMETROS WHERE PARAMETRO = 'PALMA_MOEDA_COMPRAS'","TMPLISTA_COMBO_MOEDAS")
	ZZ_LISTA_MOEDAS = alltrim(TMPLISTA_COMBO_MOEDAS.COMBO_LISTA_MOEDAS)

	*****
	* INICIO DO OBJETO DE ENTRADA
	*/
	DO CASE
	CASE Upper(xmetodo) == 'USR_REFRESH'
		desabilita_toolbar_filha(thisformset)
	
	CASE Upper(xmetodo) == 'USR_INCLUDE_AFTER'

		desabilita_toolbar_filha(thisformset)
		LIMPA_LOG_AUTORIZACAO()
		PROC_004006_INCLUDE_AFTER(THISFORMSET, xmetodo, xobjeto, xnome_obj)
			
	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TX_PEDIDO_ORIGINAL'
		** atribui o conteudo do textbox TX_PEDIDO_ORIGINAL para guardar na propriedade
		** PEDIDO_ORIGINAL_COPIA, pois o conteudo do textbox � apagado ap�s o processamento na tela
		thisformset.PEDIDO_ORIGINAL_COPIA = ALLTRIM(VTMP_PEDIDO_COPIA.pedido_origem)
	
	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='BT_DUPLICA'
		COPIAR_PEDIDO_EXT(thisformset) && copiar campos exclusivos do pedido, que n�o s�o padr�o do Linx
		
	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TV_FORNECEDOR'

		IF ThisFormSet.p_Tool_Status="I" && Somente na inclus�o
			f_select("select * from fornecedores where fornecedor = ?v_compras_01.fornecedor", 'vtmp_forn')
			IF RECCOUNT('vtmp_forn') > 0 
				SELECT v_compras_01
				replace v_compras_01.FILIAL_A_ENTREGAR	WITH NVL(vtmp_forn.ERP_FILIAL_A_ENTREGAR,RTRIM(o_004006.pp_filial_padrao)),;
						v_compras_01.FILIAL_COBRANCA 	WITH NVL(vtmp_forn.ERP_FILIAL_COBRANCA,'MATRIZ'),;
						v_compras_01.FILIAL_A_FATURAR	WITH NVL(vtmp_forn.ERP_FILIAL_A_FATURAR,RTRIM(o_004006.pp_filial_padrao))
			
			ENDIF 
		ENDIF		

	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TX_ENTREGA_UNICA'

		IF ThisFormSet.p_Tool_Status="I" && Somente na inclus�o
			thisformset.lx_form1.lx_pageframe1.Page1.tx_data_otb1.value = xobjeto.value
		ENDIF

	CASE Upper(xmetodo) == 'USR_WHEN' AND UPPER(xnome_obj)='TX_LIMITE_ENTREGA_UNICA'

		IF ThisFormSet.p_Tool_Status="I" && Somente na inclus�o
	
			thisformset.lx_form1.lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.value = xobjeto.value+;
			ICASE(DOW(xobjeto.value)=1,4,DOW(xobjeto.value)=2,3,DOW(xobjeto.value)=3,2,;
			DOW(xobjeto.value)=4,1,DOW(xobjeto.value)=5,7,DOW(xobjeto.value)=6,6,5)

			thisformset.lx_form1.lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.REFRESH
		ENDIF
																		
	
	CASE Upper(xmetodo) == 'USR_ALTER_BEFORE'

		LIMPA_LOG_AUTORIZACAO()
		desabilita_toolbar_filha(thisformset)
		RETURN (PROC_004006_ALTER_BEFORE(THISFORMSET, xmetodo, xobjeto, xnome_obj))
	
	CASE Upper(xmetodo) == 'USR_INIT'
		
		
		INIT_CONFIGURA(THISFORMSET, xmetodo, xobjeto, xnome_obj)
		
		ADICIONA_CONTROLES(THISFORMSET, xmetodo, xobjeto, xnome_obj)
	

	CASE Upper(xmetodo) == 'USR_SAVE_BEFORE'
		*SET STEP ON 
		llCancela = (RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0)
		
		***
		* Se tiver dados de cancelamento, n�o validar 
		* nenhuma regra e permitir salvar o pedido
		*/
		IF llCancela 
			RETURN .t.
		ENDIF
		
		llOk0 = VALIDA_CABILOG(ThisFormSet.lx_form1.lx_pageframe1.pgWarning.lista_erro1, ThisformSet)
		IF !llOk0
			Thisformset.lx_form1.lx_pageframe1.activepage = getPageIndex(Thisformset, "Avisos")
			RETURN llOk0 && retorna falso e interrompe o comando salvar at� que o 
							&& usu�rio corrija os erros e salve novamente.
		ENDIF
		
		PRIVATE pdEntrega, pdLimite
		pdEntrega = ThisFormSet.lx_form1.Lx_pageframe1.Page1.tx_ENTREGA_UNICA.value
		pdLimite = ThisFormSet.lx_form1.Lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.value


		llOk1 = VALIDA_CAMPOS_PEDIDO(ThisFormSet.lx_form1.lx_pageframe1.pgWarning.lista_erro1)

		IF !llOk1
			Thisformset.lx_form1.lx_pageframe1.activepage = getPageIndex(Thisformset, "Avisos")
			RETURN llOk1 && retorna falso e interrompe o comando salvar at� que o 
						&& usu�rio corrija os erros e salve novamente.
		ENDIF
		
		llOk2 = VALIDA_METRICAS_PEDIDO(ThisFormSet.lx_form1.lx_pageframe1.pgWarning.lista_metrica1)

		IF !llOk2
			Thisformset.lx_form1.lx_pageframe1.activepage = getPageIndex(Thisformset, "Avisos")
			
			GRAVA_LOG_AUTORIZACAO()
			
			SELECT V_COMPRAS_01
			REPLACE STATUS_COMPRA WITH '04' && AGUARDANDO SENHA (LIBERA��O)
			
			RETURN .T. &&llOk2 -- retorna falso e interrompe o comando salvar at� que o 
					   && usu�rio corrija os erros e salve novamente.
		ENDIF
			
	CASE Upper(xmetodo) == 'USR_SAVE_AFTER'
	
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
	
	OTHERWISE
		RETURN .T.

	ENDCASE
	*/
	* FIM DO OBJETO DE ENTRADA
	*****

	ENDPROC && fim --> PROCEDURE metodo_usuario

ENDDEFINE

****************************************************************************
******************** FUNCTION E PROCEDURES DA CLASSE ***********************
****************************************************************************

****
* PAULO DEVIDE
* CONFIGURA��ES DO M�TODO USR_INIT
* CRIADO EM: 18/08/2016
*/
FUNCTION INIT_CONFIGURA
	LPARAMETERS objTelaPai, xmetodo, xobjeto, xnome_obj
	WAIT WINDOW NOWAIT "OBJETO"

	objTelaPai.lx_form1.minbutton=.t.
	objTelaPai.lx_form1.maxbutton=.t.

	objTelaPai.lx_form1.lx_pageframe1.TabStretch = 0 && multiple rows (pageframe)

	objTelaPai.lx_form1.Height = objTelaPai.lx_form1.Height + 60
	objTelaPai.lx_form1.Width = objTelaPai.lx_form1.Width + 60

	*** FILTRO PARA N�O PERMITIR USAR CONDICAO DE PAGAMENTO E FORNECEDOR QUE N�O TENHA UMA ID ORACLE VALIDA
	* PAULO DEVIDE - 30-06-2016	
	objTelaPai.LX_FORM1.LX_pageframe1.Page1.TV_condicao_pgto.p_valida_where = " AND EBS_ID_COND_PAGAMENTO IS NOT NULL "
	objTelaPai.LX_FORM1.TV_FORNECEDOR.p_valida_where = " AND EBS_ID_FORNECEDOR IS NOT NULL "
	*********************************************************************************************************************	

	TRY 
		ADDPROPERTY(objTelaPai,"PEDIDO_ORIGINAL_COPIA","")				
	CATCH TO err1
		WAIT WINDOW NOWAIT err1.message
	FINALLY
		objTelaPai.PEDIDO_ORIGINAL_COPIA = ""
		WAIT clear
	ENDTRY

	** Carrega VCX para mem�ria	
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

	*** CURSOR PARA ARMAZENAR O NUMERO DO PEDIDO DE ORIGEM PARA FUN��O COPIA
	CREATE CURSOR VTMP_PEDIDO_COPIA (;
		PEDIDO_ORIGEM C(8) NULL )
	INSERT INTO VTMP_PEDIDO_COPIA VALUES ("")
	SELECT VTMP_PEDIDO_COPIA
	GO TOP	

	Create Cursor ;
		xUserSenha(usuario Varchar(25), motivo Varchar(25))
		
	CREATE CURSOR vCboPack (CODIGO_PACK C(1) NULL)
	
	***
	* TABELA DE METRICAS DO M�DULO DE COMPRAS
	*/	
	TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
		SELECT 
			COD_METRICA, DESC_METRICA, TIPO_DADO 
		FROM 
			CAEDU_METRICAS_LOG_COMPRAS 
		ORDER BY 
			COD_METRICA
	ENDTEXT
	F_SELECT(lcSQL, "vLOG_METRICAS")

	***
	* CRIA O CURSOR V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
	* PARA ARMAZENAR OS AVISOS DE METRICAS DO CABE�ALHO
	*/
	TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
		select * 
		from CAEDU_LOG_AUTORIZA_COMPRAS 
		WHERE 1=0
	ENDTEXT
	F_SELECT(lcSQL, "vtmpLogPedido")
	=AFIELDS(laFields1, "vtmpLogPedido")
	
	CREATE CURSOR V_CAEDU_LOG_AUTORIZA_COMPRAS ;
	FROM ARRAY laFields1
	
	***
	* CRIA O CURSOR V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
	* PARA ARMAZENAR OS AVISOS DE METRICAS DE ITENS
	*/
	TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
		select * 
		from CAEDU_LOG_AUTORIZA_COMPRAS_ITEM 
		WHERE 1=0
	ENDTEXT
	F_SELECT(lcSQL, "vtmpLogPedidoItem")
	=AFIELDS(laFields2, "vtmpLogPedidoItem")
	
	CREATE CURSOR V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM ;
	FROM ARRAY laFields2
	
	USE IN vtmpLogPedidoItem
	USE IN vtmpLogPedido

	objTelaPai.LX_FORM1.LX_pageframe1.PAGE5.TX_pedido_original.controlsource = "VTMP_PEDIDO_COPIA.pedido_origem"
	
	desabilita_toolbar_filha()


	RETURN .T.
ENDFUNC

PROCEDURE COPIAR_PEDIDO_EXT
	LPARAMETERS objTelaPai

	lnArea = SELECT()
	
	**cPedido = ALLTRIM(objTelaPai.LX_FORM1.LX_pageframe1.PAGE5.TX_pedido_original.Value)
	cPedido = objTelaPai.PEDIDO_ORIGINAL_COPIA &&  PEGA da propriedade, 
												&& pois o metodo do Linx limpa a variavel 
	
	TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
		SELECT 
		    PEDIDO
		    ,RATEIO_CENTRO_CUSTO
		    ,RATEIO_FILIAL
		    ,NATUREZA_ENTRADA
		    ,CAEDU_DATA_OTB
		    ,ERP_CONFERENCIA_PACKS
		    ,ERP_CUPS_TIPO_PEDIDO
		    ,ERP_CUPS_SEGMENTO
		    ,ERP_CUPS_DATA_ACORDADA
		    ,ERP_CUPS_PECA_MOSTRUARIO
		    ,ERP_CUPS_EMBARQUE_ATUAL
		    ,ERP_CUPS_EMBARQUE_REAL
		    ,ERP_CUPS_CONTRATO
		    ,ERP_CUPS_CHEGADA_PORTO
		    ,ERP_CUPS_CHEGADA_CD
		    ,ERP_CUPS_PROCESSO_CCF_CCA
		    ,ERP_CUPS_EMBARQUE_LIBERADO
		    ,ERP_CUPS_INCOTERM
		    ,ERP_CUPS_ID_CONTRATO
		    ,ERP_PERCENT_VERBAS
		    ,ERP_IMPORTADO
		    ,ERP_MOEDA
		    ,ERP_TOTAL_QTD_DISTRIB
		    ,ERP_PERCENT_DISTRIB
		    ,ERP_TOTAL_CAIXAS_ORIGINAL
		FROM COMPRAS
		WHERE PEDIDO = '<<cPedido>>'
	ENDTEXT

	F_SELECT(lcSQL,"tmpCompras02")
	SELECT tmpCompras02
	GO TOP
	WAIT WINDOW tmpCompras02.PEDIDO
		
	Select v_Compras_01
	** INICIO: PAULO DEVIDE - 30-JUL-14 **
	** INCLUS�O DOS CAMPOS:
	** NATUREZA_ENTRADA
	** RATEIO_FILIAL
	** RATEIO_CENTRO_CUSTO

	REPLACE v_Compras_01.RATEIO_CENTRO_CUSTO WITH tmpCompras02.RATEIO_CENTRO_CUSTO
	REPLACE v_Compras_01.RATEIO_FILIAL WITH tmpCompras02.RATEIO_FILIAL
	REPLACE v_Compras_01.NATUREZA_ENTRADA WITH tmpCompras02.NATUREZA_ENTRADA
	REPLACE v_Compras_01.CAEDU_DATA_OTB WITH tmpCompras02.CAEDU_DATA_OTB
	REPLACE v_Compras_01.ERP_CUPS_TIPO_PEDIDO WITH tmpCompras02.ERP_CUPS_TIPO_PEDIDO
	REPLACE v_Compras_01.ERP_CUPS_SEGMENTO WITH tmpCompras02.ERP_CUPS_SEGMENTO
	REPLACE v_Compras_01.ERP_CUPS_DATA_ACORDADA WITH tmpCompras02.ERP_CUPS_DATA_ACORDADA
	REPLACE v_Compras_01.ERP_CUPS_PECA_MOSTRUARIO WITH tmpCompras02.ERP_CUPS_PECA_MOSTRUARIO
	REPLACE v_Compras_01.ERP_CUPS_EMBARQUE_ATUAL WITH tmpCompras02.ERP_CUPS_EMBARQUE_ATUAL
	REPLACE v_Compras_01.ERP_CUPS_EMBARQUE_REAL WITH tmpCompras02.ERP_CUPS_EMBARQUE_REAL
	REPLACE v_Compras_01.ERP_CUPS_CONTRATO WITH tmpCompras02.ERP_CUPS_CONTRATO
	REPLACE v_Compras_01.ERP_CUPS_CHEGADA_PORTO WITH tmpCompras02.ERP_CUPS_CHEGADA_PORTO
	REPLACE v_Compras_01.ERP_CUPS_CHEGADA_CD WITH tmpCompras02.ERP_CUPS_CHEGADA_CD
	REPLACE v_Compras_01.ERP_CUPS_PROCESSO_CCF_CCA WITH tmpCompras02.ERP_CUPS_PROCESSO_CCF_CCA
	REPLACE v_Compras_01.ERP_CUPS_EMBARQUE_LIBERADO WITH tmpCompras02.ERP_CUPS_EMBARQUE_LIBERADO
	REPLACE v_Compras_01.ERP_CUPS_INCOTERM WITH tmpCompras02.ERP_CUPS_INCOTERM
	REPLACE v_Compras_01.ERP_CUPS_ID_CONTRATO WITH tmpCompras02.ERP_CUPS_ID_CONTRATO
	REPLACE v_Compras_01.ERP_PERCENT_VERBAS WITH tmpCompras02.ERP_PERCENT_VERBAS
	REPLACE v_Compras_01.ERP_IMPORTADO WITH tmpCompras02.ERP_IMPORTADO
	REPLACE v_Compras_01.ERP_MOEDA WITH tmpCompras02.ERP_MOEDA
	REPLACE v_Compras_01.ERP_TOTAL_QTD_DISTRIB WITH tmpCompras02.ERP_TOTAL_QTD_DISTRIB
	REPLACE v_Compras_01.ERP_PERCENT_DISTRIB WITH tmpCompras02.ERP_PERCENT_DISTRIB
	REPLACE v_Compras_01.ERP_TOTAL_CAIXAS_ORIGINAL WITH tmpCompras02.ERP_TOTAL_CAIXAS_ORIGINAL

	** FINAL: PAULO DEVIDE - 30-JUL-14 **


	*** DUPLICA PROPRIEDADES
	lcPedido = cPedido

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select * 
		from prop_compras 
		where pedido=?lcPedido
	ENDTEXT

	f_select(lcSQL,"tmpProp_compras1")

	IF USED("tmpProp_compras1")
		SELECT tmpProp_compras1
		SCAN 	
			SELECT curpropcompras
			LOCATE FOR propriedade = tmpProp_compras1.propriedade
			IF FOUND()
				replace valor_propriedade WITH tmpProp_compras1.valor_propriedade
			ENDIF
			SELECT tmpProp_compras1	
		ENDSCAN
	ENDIF


	SELECT (lnArea)

	**** DUPLICA PACKS

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * 
		FROM CAEDU_COMPRAS_PRODUTOS_PACKS 
		WHERE PEDIDO = ?lcPedido
	ENDTEXT

	f_select(lcSQL,"tmpCAEDU_COMPRAS_PRODUTOS_PACKS")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * 
		FROM CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL 
		WHERE PEDIDO = ?lcPedido
	ENDTEXT

	f_select(lcSQL,"tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL")

	IF USED("tmpCAEDU_COMPRAS_PRODUTOS_PACKS") AND USED("tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL")

		LOCAL ii as Integer
		SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS
		FOR ii=1 TO 48
			SCAN
				lcCampo="tmpCAEDU_COMPRAS_PRODUTOS_PACKS.Q"+ALLTRIM(TRANSFORM(ii,"99"))
				replace &lcCampo. WITH NVL(&lcCampo.,0)	
			ENDSCAN
		ENDFOR

		SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		FOR ii=1 TO 48
			SCAN
				lcCampo="tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q"+ALLTRIM(TRANSFORM(ii,"99"))
				replace &lcCampo. WITH NVL(&lcCampo.,0)	
			ENDSCAN
		ENDFOR

		**thisformset.lx_form1.lx_pageframe1.ActivePage=21
		
		SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS
		SCAN 	
			
			SCATTER MEMVAR 
			
			SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
			APPEND BLANK
			GATHER memvar

			**WITH ThisFormset.Lx_form1.Lx_pageframe1.Page21.Lx_grid_filha1
			**	.afterrowcolchange()
			**	.Refresh
			**ENDWITH
					
			SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS
			
		ENDSCAN

		SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		SCAN 	
			
			SCATTER MEMVAR 
			
			SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
			APPEND BLANK
			GATHER memvar

			**WITH ThisFormset.Lx_form1.Lx_pageframe1.Page21.Lx_grid_filha2
			**	.afterrowcolchange()
			**	.Refresh
			**ENDWITH
			
			SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL

		ENDSCAN

		
	ENDIF


	SELECT (lnArea)
	RETURN
	
ENDPROC


PROCEDURE LIMPA_LOG_AUTORIZACAO
	LOCAL lnArea
	
	lnArea = SELECT()
	TRY 
		SET SAFETY off
		IF USED("V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM")
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM			
			ZAP
		ENDIF
		
		IF USED("V_CAEDU_LOG_AUTORIZA_COMPRAS")		
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS
			ZAP
		ENDIF
	CATCH TO oErro
		MESSAGEBOX(oErro.Message, 16, "Aviso")

	ENDTRY
	
	SELECT (lnArea)
ENDPROC

FUNCTION GRAVA_LOG_AUTORIZACAO
	llRet = .t.
	TRY 
	
		SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS 
		SCAN 		
	
			F_SELECT("SELECT * FROM dbo.CAEDU_LOG_AUTORIZA_COMPRAS "+;
						"WHERE PEDIDO=?v_compras_01.PEDIDO AND PRODUTO=?V_CAEDU_LOG_AUTORIZA_COMPRAS.PRODUTO","VTMPLOG1")

			llExiste = .t.

			IF RECCOUNT("VTMPLOG1")=0
				llExiste = .f.
			ENDIF

			IF llExiste
				lcSQL = "UPDATE dbo.CAEDU_LOG_AUTORIZA_COMPRAS SET "
				lcSQL = lcSQL + " STATUS_PEDIDO = 3 " && AGUARDANDO APROVA��O
				lcSQL = lcSQL + " WHERE PEDIDO = '"+ALLTRIM(v_compras_01.PEDIDO)+"' AND "
				lcSQL = lcSQL + " PRODUTO = '"+ALLTRIM(V_CAEDU_LOG_AUTORIZA_COMPRAS.PRODUTO)+"'" 
			ELSE
				lcSQL = "INSERT INTO dbo.CAEDU_LOG_AUTORIZA_COMPRAS "
				lcSQL = lcSQL + " (PEDIDO,PRODUTO,DATA_LOG,STATUS_PEDIDO) "
				lcSQL = lcSQL + " VALUES ('"+ALLTRIM(v_compras_01.PEDIDO)+"','"+ALLTRIM(V_CAEDU_LOG_AUTORIZA_COMPRAS.PRODUTO)+"','"
				lcSQL = lcSQL + DTOS(DATE())+"', 3)"
			ENDIF
			
			F_EXECUTE(lcSQL)
									
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS 

		ENDSCAN

		SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
		SCAN
			TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
				INSERT INTO dbo.CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
				(PEDIDO,PRODUTO,COR_PRODUTO,COD_METRICA,DATA_LOG,TIPO_OP,
				VALOR_ANTES,VALOR_DEPOIS,APROVADO,USUARIO_PEDIDO,USUARIO_APROVADOR,OBS)
				VALUES (
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.PEDIDO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.PRODUTO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.COR_PRODUTO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.COD_METRICA,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.DATA_LOG,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.TIPO_OP,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.VALOR_ANTES,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.VALOR_DEPOIS,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.APROVADO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.USUARIO_PEDIDO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.USUARIO_APROVADOR,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.OBS)
			ENDTEXT
			F_INSERT(lcSQL)
			
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
		ENDSCAN

	CATCH TO oErro
		MESSAGEBOX(oErro.message,16, "Aviso")
		llRet = .f.

	ENDTRY
	RETURN llRet
	
ENDFUNC

***
* 
*/
PROCEDURE desabilita_toolbar_filha
	PARAMETERS objTelaPai
	TRY 
		o_toolbar.Botao_filhas_inserir.Enabled= .F.
		o_toolbar.botao_filhas_deletar.Enabled= .f.
		
	CATCH TO oErro
		MESSAGEBOX(oErro.message, 16, "Aviso")

	ENDTRY

ENDPROC


****
* PAULO DEVIDE
* ADICIONA OBJETOS NA TELA DE COMPRAS
* CRIADO EM: 18/08/2016
*/
FUNCTION ADICIONA_CONTROLES
	LPARAMETERS objTelaPai, xmetodo, xobjeto, xnome_obj

	** Adiciona Page da Cabilog
	lnLastPage = objTelaPai.lx_form1.lx_pageframe1.pagecount + 1
	lcLastPage = "pgCabilog"
	objTelaPai.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageCabilog") && classe cPageCabilog - definida neste objeto de entrada
	WITH objTelaPai.lx_form1.lx_pageframe1.pgCabilog
		.enabled=.t.
		lnPageIndex = .pageorder
	ENDWITH

	** Adiciona Page de Avisos/Erros
	lnLastPage = objTelaPai.lx_form1.lx_pageframe1.pagecount + 1
	lcLastPage = "pgWarning"
	objTelaPai.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageWarning") && classe cPageCabilog - definida neste objeto de entrada
	WITH objTelaPai.lx_form1.lx_pageframe1.pgWarning
		.enabled=.t.
		lnPageIndex = .pageorder
	ENDWITH
	
	** Adiciona Page de Importado (Atacado)
	lnLastPage = objTelaPai.lx_form1.lx_pageframe1.pagecount + 1
	lcLastPage = "pgAtacado"
	objTelaPai.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageAtacado") && classe cPageAtacado - definida neste objeto de entrada
	WITH objTelaPai.lx_form1.lx_pageframe1.pgAtacado
		.enabled=.t.
		lnPageIndex = .pageorder
	ENDWITH
	objTelaPai.lx_form1.lx_pageframe1.Activepage = lnPageIndex
	
	*** Adiciona objetos na page 'Atacado'
	WITH objTelaPai.lx_form1.lx_pageframe1.pgAtacado

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

		.addobject('lbl_moeda', 'rotulo')
		.addobject('cbo_moeda1', 'cbo_moeda')
		WITH .cbo_moeda1
			.controlsource = "v_compras_01.ERP_MOEDA"
			.visible = .t.
			.parent.lbl_moeda.caption = "Moeda"
			.parent.lbl_moeda.top = 83
			.parent.lbl_moeda.left = 290
			.parent.lbl_moeda.visible = .t.
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
			.p_valida=.F. && 20-07-15 --> N�o � mais obrigat�rio
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
	
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1

	
		.addobject("lblTotPercentDistrib1","lblTotPercentDistrib")
		.lblTotPercentDistrib1.visible=.t.
		
		.addobject("lblTotQtdDistrib1","lblTotQtdDistrib")
		.lblTotQtdDistrib1.visible=.t.

		.addobject("txtTotQtdDistrib1","txtTotQtdDistrib")
		.txtTotQtdDistrib1.visible=.t.

		.addobject("txtTotPercentDistrib1","txtTotPercentDistrib")
		.txtTotPercentDistrib1.visible=.t.
	
		.addobject("ck_importado1","ck_importado")
		.ck_importado1.visible=.t.
			
		.addobject('CBO_tipo_pedido1','CBO_tipo_pedido')
		.CBO_tipo_pedido1.Left = 425
		.CBO_tipo_pedido1.Top = 376
		.CBO_tipo_pedido1.controlsource = "v_compras_01.ERP_CUPS_TIPO_PEDIDO"
		.CBO_tipo_pedido1.Visible = .T.

		.addobject('label_tipo_pedido','rotulo')
		.label_tipo_pedido.Left = 393
		.label_tipo_pedido.Top = 379
		
		.label_tipo_pedido.Caption = "Tipo"
		.label_tipo_pedido.autosize = .T.
		.label_tipo_pedido.Visible = .T.

		.addobject('label_segmento_pedido','rotulo')
		.label_segmento_pedido.Left = 608
		.label_segmento_pedido.Top = 379
		
		.label_segmento_pedido.Caption = "Segmento"
		
		.label_segmento_pedido.autosize = .T.
		.label_segmento_pedido.Visible = .T.		
		
		.addobject('CBO_segmento_pedido1','CBO_segmento_pedido')
		.CBO_segmento_pedido1.Left = 673
		.CBO_segmento_pedido1.Top = 376
		.CBO_segmento_pedido1.controlsource = "v_compras_01.ERP_CUPS_SEGMENTO"
		.CBO_segmento_pedido1.Visible = .T.
										
	ENDWITH

	FOR EACH loPg IN objTelaPai.lx_form1.lx_pageframe1.pages
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

				***
				* Bot�o Adicionar Produtos
				*/
				.addobject("cmdAddProduto1","cmdAddProduto",objTelaPai)
				.cmdAddProduto1.visible = .t.

				***
				* Bot�o Excluir Produtos
				*/
				.addobject("cmdDelProduto1","cmdDelProduto",objTelaPai)
				.cmdDelProduto1.visible = .t.

								
				***
				* Adiciona um shape invisivel para n�o deixar o usu�rio editar o
				* pack dos itens do pedido 
				*/
				.AddObject("shape11","shape")
				WITH .shape11
					.Top = 32
					.left = 7
					.visible = .t.
					.height = 117   && altura
					.Width = 820    && largura
					.BackStyle= 0   && transparente
					.BorderStyle= 0 && borda invisivel
				ENDWITH
				
			ENDWITH
		
		ENDIF
	
	ENDFOR
	
	***
	* Bot�o de Pedido em Ingl�s --> 21-05-2013
	*/
	objTelaPai.lx_form1.addobject('bt_pedido1', 'bt_pedido')
	WITH objTelaPai.lx_form1.bt_pedido1
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
	
	*** Inclui Campo Data OTB
	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('sh_OTB1', 'sh_OTB')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.sh_OTB1
		.visible = .F.
	ENDWITH

	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('lb_data_otb1', 'lb_data_otb')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.lb_data_otb1
		.visible = .t.
		.top = 182
		.Left = 8
	ENDWITH

	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('tx_data_otb1', 'tx_data_otb')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.tx_data_otb1
		.visible = .t.
		.top = 182
		.left = 84
		.ControlSource = 'V_COMPRAS_01.CAEDU_DATA_OTB'
	ENDWITH

	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('btn_Recalcula1', 'btn_Recalcula')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.btn_Recalcula1
		.visible = .t.
	ENDWITH
	
	*************************************************************

	objTelaPai.lx_form1.lx_pageframe1.Page5.addobject('bt_obs_pack1', 'bt_obs_pack')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page5.bt_obs_pack1
		.visible = .t.
	ENDWITH
	
	** PAULO DEVIDE - 09-SET-14 (INICIO) --> Pageframe Cabilog
	TRY

		lcPage = ALLTRIM(TRANSFORM(objTelaPai.lx_form1.lx_pageframe1.pagecount,"99"))

		FOR EACH loPg IN objTelaPai.lx_form1.lx_pageframe1.pages
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
				
				loPg.addobject("label1","label")
				loPg.label1.top = 400
				loPg.label1.left = 40
				loPg.label1.visible=.t.

				loPg.addobject("cmdAtualizaCabilog1","cmdAtualizaCabilog")
				loPg.cmdAtualizaCabilog1.visible=.t.
				
				
				loPg.refresh
				
			ENDIF
			
			IF "avisos" $ LOWER(loPg.caption)

				loPg.addobject("lista_erro1","lista_erro")
				loPg.lista_erro1.visible=.t.
				
				loPg.addobject("label_erro1","label_erro")
				loPg.label_erro1.visible=.t.

				loPg.addobject("lista_metrica1","lista_metrica")
				loPg.lista_metrica1.visible=.t.
				
				loPg.addobject("label_metrica1","label_metrica")
				loPg.label_metrica1.visible=.t.			
				
			ENDIF
			
			
		ENDFOR
		
		objTelaPai.lx_form1.lx_pageframe1.activepage = 1 &&CAST(lcPage as Int)

	CATCH TO loErro
		MESSAGEBOX(loErro.Message,16,"Aviso")

	ENDTRY
	** PAULO DEVIDE - 09-SET-14 (FIM)
	
	*** para pegar o numero da p�gina para acessar
	** objTelaPai.lx_form1.lx_pageframe1.activepage = getPageIndex(objTelaPai, "Avisos")
	***
	
	RETURN .T.
ENDFUNC

PROCEDURE PROC_004006_INCLUDE_AFTER
	PARAMETERS objTelaPai, xmetodo, xobjeto, xnome_obj
	****
	* MONTA UMA CURSOR TEMPORARIO COM OS CAMPOS DE CONTROLE DE VERBAS DE OTB
	* PARA SER SUBTRAIDO AO ATUALIZAR A TABELA Caedu_verba_compras no SQL
	* PAULO DEVIDE - 28-01-2016
	*/
	lnArea = SELECT()

	SELECT ;
		PRODUTO,;
		MAX(LIMITE_ENTREGA) AS LIMITE_ENTREGA, ;
		SUM(VALOR_ORIGINAL) AS VALOR_ORIGINAL, ;
		SUM(NVL(ERP_VERBAS_EMPENHO,0)) AS ERP_VERBAS_EMPENHO, ;
		MAX(NVL(ERP_VERBAS_DATA_EMPENHO,{})) AS ERP_VERBAS_DATA_EMPENHO, ;
		MAX(CAST(NVL(ERP_VERBAS_EMPENHO_ANO_MES,0) AS NUMERIC(6,0))) AS ERP_VERBAS_EMPENHO_ANO_MES, ;
		.f. AS ERP_VERBAS_STATUS_PR ;
	FROM ;
		V_COMPRAS_01_PRODUTOS WITH (BUFFERING = .T.) ;
	GROUP BY ;
		PRODUTO INTO CURSOR CURVERBAS_BEFORE_ALTER READWRITE

	SELECT (lnArea)


	objTelaPai.lx_form1.lx_pageframe1.Page1.tx_data_otb1.value = DATE() && Valor default para data OTB

	IF objTelaPai.p_Tool_Status="I" && Somente na inclus�o

		Select v_Compras_01
		Replace FILIAL_A_ENTREGAR With RTRIM(o_004006.pp_filial_padrao),;
			FILIAL_COBRANCA   With 'MATRIZ',;
			FILIAL_A_FATURAR  With RTRIM(o_004006.pp_filial_padrao)

		objTelaPai.lx_form1.lx_pageframe1.Page1.cmb_FILIAL_A_ENTREGAR.VALUE =  RTRIM(o_004006.pp_filial_padrao)
		objTelaPai.lx_form1.lx_pageframe1.Page1.cmb_FILIAL_A_FATURAR.VALUE =  RTRIM(o_004006.pp_filial_padrao)
		
		REPLACE v_Compras_01.ERP_CUPS_SEGMENTO WITH "VAREJO"

	endif
	** PAULO DEVIDE - muda o valor do campo DATA OTB na inclus�o no caso de haver
	** altera��o no campo entrega - 15-08-2013
ENDPROC

FUNCTION PROC_004006_ALTER_BEFORE 
	PARAMETERS objTelaPai, xmetodo, xobjeto, xnome_obj
	** PAULO DEVIDE - 17-11-2014 - PROPRIEDADE PARA GUARDAR O VALOR DA CONDI��O DE PAGAMENTO
	TRY 
		ADDPROPERTY(objTelaPai,"CONDICAO_PGTO_ANTES",v_compras_01.condicao_pgto)				
	CATCH TO err1
		WAIT WINDOW NOWAIT err1.message
	FINALLY
		objTelaPai.CONDICAO_PGTO_ANTES = v_compras_01.condicao_pgto
		WAIT clear
	ENDTRY

	Select v_compras_01_ent_prod
	=Requery()

	DO Case

		Case Reccount('v_compras_01_ent_prod') >= 1

			nAnswer = Messagebox('Esse pedido de compra j� foi recebido total ou parcialmente' +Chr(13)+;
									'Altera��es permitidas apenas com Senha Gerencial.' +Chr(13)+;
									'Deseja entrar com senha de altera��o ?', 292, "Aviso")

			Do Case
				Case nAnswer = 6

					glSenha = ""
					oSenha = CREATEOBJECT("tsenhapedido")
					oSenha.show(1)

					f_select("Select valor_atual from parametros where parametro = 'CAE_SENHA_COMPRAS' ","LISTAUT"	)

					Select LISTAUT
					CAEWHERE = LISTAUT.VALOR_ATUAL
					xaut = 0

					If Inlist(glSenha  , &CAEWHERE  )
						xaut = xaut  +1
					Endif

					If xaut > 0
						Return .T.
					Else
						Messagebox("Senha incorreta ou n�o autorizada",16, "Aviso")
						Return .F.
					Endif

				Case nAnswer = 7
					Return .F.

			Endcase
	ENDCASE

	****
	* MONTA UMA CURSOR TEMPORARIO COM OS CAMPOS DE CONTROLE DE VERBAS DE OTB
	* PARA SER SUBTRAIDO AO ATUALIZAR A TABELA Caedu_verba_compras no SQL
	* PAULO DEVIDE - 28-01-2016
	*/
	
	lnArea = SELECT()

	SELECT ;
		PRODUTO,;
		MAX(LIMITE_ENTREGA) AS LIMITE_ENTREGA, ;
		SUM(VALOR_ORIGINAL) AS VALOR_ORIGINAL, ;
		SUM(NVL(ERP_VERBAS_EMPENHO,0)) AS ERP_VERBAS_EMPENHO, ;
		MAX(NVL(ERP_VERBAS_DATA_EMPENHO,{})) AS ERP_VERBAS_DATA_EMPENHO, ;
		MAX(CAST(NVL(ERP_VERBAS_EMPENHO_ANO_MES,0) AS NUMERIC(6,0))) AS ERP_VERBAS_EMPENHO_ANO_MES, ;
		.f. AS ERP_VERBAS_STATUS_PR ;
	FROM ;
		V_COMPRAS_01_PRODUTOS WITH (BUFFERING = .T.) ;
	GROUP BY ;
		PRODUTO INTO CURSOR CURVERBAS_BEFORE_ALTER READWRITE

	SELECT (lnArea)
	RETURN .T.
ENDFUNC


FUNCTION PROC_004006_ITENS_CANCELADOS
	llCancela = (RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0)
	RETURN llCancela
ENDFUNC

***
* ALIMENTA UM OBJETO LISTBOX COM AS MENSAGENS DE ERRO DA TELA
*/		
PROCEDURE ADICIONA_ERRO
	PARAMETERS loListaErro, lcMensagemErro, blnLimparLista
	IF blnLimparLista
		loListaErro.Clear
	ENDIF
	IF EMPTY(lcMensagemErro)
		RETURN
	ELSE
		loListaErro.AddItem(lcMensagemErro)
	ENDIF
	RETURN
ENDPROC


******************************************************************************************
** PAULO DEVIDE --> 22-NOV-2016 VALIDA CABILOG(INICIO)
******************************************************************************************
FUNCTION VALIDA_CABILOG
	PARAMETERS objLista, objTelaPai
	llRet = .t.
	IF Inlist(objTelaPai.p_Tool_Status, "A","I")
	
		** verifica se todos os campos foram preenchidos
		lcMsgErr = ""
		IF v_Compras_01.ERP_CAB_ENCABIDADO && se estiver clicado, valida os campos obrigat�rios
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_COD_CABIDE,""))
				ADICIONA_ERRO(objLista, "Obrigat�rio preencher o C�digo do Cabide (Aba - Cabilog)", .F.)
				llRet = .f.
			ENDIF
		
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_CD_ENTREGA,""))
				ADICIONA_ERRO(objLista, "Obrigat�rio preencher o C�digo do CD Entrega  (Aba - Cabilog)", .F.)
				llRet = .f.
			ENDIF
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_LOCALIZACAO,""))
				ADICIONA_ERRO(objLista, "Obrigat�rio preencher a Localiza��o Cabide  (Aba - Cabilog)", .F.)
				llRet = .f.
			ENDIF
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_TIPO_PEDIDO,""))
				ADICIONA_ERRO(objLista, "Obrigat�rio preencher o Tipo de Pedido  (Aba - Cabilog)", .F.)
				llRet = .f.
			ENDIF
			
		ENDIF
		
		IF NOT llRet
			RETURN .f.
		ENDIF

		lcCab_Status = "M"
		llData_Envio = .f.
		
		DO CASE
			CASE objTelaPai.p_Tool_Status="A"		&& ATUALIZA PROPRIEDADE CAB_STATUS PARA 'M'

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
					CEILING(v_Compras_01.TOT_QTDE_ORIGINAL * (objTelaPai.pp_porcentagem_qtd_cabides/100)) 
				
				IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
					replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
				ENDIF
				
				
			CASE objTelaPai.p_Tool_Status="I"		&& ATUALIZA PROPRIEADE CAB_STATUS PARA 'A'

				IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
					IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
						lcCab_Status = "C" && pedido cancelado
						llData_Envio = .t.
					ELSE
						lcCab_Status = "A" && pedido cancelado
					ENDIF

				ELSE
					lcCab_Status = "A" && pedido Ok!

				ENDIF

				REPLACE v_Compras_01.ERP_CAB_STATUS WITH lcCab_Status
				replace v_Compras_01.ERP_CAB_QTDPECAS with ;
					CEILING(v_Compras_01.TOT_QTDE_ORIGINAL * (objTelaPai.pp_porcentagem_qtd_cabides/100)) 

				IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
					replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
				ENDIF


			OTHERWISE

		ENDCASE
		
	ENDIF
ENDFUNC
******************************************************************************************
** PAULO DEVIDE --> 22-NOV-2016 VALIDA CABILOG(FIM)
******************************************************************************************

*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*** VALIDA��O DE CAMPOS OBRIGAT�RIOS DO PEDIDO
* SE objLista.ListCount = 0 retorna .T., caso contr�rio retorna .F.
*/	
FUNCTION VALIDA_CAMPOS_PEDIDO
	PARAMETERS objLista
	LOCAL lnArea as Integer
	LOCAL lnTotReg1 as Integer, lnTotReg2 as Integer

	lnArea = SELECT()

	SELECT v_caedu_compras_produtos_packs
	lnTotReg1 = RECCOUNT("v_caedu_compras_produtos_packs")

	SELECT v_caedu_compras_produtos_packs_total
	lnTotReg2 = RECCOUNT("v_caedu_compras_produtos_packs_total")

	*
	ADICIONA_ERRO(objLista, "", .T.) && limpa o listbox de erros
	*
	SELECT v_compras_01
	** 1) Tipo de compra
	IF EMPTY(NVL(v_compras_01.tipo_compra,''))
		ADICIONA_ERRO(objLista, "Campo [Tipo de Compra] � obrigat�rio...", .F.)
	ENDIF
	** 2) Requerido por:
	IF EMPTY(NVL(v_compras_01.requerido_por,''))
		ADICIONA_ERRO(objLista, "Campo [Requerido por] � obrigat�rio...", .F.)
	ENDIF
	** 3) Aprovado/Reprovado:
	IF EMPTY(NVL(v_compras_01.aprovador_por,''))
		ADICIONA_ERRO(objLista, "Campo [Aprovado/Reprovado] � obrigat�rio...", .F.)
	ENDIF
	** 4) Natureza Entrada:
	IF EMPTY(NVL(v_compras_01.natureza_entrada,''))
		ADICIONA_ERRO(objLista, "Campo [Natureza entrada] � obrigat�rio...", .F.)
	ENDIF
	** 5) Data de Entrega:
	IF EMPTY(NVL(pdEntrega,CTOD('')))
		ADICIONA_ERRO(objLista, "Campo [Data de Entrega] � obrigat�rio...", .F.)
	ENDIF
	** 6) Data de Limite de Entrega:
	IF EMPTY(NVL(pdLimite,CTOD('')))
		ADICIONA_ERRO(objLista, "Campo [Limite de Entrega] � obrigat�rio...", .F.)
	ENDIF
	** 7) Validar se existe itens cadastrados e com quantidade/valor:
	IF EMPTY(NVL(v_compras_01.tot_valor_original,0))
		ADICIONA_ERRO(objLista, "� obrigat�rio informar os itens do pedido...", .F.)
	ENDIF
	** 8) Validar se os cursor adapter PACK contem registro
	IF lnTotReg1=0
		ADICIONA_ERRO(objLista, "Inconsist�ncia na informa��o de PACKs...", .F.)
	ENDIF
	** 9) Validar se os cursor adapter PACK contem registro
	IF lnTotReg2=0
		ADICIONA_ERRO(objLista, "Inconsist�ncia na informa��o de Totalizador de PACKs...", .F.)
	ENDIF
	** 10) Validar filial_a_entregar
	IF EMPTY(NVL(v_compras_01.FILIAL_A_ENTREGAR,''))
		ADICIONA_ERRO(objLista, "� obrigat�rio informar [FILIAL_A_ENTREGAR]...", .F.)
	ENDIF
	** 11) Validar filial_cobranca
	IF EMPTY(NVL(v_compras_01.FILIAL_COBRANCA,''))
		ADICIONA_ERRO(objLista, "� obrigat�rio informar [FILIAL_COBRANCA]...", .F.)
	ENDIF
	** 12) Validar filial_a_faturar
	IF EMPTY(NVL(v_compras_01.FILIAL_A_FATURAR,''))
		ADICIONA_ERRO(objLista, "� obrigat�rio informar [FILIAL_A_FATURAR]...", .F.)
	ENDIF
	** 13) Validar RATEIO_CENTRO_CUSTO
	IF EMPTY(NVL(v_compras_01.RATEIO_CENTRO_CUSTO,""))
		ADICIONA_ERRO(objLista, "Obrigat�rio preencher RATEIO CENTRO DE CUSTO", .F.)
	ENDIF
	** 14) Validar RATEIO_FILIAL
	IF EMPTY(NVL(v_compras_01.RATEIO_FILIAL,""))
		ADICIONA_ERRO(objLista, "Obrigat�rio preencher RATEIO FILIAL", .F.)
	ENDIF

	***
	* importado/estrangeiro 
	*/
	IF ZORIGEM_PEDIDO_IMPORTADO()=.t. AND !ZAUTORIZA_ATACADO()
		IF EMPTY(NVL(v_compras_01.ERP_CUPS_TIPO_PEDIDO,""))
			ADICIONA_ERRO(objLista, "Obrigat�rio preencher TIPO DE PEDIDO (CCF/CCA)", .F.)
		ENDIF
		
		IF EMPTY(NVL(v_compras_01.ERP_CUPS_DATA_ACORDADA,{}))
			ADICIONA_ERRO(objLista, "Obrigat�rio preencher DATA ACORDADA", .F.)
		ENDIF
		
		IF EMPTY(NVL(v_compras_01.ERP_CUPS_INCOTERM,""))
			ADICIONA_ERRO(objLista, "Obrigat�rio preencher INCOTERM na aba IMPORTADO", .F.)
		ENDIF
		
		IF EMPTY(NVL(v_compras_01.ERP_CUPS_ID_CONTRATO,""))
			ADICIONA_ERRO(objLista, "Obrigat�rio preencher CONTRATO na aba IMPORTADO", .F.)
		ENDIF

		SELECT v_compras_01_produtos
		GO top

		SCAN 					

			IF EMPTY(NVL(v_compras_01_produtos.ERP_CUPS_CUSTO_FOB,0))
				ADICIONA_ERRO(objLista, "Campo CUSTO FOB em branco.", .F.)
			ENDIF
			
			SELECT v_compras_01_produtos
			
		ENDSCAN
	ENDIF
	
	SELECT (lnArea)
	RETURN (objLista.ListCount = 0)
ENDFUNC
*** VALIDA��O DE M�TRICAS DEFINIDAS DO PEDIDO
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************

*** VALIDA��O DE M�TRICAS DEFINIDAS DO PEDIDO
* SE objLista.ListCount = 0 retorna .T., caso contr�rio retorna .F.
*/	
FUNCTION VALIDA_METRICAS_PEDIDO
	PARAMETERS objLista
	LOCAL lnArea as Integer
	LOCAL lnTotReg1 as Integer, lnTotReg2 as Integer

	LOCAL objMetrica as object 
	objMetrica = CREATEOBJECT("funcoes_metricas", objLista)
	
	lnArea = SELECT()

	*
	ADICIONA_ERRO(objLista, "", .T.) && limpa o listbox de metricas
	*
	**>> ADICIONA_ERRO(objLista, "Campo [Tipo de Compra] � obrigat�rio...", .F.)
	
	***
	* Vefifica se � necess�rio adicionar 
	* o registro da tabela pai, e adiciona se precisar
	*/

	** Cria um registro de cabe�alho (tabela pai) 
	** para cada PEDIDO + PRODUTO distinto
	objMetrica.ADICIONA_CABECALHO_LOG() 
	***********************************
	
	************************************************
	** PEGA REGISTRO ANTERIOR DOS ITENS DO PEDIDO **
	************************************************
	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM COMPRAS_PRODUTO
		WHERE PEDIDO = '<<v_compras_01.PEDIDO>>'
	ENDTEXT
	F_SELECT(lcSQL, "V_COMPRAS_PRODUTO_ANTES")
	************************************************
	
	***
	* Percorre a tabela de M�tricas e verifica cada uma
	*/
	SELECT vLOG_METRICAS
	GO TOP
	SCAN

		objMetrica.retorno = .f.
		objMetrica.metrica_erro = ""
		objMetrica.Executa(vLOG_METRICAS.COD_METRICA)


		SELECT vLOG_METRICAS
	ENDSCAN
	
	SELECT (lnArea)
	RETURN (objLista.ListCount = 0)
ENDFUNC


*** VALIDA��O DE M�TRICAS DEFINIDAS DO PEDIDO
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************

FUNCTION ZAUTORIZA_ATACADO
	lnArea = SELECT()
	SELECT * FROM curpropcompras WITH (BUFFERING=.T.) ;
		WHERE ALLTRIM(PROPRIEDADE) = "00077" ;
		INTO CURSOR tmp_autoriza
	llRet = UPPER(ALLTRIM(NVL(tmp_autoriza.valor_propriedade,"")))=="SIM"		
	SELECT (lnArea)

	IF llRet
		MESSAGEBOX("Autoriza��o para Transfer�ncia Atacado foi liberada!",48,"Aviso")
	ENDIF
	
	RETURN llRet
ENDFUNC

***
* data_excel - retorna data no formato numerico do Excel
* parametros varialvel_data no formato Date do foxpro
* PAULO DEVIDE - 27-07-2015
*/
FUNCTION data_excel
	PARAMETERS tcData1
	RETURN CAST(SYS(11,tcData1) as int) - CAST(SYS(11,{30/12/1899}) as int)
ENDFUNC

FUNCTION ZORIGEM_PEDIDO_IMPORTADO
	** VERIFICA OS PRODUTOS NO CAMPO TRIBUT_ORIGEM, SE ENCONTRAR PELO MENOS UM PRODUTO COM VALOR = '1' ENT�O ORIGEM � ESTRANGEIRA
	** RETORNA .T. SE FOR ESTRANGEIRO E .F. SE N�O FOR
	** alterado em 30/11/15 - inclui os codigos 2, 6 e 7 que s�o estrangeiros tamb�m
	** ser� utilizado esta fun��o para verificar nacional, no caso tem que retorna .f.
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
		IF INLIST(ALLTRIM(NVL(tmpTributOrigem.TRIBUT_ORIGEM,"")),"1","2","6","7")
			llRet = .T.
			EXIT
		ENDIF
	ENDSCAN

	SELECT (lnArea)
	RETURN llRet
ENDFUNC

** PAULO DEVIDE -> 22-05-2013 --> alterado em 15-set-14 impressao de varios pedidos
FUNCTION zPedido_Excel
	PARAMETERS tcArquivo, oExcel, lnSheet

	IF PARAMETERS()<3
		lnSheet = 0 && imprime s� um pedido 
	ENDIF
	
	** Querys de dados do relat�rio
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


	WITH oExcel && objeto publico passado de parametro para esta fun��o
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

		** CUPS --> Propriedade 00068 � AGORA produtos.ERP_CUPS_STYLENUMBER
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
			** Data convertida para formato num�rico do Excel
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
    
		*** Formata��o dos Itens do Pedido
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
		lnSheet = 0 && imprime s� um produto do pedido 
	ENDIF
	
	** Querys de dados do relat�rio
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


	WITH oExcel && objeto publico passado de parametro para esta fun��o
		IF lnSheet = 0
			.Sheets(1).Name = ALLTRIM(tmpProdutos1.PRODUTO) &&ALLTRIM(v_compras_01.pedido)
		ELSE
			***
			* {Paulo Devid� - 20-07-15}
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

		** CUPS --> Propriedade 00068 � AGORA produtos.ERP_CUPS_STYLENUMBER
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
			** Data convertida para formato num�rico do Excel
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

		*** Formata��o dos Itens do Pedido
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



***
* Fun��o para obter o PageIndex para manipular o objeto ActivePage
*/
FUNCTION getPageIndex
PARAMETERS objTelaPai, tcCaption
	LOCAL liPageIndex as Integer
	liPageIndex = 1
	TRY 
		FOR EACH loPage IN objTelaPai.lx_form1.lx_pageframe1.pages
			IF LOWER(tcCaption) $ LOWER(loPage.caption)
				liPageIndex = loPage.pageorder
			ENDIF
		ENDFOR
		
	CATCH TO oErro1
		MESSAGEBOX(oErro1.message,16,"Aviso")
	ENDTRY
	RETURN liPageIndex
ENDFUNC


******************************************************************************************************************************************************
******************** DEFINE DE OBJETOS DA CLASSE *****************************************************************************************************
******************************************************************************************************************************************************

***
* Bot�o para chamar a tela para excluir produto/pack
*/
DEFINE CLASS cmdAtualizaCabilog AS CommandButton

	Height = 34
	Left = 18
	Top = 170
	Width = 185
	Name = "cmdAtualizaCabilog"
	caption = "Atualizar Dados"
	wordwrap = .t.
	
	objTelaPai = .f.
	
	PROCEDURE init
		
		PARAMETERS oThisformSet
		this.objTelaPai = oThisformSet
					
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE click
		WAIT WINDOW NOWAIT "Atualizando..."
		
		lcMsg = ""
		lcEnter = CHR(13)
		llRet = .T.
		
		IF v_Compras_01.ERP_CAB_ENCABIDADO && se estiver clicado, valida os campos obrigat�rios
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_COD_CABIDE,""))
				lcMsg = lcEnter + lcMsg + "Obrigat�rio preencher o C�digo do Cabide (Aba - Cabilog)" + lcEnter
				llRet = .f.
			ENDIF
		
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_CD_ENTREGA,""))
				lcMsg = lcEnter + lcMsg + "Obrigat�rio preencher o C�digo do CD Entrega  (Aba - Cabilog)" + lcEnter
				llRet = .f.
			ENDIF
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_LOCALIZACAO,""))
				lcMsg = lcEnter + lcMsg + "Obrigat�rio preencher a Localiza��o Cabide  (Aba - Cabilog)" + lcEnter
				llRet = .f.
			ENDIF
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_TIPO_PEDIDO,""))
				lcMsg = lcEnter + lcMsg + "Obrigat�rio preencher o Tipo de Pedido  (Aba - Cabilog)" + lcEnter
				llRet = .f.
			ENDIF
		ELSE
			MESSAGEBOX("Check CABILOG n�o selecionado!"+CHR(13)+"Dados n�o atualizados!",64,"Aviso")	
			RETURN 	
		ENDIF
		
		IF NOT llRet
			MESSAGEBOX(lcMsg,16,"Aviso")
			RETURN 
		ENDIF

		lcCab_Status = "M"
		llData_Envio = .f.

		SELECT v_Compras_01
		thisformset.lx_form1.lx_pageframe1.Page1.ACTIVATE()
				
		DO CASE
			CASE ThisformSet.p_Tool_Status="A"		&& ATUALIZA PROPRIEDADE CAB_STATUS PARA 'M'

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
					CEILING(v_Compras_01.TOT_QTDE_ORIGINAL * (ThisformSet.pp_porcentagem_qtd_cabides/100)) 
				
				IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
					replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
				ENDIF
				
				
			CASE ThisformSet.p_Tool_Status="I"		&& ATUALIZA PROPRIEADE CAB_STATUS PARA 'A'

				IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
					IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
						lcCab_Status = "C" && pedido cancelado
						llData_Envio = .t.
					ELSE
						lcCab_Status = "A" && pedido cancelado
					ENDIF

				ELSE
					lcCab_Status = "A" && pedido Ok!

				ENDIF

				
				lnQtdOrig = v_Compras_01.TOT_QTDE_ORIGINAL 
				lnQtdEncabidados = CEILING( lnQtdOrig * (ThisformSet.pp_porcentagem_qtd_cabides/100)) 

				REPLACE v_Compras_01.ERP_CAB_STATUS WITH lcCab_Status
				replace v_Compras_01.ERP_CAB_QTDPECAS with lnQtdEncabidados

				IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
					replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
				ENDIF


			OTHERWISE

		ENDCASE
		This.Parent.Refresh		
		WAIT WINDOW "OK!" TIMEOUT 1
		
	ENDPROC
	
	PROCEDURE refresh
		** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
	
ENDDEFINE

DEFINE CLASS lblTotPercentDistrib AS Label
	Autosize = .t.
	Left = 5
	Top = 376
	Caption = "% Distrib."
	Name = "lblTotPercentDistrib1"
	BackStyle= 0
ENDDEFINE

DEFINE CLASS lblTotQtdDistrib AS Label
	Autosize = .t.
	Left = 5
	Top = 400
	Caption = "Qtd. Distrib."
	Name = "lblTotQtdDistrib1"
	BackStyle= 0
ENDDEFINE

** CAMPO PARA INFORMAR TOTAL QTDE A DISTRIBUIR DO PEDIDO
DEFINE CLASS txtTotQtdDistrib AS lx_textbox_base
	Height = 21
	Left = 80
	Top = 400
	Width = 84
	ReadOnly = .T.
	Name = "txtTotQtdDistrib1"
	ControlSource = "v_compras_01.ERP_TOTAL_QTD_DISTRIB"
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		RETURN .F. 
	ENDPROC
ENDDEFINE

** CAMPO PARA INFORMAR PERCENTUAL A DISTRIBUIR DO PEDIDO
DEFINE CLASS txtTotPercentDistrib AS lx_textbox_base
	Height = 21
	Left = 80
	Top = 376
	Width = 84
	Name = "txtTotPercentDistrib1"
	InputMask = "999.999999"
	ControlSource = "v_compras_01.ERP_PERCENT_DISTRIB"
	p_tipo_dado = "EDITA"

	PROCEDURE valid
		IF INLIST(ThisFormSet.p_Tool_Status,"I","A")
			replace v_compras_01.ERP_TOTAL_QTD_DISTRIB WITH INT((this.Value/100) * v_compras_01.ERP_TOTAL_CAIXAS_ORIGINAL)
			this.Parent.txtTotQtdDistrib1.refresh
		ENDIF
			
		RETURN .T. 
	ENDPROC

ENDDEFINE

** Checkbox Importado
DEFINE CLASS ck_importado AS lx_checkbox
	Height = 21
	Left = 610
	Top = 406
	Width = 125
	Alignment = 0
	FontBold = .T.
	Caption = "  Importado"
	Name = "ck_importado1"
	ControlSource = "v_compras_01.ERP_IMPORTADO"
	p_tipo_dado = "EDITA"
ENDDEFINE

** Combobox de Moeda
DEFINE CLASS cbo_moeda AS lx_combobox
	Height = 21
	Left = 340
	Top = 80
	Width = 84
	Name = "cbo_moeda1"

	RowSourceType = 1
	RowSource = ZZ_LISTA_MOEDAS

	ControlSource = "v_compras_01.ERP_MOEDA"
	p_tipo_dado = "EDITA"
ENDDEFINE

** Page de objetos de Importa��o
DEFINE CLASS cPageAtacado as Page

	caption = "Importado"
	PROCEDURE Activate
		thisform.refresh
	ENDPROC
	
ENDDEFINE

** Page de objetos de Importa��o
DEFINE CLASS cPageCabilog as Page

	caption = "Cabilog"
	PROCEDURE Activate
	
		IF Inlist(Thisformset.p_Tool_Status, "A","I")

			IF EMPTY(NVL(v_Compras_01.ERP_CAB_CD_ENTREGA,""))	
				replace v_Compras_01.ERP_CAB_CD_ENTREGA WITH "64"
			ENDIF
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_LOCALIZACAO,""))
				replace v_Compras_01.ERP_CAB_LOCALIZACAO WITH "PAREDE"
			ENDIF
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_TIPO_PEDIDO,""))
				replace v_Compras_01.ERP_CAB_TIPO_PEDIDO WITH "NORMAL"
			ENDIF	
			
			IF NVL(v_Compras_01.ERP_CAB_ENCABIDADO,.F.)=.F.
				replace v_Compras_01.ERP_CAB_ENCABIDADO WITH .F.
			ENDIF
			
		ENDIF

		THIS.LABEL1.Caption = NVL(v_Compras_01.ERP_CAB_STATUS,"nulo")

		this.refresh()	
	
	ENDPROC
	
ENDDEFINE

** Page de objetos de Erros/Avisos
DEFINE CLASS cPageWarning as Page

	caption = "Avisos"
	PROCEDURE Activate
		thisform.refresh
	ENDPROC
	
ENDDEFINE

** Shape da Data do OTB
DEFINE CLASS sh_OTB AS lx_shape
	Top = 332
	Left = 4
	Height = 40
	Width = 342
	Name = "sh_OTB1"
ENDDEFINE

** Label da Data do OTB
DEFINE CLASS lb_data_otb AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Data OTB:"
	Left = 54
	Top = 179
	Name = "lb_data_otb1"
ENDDEFINE

** Textbox da Data do OTB
DEFINE CLASS tx_data_otb AS lx_textbox_base
	Height = 21
	Left = 116
	Top = 179
	Width = 100
	Name = "tx_data_otb1"
	
	PROCEDURE when
		If !Inlist(Thisformset.p_Tool_Status, "A","I")
			WAIT WINDOW "altera��o n�o permitida em modo consulta" TIMEOUT 2
			RETURN .f.
		ENDIF
		
	ENDPROC
	
ENDDEFINE

DEFINE CLASS btn_Recalcula as CommandButton

	Width = 105
	Top = 158
	Height = 21
	FontBold = .T.
	Left = 237
	Caption = "Recalcula Saldo"

	PROCEDURE click
		IF MESSAGEBOX("Deseja recalcular os saldos de quantidades para o PEDIDO n�."+ALLTRIM(V_COMPRAS_01.PEDIDO)+"?",292,"Aviso")=6

			cmdsql = "exec lx_movimenta_compras_pa @PEDIDO = '"+ ALLTRIM(V_COMPRAS_01.PEDIDO) + "'"
			
			F_WAIT("Aguarde ... recalculando saldos do PEDIDO  n�."+ALLTRIM(V_COMPRAS_01.PEDIDO))

			f_execute(cmdsql)
			
			F_WAIT()
			
			MESSAGEBOX("Processamento conclu�do!",64,"Aviso")
			
		ENDIF
	ENDPROC

	PROCEDURE refresh
		** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC
	
ENDDEFINE


DEFINE CLASS tv_produto as lx_textbox_valida 

	ControlSource = "V_COMPRAS_01.ERP_CAB_COD_CABIDE"
	Format = "!"
	Height = 25
	Left = 270
	Top = 150
	Width = 200
	p_valida_coluna = "PRODUTO"
	p_valida_coluna_tabela = "PRODUTOS"
	p_valida_colunas_incluir = "PRODUTOS.DESC_PRODUTO"
	p_valida_nao_existencia = .F.
	p_bloqueia_na_alteracao = .F.
	Name = "tv_produto"
	
ENDDEFINE
	

****
* DEFINI��O CLASSE tv_contrato 
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
				MESSAGEBOX("Contrato n�o pode ser alterado, pois pedido j� foi recebido!",16,"Aviso")
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

			MESSAGEBOX("Este contrato j� foi utilizado em outros Pedidos com SEGMENTO diferente deste.",16,"Aviso")

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
		
			IF v_compras_01.TOT_QTDE_ORIGINAL=v_compras_01.TOT_QTDE_ENTREGAR && pedido ainda n�o recebido

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
			WAIT WINDOW "Atualiza��o s� permitida em modo ALTERA��O" TIMEOUT 2
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

*** INICIO CABILOG --> 09/09/14

DEFINE CLASS lb_cod_cabide AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "C�digo Cabide:"
	Left = 18
	Top = 48
	Name = "lb_cod_cabide1"
ENDDEFINE

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
	Caption = "C�d. CD Entrega:"
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
		WAIT WINDOW NOWAIT "Campo n�o edit�vel"
		RETURN .f. && campo � somente leitura, conteudo � formula
	ENDPROC


ENDDEFINE

DEFINE CLASS lb_cab_localizacao AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Localiza��o:"
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
	Caption = "Qtd. Pe�as:"
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
		WAIT WINDOW NOWAIT "Campo n�o edit�vel"
		RETURN .f. && campo � somente leitura, conteudo � formula
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
	RowSource = "NORMAL,IMPORTA��O,BONIFICA��O,AMOSTRA"
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
		WAIT WINDOW NOWAIT "Campo n�o edit�vel"
		RETURN .f. && campo � somente leitura, conteudo � formula
	ENDPROC

ENDDEFINE

*** FIM CABILOG --> 09/09/14

** PREENCHE A OBSERVA��O DO PEDIDO --> 31/07/14
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
			MESSAGEBOX("Para editar observa��o entre em modo de Altera��o do Pedido",64,"Aviso")
			SELECT (lnArea)
			RETURN
		ENDIF

		IF "PACK:" $ UPPER(ALLTRIM(V_COMPRAS_01.OBS))
			MESSAGEBOX("Apague manualmente a observa��o antes de executar a rotina de preenchimento do PACK na observa��o do pedido",64,"Aviso")
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
	*!*			** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
	*!*			this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	*!*		ENDPROC

ENDDEFINE

*** PAULO DEVIDE
*** TELA PARA PARAMETROS DO 
*** PEDIDO EM INGL�S (EXCEL)
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
** BOT�O PEDIDO INGLES EXCEL
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
		llRet = MESSAGEBOX("Deseja Formatar Pedido no Excel em Ingl�s?",292,"Aviso")=6


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

				** Pega o modelo (template em branco) para gerar o Excel do relat�rio
				f_select(lcSQL,"vCAE_Modelos")

				** Converte a imagem para arquivo bin�rio
				lcTmpArqxls = CAST(vCAE_Modelos.imagem_modelo as blob)

				LOCAL lcArquivo as String
				lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

				STRTOFILE(lcTmpArqxls,lcArquivo) && grava modelo na pasta tempor�ria do usu�rio
				WITH oExcel				
					.workbooks.open(lcArquivo)
					.Sheets(1).Name = "matriz"
					.visible = .T.
					.DisplayAlerts = .F. && Excel n�o apresenta caixa de dialogo que solicita confirma��o

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
					oExcel.DisplayAlerts = .T. && volta status Default - Excel solicita confirma��o para Salvar, Excluir, etc.
				ENDIF
				
			
			ENDIF
			
			RELEASE frmInvoice, llRespInvoice, oExcel
			SELECT v_compras_01
			GO top
			
		ELSE
		
			IF llRet
			
				IF ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,'')) = "ATACADO"		
					*** chamada do PEDIDO INGL�S PARA ATACADO
					*** 1 produto por ABA no Excel

					PUBLIC oExcel as Object
					oExcel = CREATEOBJECT("Excel.Application")
					** Define o nome do arquivo XLSX a ser criado
					lcSQL = "select codigo_modelo,descricao_modelo,imagem_modelo "+;
						"from CAE_MODELOS_EXCEL where codigo_modelo='0001'"

					** Pega o modelo (template em branco) para gerar o Excel do relat�rio
					f_select(lcSQL,"vCAE_Modelos")
					** SET STEP ON
					** Converte a imagem para arquivo bin�rio
					lcTmpArqxls = CAST(vCAE_Modelos.imagem_modelo as blob)

					LOCAL lcArquivo as String
					lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

					STRTOFILE(lcTmpArqxls,lcArquivo) && grava modelo na pasta tempor�ria do usu�rio

					SELECT distinct PRODUTO ;
					FROM v_compras_01_produtos ;
					INTO CURSOR tmpProdutos1

					WITH oExcel				
						.workbooks.open(lcArquivo)
						.Sheets(1).Name = "matriz"
						.visible = .T.
						.DisplayAlerts = .F. && Excel n�o apresenta caixa de dialogo que solicita confirma��o

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
						
					oExcel.DisplayAlerts = .T. && volta status Default - Excel solicita confirma��o para Salvar, Excluir, etc.
					

					RELEASE oExcel

					SELECT v_compras_01
					GO top
					
				ENDIF
				
			ENDIF
				
		ENDIF


	ENDPROC

	PROCEDURE refresh
		** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC

ENDDEFINE
** BOT�O PEDIDO INGLES EXCEL
** FIM: 22-05-2013

*** TELA QUE PEDE A SENHA DO DIRETOR/GERENTE
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
			MESSAGEBOX("Falha na Autentica��o do Login!",64,"Aviso")
		ENDIF
		
		ThisForm.Release
	ENDPROC
	
ENDDEFINE
**** 

***
* Bot�o para chamar a tela para adicionar produto/pack
*/
DEFINE CLASS cmdAddProduto AS CommandButton

	Height = 34
	Left = 19
	Top = 150
	Width = 135
	Name = "cmdAddProduto"
	caption = "Adicionar Produto"
	wordwrap = .t.
	
	objTelaPai = .f.
	
	PROCEDURE init
		
		PARAMETERS oThisformSet
		this.objTelaPai = oThisformSet
					
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE click
		IF v_compras_01.TOT_QTDE_ENTREGAR <> v_compras_01.TOT_QTDE_ORIGINAL
			Messagebox('Esse pedido de compra j� foi recebido total ou parcialmente' +Chr(13)+;
									'Altera��es n�o permitidas!', 16, "Aviso")
			RETURN .F.
		ENDIF

		IF USED("VPRODUTO")
			SELECT VPRODUTO
			IF RECCOUNT("VPRODUTO")=0
				APPEND BLANK
			ENDIF
		ENDIF
		
		IF UPPER(ALLTRIM(v_compras_01.ERP_CUPS_SEGMENTO)) <> "ATACADO"
			
			SELECT V_COMPRAS_01_PRODUTOS
			
			COUNT TO lnTotLinhas ;
				FOR NOT DELETED()
			
			WAIT WINDOW NOWAIT TRANSFORM(lnTotLinhas)
				
			IF lnTotLinhas > 0 &&RECCOUNT("V_COMPRAS_01_PRODUTOS") > 0
			
				MESSAGEBOX("N�o � permitido inserir mais de um "+CHR(13)+;
							"produto para o Segmento VAREJO",64,"Aviso")
				RETURN .F.
				
			ENDIF
			
		ENDIF
		
		frm = CREATEOBJECT("TFormPack",this.objTelaPai)
		frm.show(1)						
	ENDPROC

	PROCEDURE refresh
		** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
	
ENDDEFINE

***
* Bot�o para chamar a tela para excluir produto/pack
*/
DEFINE CLASS cmdDelProduto AS CommandButton

	Height = 34
	Left = 160
	Top = 150
	Width = 135
	Name = "cmdDelProduto"
	caption = "Excluir Produto"
	wordwrap = .t.
	
	objTelaPai = .f.
	
	PROCEDURE init
		
		PARAMETERS oThisformSet
		this.objTelaPai = oThisformSet
					
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE click
		IF v_compras_01.TOT_QTDE_ENTREGAR <> v_compras_01.TOT_QTDE_ORIGINAL
			Messagebox('Esse pedido de compra j� foi recebido total ou parcialmente' +Chr(13)+;
									'Altera��es n�o permitidas!', 16, "Aviso")
			RETURN .F.
		ENDIF

		this.excluir_produtos()
	ENDPROC
	
	PROCEDURE excluir_produtos
		lnResp = MESSAGEBOX("Deseja excluir os lan�amentos informados para o "+CHR(13)+"produto selecionado para todas as cores?", 292, "Aviso")
		IF lnResp = 7
			WAIT WINDOW NOWAIT "Opera��o cancelada pelo usu�rio..."
		ENDIF
		
		SET DELETED on
		
		meuproduto = ALLTRIM(v_compras_01_produtos.produto)
		
		SELECT v_caedu_compras_produtos_packs
		delete FOR ALLTRIM(v_caedu_compras_produtos_packs.produto) = meuproduto		

		SELECT v_caedu_compras_produtos_packs_total
		delete FOR ALLTRIM(v_caedu_compras_produtos_packs_total.produto) = meuproduto		
		
		SELECT v_compras_01_produtos
		delete FOR ALLTRIM(v_compras_01_produtos.produto) = meuproduto		
		
		this.objTelaPai.refresh
		
	ENDPROC
	

	PROCEDURE refresh
		** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
	
ENDDEFINE


***
* Tela para adicionar produto/pack
*/
DEFINE CLASS TFormPack As Form

	Width = 350
	Height = 340
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Minbutton = .f.
	Maxbutton = .f.
	borderstyle = 1
	Caption = "Selecionar Produto/Pack"

	objTelaPai = .f.
	
	gcLogin = ""
	gcPwd = ""

	ADD OBJECT lblProduto as Label WITH;
		Width=200, Height=25, Left=20, Top=15, Caption = "Produto"
	
	ADD OBJECT lblPack as Label WITH;
		Width=200, Height=25, Left=20, Top=45, Caption = "Pack"

	ADD OBJECT lblQtdPack1 as Label WITH;
		Width=200, Height=25, Left=180, Top=45, Caption = "Qtd. Pack", VISIBLE = .T.

	ADD OBJECT lblQtdTotalPack1 as Label WITH;
		Width=200, Height=25, Left=20, Top=75, Caption = "Qtde. Total" 

	ADD OBJECT lblValorTotalPack1 as Label WITH;
		Width=200, Height=25, Left=180, Top=75, Caption = "Valor Total"

	ADD OBJECT lblCustoFob1 as Label WITH;
		Width=200, Height=25, Left=20, Top=105, Caption = "Custo FOB"

	ADD OBJECT lblCustoFobMinimo1 as Label WITH;
		Width=200, Height=25, Left=180, Top=105, Caption = "FOB M�n."

	ADD OBJECT txtProduto as Textbox WITH;
		Width=100, Height=25, Left=100, Top=10 , controlsource = "vPRODUTO.PRODUTO"

	ADD OBJECT lblOrigem1 as Label WITH ;
		Width=100, Height=25, Left=240, Top=10 , CAPTION = "", ForeColor = RGB(255,0,0), ;
		FontBold = .T.
		
	ADD OBJECT cboPack1 as Combobox WITH;
		Width=60, Height=25, Left=100, Top=40 , controlsource = "vPRODUTO.CODIGO_PACK", ;
		RowSourceType = 6, RowSource = "vCboPack.CODIGO_PACK", Style = 2, ;
		SpecialEffect = 1

	ADD OBJECT txtQtdPack1 as Textbox WITH;
		Width=60, Height=25, Left=240, Top=40 , controlsource = "vPRODUTO.QtdPack", VISIBLE = .T.

	ADD OBJECT txtQtdTotalPack1 as Textbox WITH;
		Width=70, Height=25, Left=100, Top=70 , controlsource = "vPRODUTO.QtdTotalPack", ReadOnly = .T.

	ADD OBJECT txtValorTotalPack1 as Textbox WITH;
		Width=100, Height=25, Left=240, Top=70 , controlsource = "vPRODUTO.ValorTotalPack", ReadOnly = .T.

	ADD OBJECT txtCustoFob1 as Textbox WITH;
		Width=70, Height=25, Left=100, Top=100 , controlsource = "vPRODUTO.custofob", ReadOnly = .F.

	ADD OBJECT txtFobMinimo1 as Textbox WITH;
		Width=100, Height=25, Left=240, Top=100 , controlsource = "vPRODUTO.fobminimo", ReadOnly = .F.

	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=222, Top=310, ;
		Caption="Cancel" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=284, Top=310, ;
		Caption="Ok"
		
	ADD OBJECT cmdPesq1 As CommandButton WITH;
		Width=25, Height=25, Left=200, Top=10, ;
		Caption="..."

	ADD OBJECT cntDadosProduto1 as Container WITH ;
		Width=330, Height=100, Left=10, Top=145, SpecialEffect = 1
	

	
	*********************************************************
	*** PROCEDURES, M�TODOS E FUNCTIONS DA TELA TFormPack ***
	*********************************************************
	PROCEDURE init
		
		PARAMETERS oThisformSet
		thisform.objTelaPai = oThisformSet
		
		SELECT vPRODUTO
		GO top
		SCATTER MEMVAR MEMO BLANK
		*
		GATHER MEMVAR
					
	ENDPROC
	
	PROCEDURE cntDadosProduto1.init
	
		this.AddObject("lblProduto","label")
		WITH this.lblProduto
			.AutoSize = .T.
			.Caption = "Produto"
			.Height = 17
			.Left = 8
			.Top = 14
			.Width = 45
			.Name = "lblProduto"
			.Visible = .t.
		ENDWITH
		
		this.AddObject("edtProduto","editbox")
		WITH this.edtProduto
			.Height = 46
			.Left = 68
			.ReadOnly = .T.
			.Enabled = .f.
			.Top = 14
			.Width = 255
			.Name = "edtProduto"
			.Value = ""
			.Visible = .t.
		ENDWITH

		this.AddObject("lblTotalPack","label")
		WITH this.lblTotalPack
			.AutoSize = .T.
			.Caption = "Total Pack"
			.Height = 17
			.Left = 8
			.Top = 74
			.Width = 45
			.Name = "lblTotalPack"
			.Visible = .t.
		ENDWITH
		
		this.AddObject("txtTotalPack","textbox")
		WITH this.txtTotalPack
			.Height = 23
			.Left = 68
			.ReadOnly = .T.
			.Enabled = .f.
			.Top = 74
			.Width = 60
			.Name = "txtTotalPack"
			.Value = 0
			.Visible = .t.
		ENDWITH

		this.AddObject("lblCusto","label")
		WITH this.lblCusto
			.AutoSize = .T.
			.Caption = "Custo R$"
			.Height = 17
			.Left = 163
			.Top = 74
			.Width = 45
			.Name = "lblCusto"
			.Visible = .t.
		ENDWITH
		
		this.AddObject("txtCusto","textbox")
		WITH this.txtCusto
			.Height = 23
			.Left = 225
			.ReadOnly = .T.
			.Enabled = .f.
			.Top = 74
			.Width = 100
			.Name = "txtCusto"
			.Value = 0.00
			.InputMask = "999,999.99"
			.Visible = .t.
		ENDWITH

	ENDPROC
	

	PROCEDURE activate
		thisform.Refresh
	ENDPROC
	
	PROCEDURE cmd1.Click
		ThisForm.Release
	ENDPROC

	** Bot�o OK
	PROCEDURE cmd2.Click
		
		thisform.calcula2()
		IF thisform.inserir_produto()		
			ThisForm.Release
		ENDIF
	ENDPROC

	PROCEDURE cmdPesq1.Click
		frmPesq1 = NEWOBJECT("Tpesqproduto")
		frmPesq1.show(1)						
	ENDPROC
	
	PROCEDURE txtProduto.Valid
		TEXT TO lcSQL NOSHOW TEXTMERGE
			SELECT produto FROM produtos 
			where produto = '<<ALLTRIM(NVL(this.value,""))>>'
		ENDTEXT
		f_select(lcSQL,"vInfoProduto")
		IF RECCOUNT("vInfoProduto")=0
			thisform.cmdPesq1.Click()
			meuproduto = ALLTRIM(vProduto.produto)
			thisform.requery_cursores_produtos()
			thisform.montaComboPack()	
			thisform.lblOrigem1.CAPTION = IIF(thisform.ORIGEM_PRODUTO(meuproduto)="N","nacional","importado")
		ELSE
			meuproduto = ALLTRIM(vProduto.produto)
			thisform.requery_cursores_produtos()
			thisform.montaComboPack()	
			thisform.lblOrigem1.CAPTION = IIF(thisform.ORIGEM_PRODUTO(meuproduto)="N","nacional","importado")
		ENDIF
	ENDPROC

	PROCEDURE ORIGEM_PRODUTO
		LPARAMETERS _produtoId
		oMetrica = CREATEOBJECT("funcoes_metricas")
		RETURN oMetrica.ORIGEM_PRODUTO(_produtoId)
	ENDPROC
		
	PROCEDURE requery_cursores_produtos
		SELECT v_produtos_99
		=REQUERY()

		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS
		=REQUERY()

		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		=REQUERY()	
		WAIT WINDOW NOWAIT "Cursores carregados..."

		f_select("select preco1 from PRODUTOS_precos where PRODUTO = ?meuproduto and CODIGO_TAB_PRECO = '00' ","caepreco")
		xcaepreco = caepreco.preco1

		TEXT TO lcSQL NOSHOW TEXTMERGE
			SELECT * 
			FROM PRODUTOS_PACKS_PERMITIDOS 
			WHERE PRODUTO = '<<meuproduto>>'
		ENDTEXT
		F_select(lcSQL, "vtmpProdutoPackPermitido")
		SELECT vtmpProdutoPackPermitido
		INDEX ON PACK + PRODUTO + COR_PRODUTO TAG INDX1
		SET ORDER TO TAG INDX1
				
		thisform.cntDadosProduto1.edtProduto.value = ALLTRIM(v_produtos_99.desc_produto)
		thisform.cntDadosProduto1.txtTotalPack.value = v_produtos_99.erp_qtd_pack
		thisform.cntDadosProduto1.txtCusto.value = xcaepreco
		thisform.cntDadosProduto1.Refresh
		
	ENDPROC

		
	PROCEDURE montaComboPack
		***
		* carrega dados no combobox de sele��o de pack
		*/
		SET SAFETY off
		SELECT vCboPack
		ZAP
		
		TEXT TO lcSQL NOSHOW TEXTMERGE
			SELECT distinct PACK AS CODIGO_PACK 
			FROM PRODUTOS_PACKS_PERMITIDOS 
			WHERE PRODUTO = '<<ALLTRIM(vPRODUTO.PRODUTO)>>'
		ENDTEXT
		F_SELECT(lcSQL,"tmpPackProduto1")
		
		SELECT vCboPack
		APPEND FROM DBF("tmpPackProduto1")			
		GO top
		REPLACE vPRODUTO.CODIGO_PACK WITH vCboPack.CODIGO_PACK 
		thisform.Refresh
		
	ENDPROC

	PROCEDURE txtQtdPack1.when
		thisform.cboPack1.valid()
		RETURN .t.
	ENDPROC

	PROCEDURE txtQtdPack1.valid
		thisform.calcula1()
		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		GO top

		xtotpack  = V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.qtde

		thisform.txtQtdTotalPack1.Value = xtotpack  * (thisform.txtQtdPack1.Value)

		f_select("select preco1 from PRODUTOS_precos where PRODUTO = ?meuproduto and CODIGO_TAB_PRECO = '00' ","caepreco")
		xcaepreco = caepreco.preco1

		thisform.txtValorTotalPack1.Value  = thisform.txtQtdTotalPack1.Value * xcaepreco 
	ENDPROC
	

	PROCEDURE cboPack1.valid
		thisform.requery_cursores_produtos()
		
		SELECT vtmpProdutoPackPermitido
		GO top
		
		SCAN FOR ALLTRIM(PACK) = ALLTRIM(vPRODUTO.CODIGO_PACK)
			SELECT vtmpProdutoPackPermitido		
			SCATTER MEMVAR
			
			SELECT V_PRODUTOS_00_PACKS_PERMITIDOS
			LOCATE FOR ALLTRIM(PRODUTO) = ALLTRIM(vtmpProdutoPackPermitido.PRODUTO) ;
				AND ALLTRIM(COR_PRODUTO) = ALLTRIM(vtmpProdutoPackPermitido.COR_PRODUTO)
			IF FOUND()
				GATHER MEMVAR
				REPLACE INATIVO WITH 1
			ENDIF
						
			SELECT vtmpProdutoPackPermitido		
		ENDSCAN
		
	ENDPROC
		
	*** ROTINAS DE CALCULO DA GRADE DE PACK ***
	
	PROCEDURE calcula1
		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS
		*replace ALL inativo WITH 1
		GO top

		SUM qtde ,Q1, Q2, Q3, Q4,Q5, Q6, Q7, Q8,Q9, Q10, Q11, Q12,Q13, Q14, Q15, Q16,Q17, Q18, Q19, Q20,Q21, Q22, Q23, Q24,Q25, Q26, Q27, Q28 for inativo = 1 ;
			TO VCAEQTDE, VCAE1, VCAE2, VCAE3, VCAE4, VCAE5, VCAE6, VCAE7, VCAE8, VCAE9, VCAE10, VCAE11, VCAE12, VCAE13, VCAE14, VCAE15, VCAE16, VCAE17, ;
			VCAE18, VCAE19, VCAE20, VCAE21, VCAE22, VCAE23, VCAE24, VCAE25, VCAE26, VCAE27, VCAE28


		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_total

		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.qtde with VCAEqtde
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q1 with VCAE1
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q2 with VCAE2
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q3 with VCAE3
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q4 with VCAE4
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q5 with VCAE5
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q6 with VCAE6
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q7 with VCAE7
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q8 with VCAE8
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q9 with VCAE9
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q10 with VCAE10
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q11 with VCAE11
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q12 with VCAE12
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q13 with VCAE13
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q14 with VCAE14
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q15 with VCAE15
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q16 with VCAE16
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q17 with VCAE17
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q18 with VCAE18
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q19 with VCAE19
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q20 with VCAE20
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q21 with VCAE21
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q22 with VCAE22
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q23 with VCAE23
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q24 with VCAE24
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q25 with VCAE25
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q26 with VCAE26
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q27 with VCAE27
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q28 with VCAE28

		thisform.lx_grade48_recalculo()
	
	ENDPROC
	
	PROCEDURE calcula2
		SELECT V_PRODUTOS_PACK_DISTRIB
		DELETE all
		 
		thisform.calcula1()

		IF thisform.txtQtdPack1.Value  > 0

			SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
			GO top
			xtotpack =  V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.qtde
			xtotprod = thisform.txtQtdTotalPack1.Value

			SELECT v_produtos_00_packs_permitidos
			SCAN
				IF V_produtos_00_packs_permitidos.INATIVO = 1
					
					SELECT v_produtos_pack_distrib
					APPEND BLANK 

					replace v_produtos_pack_distrib.COR_PRODUTO WITH   v_produtos_00_packs_permitidos.COR_PRODUTO
					replace v_produtos_pack_distrib.DESC_COR_PRODUTO WITH   v_produtos_00_packs_permitidos.DESC_COR_PRODUTO
					replace v_produtos_pack_distrib.produto WITH   v_produtos_00_packs_permitidos.produto

					replace v_produtos_pack_distrib.qtde WITH   ((xtotprod  /xtotpack )* v_produtos_00_packs_permitidos.qtde )
					replace v_produtos_pack_distrib.Q1 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q1 )
					replace v_produtos_pack_distrib.Q2 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q2 )
					replace v_produtos_pack_distrib.Q3 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q3 )
					replace v_produtos_pack_distrib.Q4 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q4 )
					replace v_produtos_pack_distrib.Q5 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q5 )
					replace v_produtos_pack_distrib.Q6 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q6 )
					replace v_produtos_pack_distrib.Q7 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q7 )
					replace v_produtos_pack_distrib.Q8 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q8 )
					replace v_produtos_pack_distrib.Q9 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q9 )
					replace v_produtos_pack_distrib.Q10 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q10 )
					replace v_produtos_pack_distrib.Q11 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q11 )
					replace v_produtos_pack_distrib.Q12 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q12 )
					replace v_produtos_pack_distrib.Q13 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q13 )
					replace v_produtos_pack_distrib.Q14 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q14 )
					replace v_produtos_pack_distrib.Q15 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q15 )
					replace v_produtos_pack_distrib.Q16 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q16 )
					replace v_produtos_pack_distrib.Q17 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q17 )
					replace v_produtos_pack_distrib.Q18 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q18 )
					replace v_produtos_pack_distrib.Q19 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q19 )
					replace v_produtos_pack_distrib.Q20 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q20 )
					replace v_produtos_pack_distrib.Q21 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q21 )
					replace v_produtos_pack_distrib.Q22 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q22 )
					replace v_produtos_pack_distrib.Q23 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q23 )
					replace v_produtos_pack_distrib.Q24 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q24 )
					replace v_produtos_pack_distrib.Q25 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q25 )
					replace v_produtos_pack_distrib.Q26 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q26 )
					replace v_produtos_pack_distrib.Q27 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q27 )
					replace v_produtos_pack_distrib.Q28 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q28 )
					replace v_produtos_pack_distrib.Q29 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q29 )
					replace v_produtos_pack_distrib.Q30 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q30 )
					replace v_produtos_pack_distrib.Q31 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q31 )
					replace v_produtos_pack_distrib.Q32 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q32 )
					replace v_produtos_pack_distrib.Q33 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q33 )
					replace v_produtos_pack_distrib.Q34 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q34 )
					replace v_produtos_pack_distrib.Q35 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q35 )
					replace v_produtos_pack_distrib.Q36 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q36 )
					replace v_produtos_pack_distrib.Q37 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q37 )
					replace v_produtos_pack_distrib.Q38 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q38 )
					replace v_produtos_pack_distrib.Q39 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q39 )
					replace v_produtos_pack_distrib.Q40 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q40 )
					replace v_produtos_pack_distrib.Q41 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q41 )
					replace v_produtos_pack_distrib.Q42 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q42 )
					replace v_produtos_pack_distrib.Q43 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q43 )
					replace v_produtos_pack_distrib.Q44 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q44 )
					replace v_produtos_pack_distrib.Q45 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q45 )
					replace v_produtos_pack_distrib.Q46 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q46 )
					replace v_produtos_pack_distrib.Q47 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q47 )
					replace v_produtos_pack_distrib.Q48 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q48 )
				ENDIF
			SELECT v_produtos_00_packs_permitidos	
			ENDSCAN
		ELSE
		ENDIF

		SELECT v_produtos_pack_distrib
		GO top

		thisform.Refresh()
	
	ENDPROC
			
	PROCEDURE lx_grade48_recalculo
		lPara xPara
		Local xQtde,xS,xQtde_Ant,xQtde_Atual
		Sele V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL

		xQtde = F_Tam()
		xQtde.Carga('Q#')
		Replace Qtde With xQtde.Soma_Grade()
	ENDPROC
	
	***
	* Preenche os dados do campo observa��o do pedido, com as informa��es 
	* da grade de pack do produto
	*/
	PROCEDURE preenche_obs_pack
		LOCAL lcObs, lnArea
		lnArea = SELECT()

		IF ALLTRIM(NVL(V_COMPRAS_01.ERP_CUPS_SEGMENTO,"")) = "VAREJO" && OBS. somente � preenchido para o segmento VAREJO -> PAULO DEVID� - 25-08-2015

			SELECT v_caedu_compras_produtos_packs
			GO top

			** variavel que acumula as observa��es de cada linha
			lcObs = ALLTRIM(V_COMPRAS_01.OBS)+CHR(13)+CHR(13)+;
				'PACK:'+CHR(13)+;
				REPLICATE('-',120)+CHR(13)


			SCAN

				zret = ""

				F_SELECT("SELECT * FROM PRODUTOS WHERE PRODUTO=?v_caedu_compras_produtos_packs.produto","tmpProduto1")

				zgrade = ""
				IF RECCOUNT("tmpProduto1")>0
					STORE UPPER(ALLTRIM(tmpProduto1.grade)) TO zgrade
				ENDIF

				SELECT v_produtos_tamanho_00
				LOCATE FOR UPPER(ALLTRIM(grade)) = zgrade
				ztam_digitados = v_produtos_tamanho_00.tamanhos_digitados

				FOR ii=1 TO ztam_digitados

					ztamanho = "TAMANHO_"+ALLTRIM(TRANSFORM(ii,"99"))
					IF RIGHT(ALLTRIM(NVL(EVALUATE(ztamanho),"")),1)="."
						ztam1 = ""
					ELSE
						ztam1 = ALLTRIM(NVL(EVALUATE(ztamanho),""))
						zq = "NVL(v_caedu_compras_produtos_packs.q"+ALLTRIM(TRANSFORM(ii,"99"))+",0)"
						ztam1 = ztam1 + "=" + ALLTRIM(TRANSFORM(EVALUATE(zq),"99999"))
					ENDIF

					zret= zret + ztam1 + IIF(EMPTY(ztam1),""," / ")

				ENDFOR

				IF RIGHT(ALLTRIM(zret),1)="/"
					zret = LEFT(zret,LEN(zret)-2)
				ENDIF
				zret = ALLTRIM(v_caedu_compras_produtos_packs.DESC_COR_PRODUTO)+": "+ zret + " TOTAL = "+;
					TRANSFORM(v_caedu_compras_produtos_packs.qtde,"9999") + CHR(13)
				lcObs = lcObs + zret

			ENDSCAN


			SELECT V_COMPRAS_01
			IF NOT EMPTY(lcObs)
				replace V_COMPRAS_01.OBS WITH lcObs
			ENDIF
			
			thisform.objTelaPai.lx_form1.lx_pageframe1.Page5.ed_obs.refresh

			SELECT (lnArea)

		ENDIF


	ENDPROC
	

	***
	* Grava o produto selecionado na tabela compras_produto
	*/	
	PROCEDURE inserir_produto
		IF RECCOUNT("V_PRODUTOS_PACK_DISTRIB")<= 0
			RETURN .f.
		endif

		IF UPPER(ALLTRIM(v_compras_01.ERP_CUPS_SEGMENTO)) = "ATACADO"
			lcMessage = ""

			IF EMPTY(NVL(vPRODUTO.CUSTOFOB,0))
				lcMessage = lcMessage + "Campo Custo Fob deve ser preenchido para o segmento ATACADO" + REPLICATE(CHR(13),2)
			ENDIF

			IF !EMPTY(lcMessage)
				MESSAGEBOX(lcMessage,16,"Aviso")
				RETURN .f.
			ENDIF

		ENDIF

		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
		IF UPPER(ALLTRIM(v_compras_01.ERP_CUPS_SEGMENTO)) <> "ATACADO"
			DELETE ALL
		ENDIF

		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		IF UPPER(ALLTRIM(v_compras_01.ERP_CUPS_SEGMENTO)) <> "ATACADO"
			DELETE ALL
		ENDIF

		SELECT v_produtos_00_packs_permitidos
		SCAN
			IF V_produtos_00_packs_permitidos.INATIVO = 1

				SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
				APPEND BLANK

				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Pedido WITH   v_compras_01.PEDIDO
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.COR_PRODUTO WITH   v_produtos_00_packs_permitidos.COR_PRODUTO
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.DESC_COR_PRODUTO WITH   v_produtos_00_packs_permitidos.DESC_COR_PRODUTO
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto WITH   v_produtos_00_packs_permitidos.produto

				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.qtde WITH   v_produtos_00_packs_permitidos.qtde
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q1 WITH    v_produtos_00_packs_permitidos.Q1
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q2 WITH    v_produtos_00_packs_permitidos.Q2
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q3 WITH    v_produtos_00_packs_permitidos.Q3
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q4 WITH    v_produtos_00_packs_permitidos.Q4
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q5 WITH    v_produtos_00_packs_permitidos.Q5
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q6 WITH    v_produtos_00_packs_permitidos.Q6
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q7 WITH    v_produtos_00_packs_permitidos.Q7
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q8 WITH    v_produtos_00_packs_permitidos.Q8
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q9 WITH    v_produtos_00_packs_permitidos.Q9
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q10 WITH    v_produtos_00_packs_permitidos.Q10
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q11 WITH    v_produtos_00_packs_permitidos.Q11
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q12 WITH    v_produtos_00_packs_permitidos.Q12
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q13 WITH    v_produtos_00_packs_permitidos.Q13
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q14 WITH    v_produtos_00_packs_permitidos.Q14
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q15 WITH    v_produtos_00_packs_permitidos.Q15
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q16 WITH    v_produtos_00_packs_permitidos.Q16
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q17 WITH    v_produtos_00_packs_permitidos.Q17
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q18 WITH    v_produtos_00_packs_permitidos.Q18
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q19 WITH    v_produtos_00_packs_permitidos.Q19
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q20 WITH    v_produtos_00_packs_permitidos.Q20
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q21 WITH    v_produtos_00_packs_permitidos.Q21
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q22 WITH    v_produtos_00_packs_permitidos.Q22
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q23 WITH    v_produtos_00_packs_permitidos.Q23
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q24 WITH    v_produtos_00_packs_permitidos.Q24
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q25 WITH    v_produtos_00_packs_permitidos.Q25
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q26 WITH    v_produtos_00_packs_permitidos.Q26
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q27 WITH    v_produtos_00_packs_permitidos.Q27
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q28 WITH    v_produtos_00_packs_permitidos.Q28
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q29 WITH    v_produtos_00_packs_permitidos.Q29
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q30 WITH    v_produtos_00_packs_permitidos.Q30
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q31 WITH    v_produtos_00_packs_permitidos.Q31
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q32 WITH    v_produtos_00_packs_permitidos.Q32
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q33 WITH    v_produtos_00_packs_permitidos.Q33
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q34 WITH    v_produtos_00_packs_permitidos.Q34
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q35 WITH    v_produtos_00_packs_permitidos.Q35
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q36 WITH    v_produtos_00_packs_permitidos.Q36
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q37 WITH    v_produtos_00_packs_permitidos.Q37
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q38 WITH    v_produtos_00_packs_permitidos.Q38
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q39 WITH    v_produtos_00_packs_permitidos.Q39
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q40 WITH    v_produtos_00_packs_permitidos.Q40
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q41 WITH    v_produtos_00_packs_permitidos.Q41
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q42 WITH    v_produtos_00_packs_permitidos.Q42
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q43 WITH    v_produtos_00_packs_permitidos.Q43
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q44 WITH    v_produtos_00_packs_permitidos.Q44
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q45 WITH    v_produtos_00_packs_permitidos.Q45
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q46 WITH    v_produtos_00_packs_permitidos.Q46
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q47 WITH    v_produtos_00_packs_permitidos.Q47
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q48 WITH    v_produtos_00_packs_permitidos.Q48

			ENDIF
			SELECT v_produtos_00_packs_permitidos
		ENDSCAN

		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
		GO top

		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		SCAN

			SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
			APPEND BLANK

			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Pedido WITH   v_compras_01.PEDIDO
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.produto WITH   V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.produto
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde WITH   V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.qtde
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q1 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q1
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q2 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q2
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q3 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q3
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q4 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q4
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q5 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q5
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q6 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q6
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q7 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q7
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q8 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q8
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q9 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q9
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q10 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q10
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q11 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q11
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q12 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q12
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q13 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q13
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q14 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q14
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q15 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q15
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q16 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q16
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q17 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q17
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q18 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q18
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q19 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q19
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q20 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q20
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q21 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q21
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q22 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q22
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q23 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q23
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q24 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q24
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q25 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q25
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q26 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q26
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q27 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q27
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q28 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q28
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q29 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q29
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q30 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q30
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q31 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q31
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q32 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q32
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q33 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q33
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q34 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q34
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q35 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q35
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q36 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q36
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q37 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q37
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q38 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q38
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q39 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q39
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q40 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q40
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q41 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q41
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q42 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q42
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q43 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q43
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q44 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q44
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q45 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q45
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q46 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q46
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q47 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q47
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q48 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q48
			SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		ENDSCAN

		sele V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		go top
		

		
		SELECT V_PRODUTOS_PACK_DISTRIB
		GO top
		SCAN
			xProduto = Alltrim( V_PRODUTOS_PACK_DISTRIB.PRODUTO )
			xcor_produto =  Alltrim( V_PRODUTOS_PACK_DISTRIB.cor_PRODUTO )
			If F_Select('SELECT PRODUTO, COR_PRODUTO, DESC_COR_PRODUTO, SORTIMENTO_COR FROM PRODUTO_CORES where produto = ?xProduto and cor_produto = ?cor_produto ','xCurCor')
				If Reccount('xCurCor') > 0

					Select xCurCor
					Scan
						Select V_Compras_01_Produtos
						Append Blank
						thisform.objTelaPai.l_desenhista_filhas_inclui_apos()

						Replace Produto 	 With xCurCor.Produto, ;
							Cor_Produto 	 With xCurCor.Cor_Produto, ;
							Desc_Cor_Produto With xCurCor.Desc_Cor_Produto, ;
							Sortimento_cor   With xCurCor.SORTIMENTO_COR, ;
							REQUISICAO       With NULL In v_Compras_01_Produtos
							
						thisform.objTelaPai.LX_Form1.lx_pageframe1.page4.tv_COR_PRODUTO.l_desenhista_recalculo()

						SELECT xCurCor
					endscan
				endif
			endif
			SELECT V_PRODUTOS_PACK_DISTRIB
		ENDSCAN

		******************************************************************************************************************************************

		SELECT v_produtos_pack_distrib
		SCAN

			SELECT v_compras_01_produtos
			GO top
			LOCATE FOR v_produtos_pack_distrib.produto = v_compras_01_produtos.produto  AND ;
				v_produtos_pack_distrib.cor_produto = v_compras_01_produtos.cor_produto
			IF FOUND()

				f_select('select * from produtos where produto = ?v_produtos_pack_distrib.produto ', 'xydesc')

				SELECT V_COMPRAS_01_PRODUTOS


				replace V_COMPRAS_01_PRODUTOS.DESC_PRODUTO WITH xydesc.desc_produto
				replace V_COMPRAS_01_PRODUTOS.entrega	WITH thisform.objTelaPai.lx_foRM1.lx_PAGEFRAME1.page1.tx_ENTREGA_UNICA.Value
				replace V_COMPRAS_01_PRODUTOS.limite_entrega	WITH thisform.objTelaPai.lx_foRM1.lx_PAGEFRAME1.page1.tx_lIMITE_ENTREGA_UNICA.Value

				replace V_COMPRAS_01_PRODUTOS.packs WITH vPRODUTO.CODIGO_PACK
				
				replace v_compras_01_produtos.CO1 WITH   v_produtos_pack_distrib.Q1
				replace v_compras_01_produtos.CO2 WITH   v_produtos_pack_distrib.Q2
				replace v_compras_01_produtos.CO3 WITH   v_produtos_pack_distrib.Q3
				replace v_compras_01_produtos.CO4 WITH   v_produtos_pack_distrib.Q4
				replace v_compras_01_produtos.CO5 WITH   v_produtos_pack_distrib.Q5
				replace v_compras_01_produtos.CO6 WITH   v_produtos_pack_distrib.Q6
				replace v_compras_01_produtos.CO7 WITH   v_produtos_pack_distrib.Q7
				replace v_compras_01_produtos.CO8 WITH   v_produtos_pack_distrib.Q8
				replace v_compras_01_produtos.CO9 WITH   v_produtos_pack_distrib.Q9
				replace v_compras_01_produtos.CO10 WITH   v_produtos_pack_distrib.Q10
				replace v_compras_01_produtos.CO11 WITH   v_produtos_pack_distrib.Q11
				replace v_compras_01_produtos.CO12 WITH   v_produtos_pack_distrib.Q12
				replace v_compras_01_produtos.CO13 WITH   v_produtos_pack_distrib.Q13
				replace v_compras_01_produtos.CO14 WITH   v_produtos_pack_distrib.Q14
				replace v_compras_01_produtos.CO15 WITH   v_produtos_pack_distrib.Q15
				replace v_compras_01_produtos.CO16 WITH   v_produtos_pack_distrib.Q16
				replace v_compras_01_produtos.CO17 WITH   v_produtos_pack_distrib.Q17
				replace v_compras_01_produtos.CO18 WITH   v_produtos_pack_distrib.Q18
				replace v_compras_01_produtos.CO19 WITH   v_produtos_pack_distrib.Q19
				replace v_compras_01_produtos.CO20 WITH   v_produtos_pack_distrib.Q20
				replace v_compras_01_produtos.CO21 WITH   v_produtos_pack_distrib.Q21
				replace v_compras_01_produtos.CO22 WITH   v_produtos_pack_distrib.Q22
				replace v_compras_01_produtos.CO23 WITH   v_produtos_pack_distrib.Q23
				replace v_compras_01_produtos.CO24 WITH   v_produtos_pack_distrib.Q24
				replace v_compras_01_produtos.CO25 WITH   v_produtos_pack_distrib.Q25
				replace v_compras_01_produtos.CO26 WITH   v_produtos_pack_distrib.Q26
				replace v_compras_01_produtos.CO27 WITH   v_produtos_pack_distrib.Q27
				replace v_compras_01_produtos.CO28 WITH   v_produtos_pack_distrib.Q28
				replace v_compras_01_produtos.CO29 WITH   v_produtos_pack_distrib.Q29
				replace v_compras_01_produtos.CO30 WITH   v_produtos_pack_distrib.Q30
				replace v_compras_01_produtos.CO31 WITH   v_produtos_pack_distrib.Q31
				replace v_compras_01_produtos.CO32 WITH   v_produtos_pack_distrib.Q32
				replace v_compras_01_produtos.CO33 WITH   v_produtos_pack_distrib.Q33
				replace v_compras_01_produtos.CO34 WITH   v_produtos_pack_distrib.Q34
				replace v_compras_01_produtos.CO35 WITH   v_produtos_pack_distrib.Q35
				replace v_compras_01_produtos.CO36 WITH   v_produtos_pack_distrib.Q36
				replace v_compras_01_produtos.CO37 WITH   v_produtos_pack_distrib.Q37
				replace v_compras_01_produtos.CO38 WITH   v_produtos_pack_distrib.Q38
				replace v_compras_01_produtos.CO39 WITH   v_produtos_pack_distrib.Q39
				replace v_compras_01_produtos.CO40 WITH   v_produtos_pack_distrib.Q40
				replace v_compras_01_produtos.CO41 WITH   v_produtos_pack_distrib.Q41
				replace v_compras_01_produtos.CO42 WITH   v_produtos_pack_distrib.Q42
				replace v_compras_01_produtos.CO43 WITH   v_produtos_pack_distrib.Q43
				replace v_compras_01_produtos.CO44 WITH   v_produtos_pack_distrib.Q44
				replace v_compras_01_produtos.CO45 WITH   v_produtos_pack_distrib.Q45
				replace v_compras_01_produtos.CO46 WITH   v_produtos_pack_distrib.Q46
				replace v_compras_01_produtos.CO47 WITH   v_produtos_pack_distrib.Q47
				replace v_compras_01_produtos.CO48 WITH   v_produtos_pack_distrib.Q48
				replace v_compras_01_produtos.CE1 WITH   v_produtos_pack_distrib.Q1
				replace v_compras_01_produtos.CE2 WITH   v_produtos_pack_distrib.Q2
				replace v_compras_01_produtos.CE3 WITH   v_produtos_pack_distrib.Q3
				replace v_compras_01_produtos.CE4 WITH   v_produtos_pack_distrib.Q4
				replace v_compras_01_produtos.CE5 WITH   v_produtos_pack_distrib.Q5
				replace v_compras_01_produtos.CE6 WITH   v_produtos_pack_distrib.Q6
				replace v_compras_01_produtos.CE7 WITH   v_produtos_pack_distrib.Q7
				replace v_compras_01_produtos.CE8 WITH   v_produtos_pack_distrib.Q8
				replace v_compras_01_produtos.CE9 WITH   v_produtos_pack_distrib.Q9
				replace v_compras_01_produtos.CE10 WITH   v_produtos_pack_distrib.Q10
				replace v_compras_01_produtos.CE11 WITH   v_produtos_pack_distrib.Q11
				replace v_compras_01_produtos.CE12 WITH   v_produtos_pack_distrib.Q12
				replace v_compras_01_produtos.CE13 WITH   v_produtos_pack_distrib.Q13
				replace v_compras_01_produtos.CE14 WITH   v_produtos_pack_distrib.Q14
				replace v_compras_01_produtos.CE15 WITH   v_produtos_pack_distrib.Q15
				replace v_compras_01_produtos.CE16 WITH   v_produtos_pack_distrib.Q16
				replace v_compras_01_produtos.CE17 WITH   v_produtos_pack_distrib.Q17
				replace v_compras_01_produtos.CE18 WITH   v_produtos_pack_distrib.Q18
				replace v_compras_01_produtos.CE19 WITH   v_produtos_pack_distrib.Q19
				replace v_compras_01_produtos.CE20 WITH   v_produtos_pack_distrib.Q20
				replace v_compras_01_produtos.CE21 WITH   v_produtos_pack_distrib.Q21
				replace v_compras_01_produtos.CE22 WITH   v_produtos_pack_distrib.Q22
				replace v_compras_01_produtos.CE23 WITH   v_produtos_pack_distrib.Q23
				replace v_compras_01_produtos.CE24 WITH   v_produtos_pack_distrib.Q24
				replace v_compras_01_produtos.CE25 WITH   v_produtos_pack_distrib.Q25
				replace v_compras_01_produtos.CE26 WITH   v_produtos_pack_distrib.Q26
				replace v_compras_01_produtos.CE27 WITH   v_produtos_pack_distrib.Q27
				replace v_compras_01_produtos.CE28 WITH   v_produtos_pack_distrib.Q28
				replace v_compras_01_produtos.CE29 WITH   v_produtos_pack_distrib.Q29
				replace v_compras_01_produtos.CE30 WITH   v_produtos_pack_distrib.Q30
				replace v_compras_01_produtos.CE31 WITH   v_produtos_pack_distrib.Q31
				replace v_compras_01_produtos.CE32 WITH   v_produtos_pack_distrib.Q32
				replace v_compras_01_produtos.CE33 WITH   v_produtos_pack_distrib.Q33
				replace v_compras_01_produtos.CE34 WITH   v_produtos_pack_distrib.Q34
				replace v_compras_01_produtos.CE35 WITH   v_produtos_pack_distrib.Q35
				replace v_compras_01_produtos.CE36 WITH   v_produtos_pack_distrib.Q36
				replace v_compras_01_produtos.CE37 WITH   v_produtos_pack_distrib.Q37
				replace v_compras_01_produtos.CE38 WITH   v_produtos_pack_distrib.Q38
				replace v_compras_01_produtos.CE39 WITH   v_produtos_pack_distrib.Q39
				replace v_compras_01_produtos.CE40 WITH   v_produtos_pack_distrib.Q40
				replace v_compras_01_produtos.CE41 WITH   v_produtos_pack_distrib.Q41
				replace v_compras_01_produtos.CE42 WITH   v_produtos_pack_distrib.Q42
				replace v_compras_01_produtos.CE43 WITH   v_produtos_pack_distrib.Q43
				replace v_compras_01_produtos.CE44 WITH   v_produtos_pack_distrib.Q44
				replace v_compras_01_produtos.CE45 WITH   v_produtos_pack_distrib.Q45
				replace v_compras_01_produtos.CE46 WITH   v_produtos_pack_distrib.Q46
				replace v_compras_01_produtos.CE47 WITH   v_produtos_pack_distrib.Q47
				replace v_compras_01_produtos.CE48 WITH   v_produtos_pack_distrib.Q48

				***
				* projeto CUPS
				*/
				replace v_compras_01_produtos.GRADE WITH ALLTRIM(NVL(xydesc.grade,''))
				***
				* verificar estes 2 campos abaixo - 26/08/2016
				*/
				**replace v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA with thisform.objTelaPai.lx_form1.lx_pageframe1.page20.txt_qtd_caixas1.value
				replace v_compras_01_produtos.ERP_CUPS_CUSTO_FOB with vPRODUTO.CUSTOFOB &&thisform.objTelaPai.lx_form1.lx_pageframe1.page20.txt_custo_fob1.value
				replace v_compras_01_produtos.ERP_CUPS_CUSTO_FOB_MINIMO with vPRODUTO.FOBMINIMO &&thisform.objTelaPai.lx_form1.lx_pageframe1.page20.txt_custo_fob1.value
				************************************************************************************************************************************

				xtoty  =  v_compras_01_produtos.CO1 + v_compras_01_produtos.CO2 +  v_compras_01_produtos.CO3 +  ;
					v_compras_01_produtos.CO4 + v_compras_01_produtos.CO5 +  v_compras_01_produtos.CO6 +  ;
					v_compras_01_produtos.CO7 +  v_compras_01_produtos.CO8 +  v_compras_01_produtos.CO9 +  ;
					v_compras_01_produtos.CO10 +  v_compras_01_produtos.CO11 +  v_compras_01_produtos.CO12 +  ;
					v_compras_01_produtos.CO13 +  v_compras_01_produtos.CO14 +  v_compras_01_produtos.CO15 +  ;
					v_compras_01_produtos.CO16 +  v_compras_01_produtos.CO17 +  v_compras_01_produtos.CO18 +  ;
					v_compras_01_produtos.CO19 +  v_compras_01_produtos.CO20 +  v_compras_01_produtos.CO21 +  ;
					v_compras_01_produtos.CO22 +  v_compras_01_produtos.CO23 +  v_compras_01_produtos.CO24 +  ;
					v_compras_01_produtos.CO25 +  v_compras_01_produtos.CO26 +  v_compras_01_produtos.CO27 +  ;
					v_compras_01_produtos.CO28 +  v_compras_01_produtos.CO29 +  v_compras_01_produtos.CO30 +  ;
					v_compras_01_produtos.CO31 +  v_compras_01_produtos.CO32 +  v_compras_01_produtos.CO33 +  ;
					v_compras_01_produtos.CO34 +  v_compras_01_produtos.CO35 +  v_compras_01_produtos.CO36 +  ;
					v_compras_01_produtos.CO37 +  v_compras_01_produtos.CO38 +  v_compras_01_produtos.CO39 +  ;
					v_compras_01_produtos.CO40 +  v_compras_01_produtos.CO41 +  v_compras_01_produtos.CO42 +  ;
					v_compras_01_produtos.CO43 +  v_compras_01_produtos.CO44 +  v_compras_01_produtos.CO45 +  ;
					v_compras_01_produtos.CO46 +  v_compras_01_produtos.CO47 +  v_compras_01_produtos.CO48

				replace v_compras_01_produtos.qtde_entregar WITH   xtoty
				replace v_compras_01_produtos.qtde_original WITH   xtoty
				replace v_compras_01_produtos.valor_entregar WITH   v_compras_01_produtos.custo1 * xtoty
				replace v_compras_01_produtos.valor_original WITH   v_compras_01_produtos.custo1 * xtoty

			endif
		ENDSCAN

		SELECT v_compras_01_produtos
		GO top

		*meuproduto = 'xpto'
		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS
		=REQUERY()

		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		=REQUERY()


		SELECT V_PRODUTOS_PACK_DISTRIB
		DELETE ALL

		*!*			this.Parent.TExt1.Value =0
		*!*			this.Parent.TExt2.Value =0
		*!*			this.Parent.TExt3.Value =0
		*!*			this.Parent.TExt4.Value =''


		** PAULO DEVIDE 12/08/2014 ****
		*>>>>>>>>>>thisform.objTelaPai.preenche_obs_pack()
		thisform.preenche_obs_pack()
		*******************************

		thisform.atualiza_qtd_caixa()
		
		RETURN .T.

	ENDPROC
	
	PROCEDURE atualiza_qtd_caixa
		lnArea = SELECT()
		SELECT v_compras_01_produtos
		GO top
		
		lnQtd = 0
		SCAN
			lnQtd = lnQtd + v_compras_01_produtos.QTDE_ORIGINAL
		ENDSCAN
		
		IF V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde > 0
			
			lnTotalCaixas = (lnQtd / V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde)
			SELECT v_compras_01
			replace v_compras_01.ERP_TOTAL_CAIXAS_ORIGINAL WITH lnTotalCaixas
			replace v_compras_01.ERP_PERCENT_DISTRIB WITH 100.000000
			replace v_compras_01.ERP_TOTAL_QTD_DISTRIB WITH lnTotalCaixas
			
		ENDIF
		
		SELECT v_compras_01_produtos
		GO top
		SELECT (lnArea)
	ENDPROC
		
ENDDEFINE

***
* Pesquisa de Produtos
*/
DEFINE CLASS Tpesqproduto AS form

	Height = 350
	Width = 473
	ShowWindow = 1
	ShowTips = .T.
	AutoCenter = .T.
	Caption = "Pesquisa de Produtos"
	KeyPreview = .T.
	WindowType = 1
	AlwaysOnTop = .T.
	Minbutton = .f.
	Maxbutton = .f.
	borderstyle = 1
	Name = "frmPesquisaProduto"


	ADD OBJECT optiongroup1 AS optiongroup WITH ;
		AutoSize = .T., ;
		ButtonCount = 2, ;
		Value = 1, ;
		Height = 46, ;
		Left = 14, ;
		Top = 25, ;
		Width = 84, ;
		Name = "Optiongroup1", ;
		Option1.Caption = "C�digo", ;
		Option1.Value = 1, ;
		Option1.Height = 17, ;
		Option1.Left = 5, ;
		Option1.Top = 5, ;
		Option1.Width = 61, ;
		Option1.Name = "Option1", ;
		Option2.Caption = "Descri��o", ;
		Option2.Height = 17, ;
		Option2.Left = 5, ;
		Option2.Top = 24, ;
		Option2.Width = 74, ;
		Option2.AutoSize = .T., ;
		Option2.Name = "Option2"


	ADD OBJECT label1 AS label WITH ;
		AutoSize = .T., ;
		Caption = "Pesquisar por:", ;
		Height = 17, ;
		Left = 14, ;
		Top = 5, ;
		Width = 83, ;
		Name = "Label1"


	ADD OBJECT text1 AS textbox WITH ;
		Height = 23, ;
		Left = 108, ;
		Top = 25, ;
		Width = 337, ;
		Name = "Text1", ;
		ControlSource = "vPRODUTO.PRODUTO"


	ADD OBJECT grid1 AS grid WITH ;
		ColumnCount = 2, ;
		DeleteMark = .F., ;
		GridLines = 2, ;
		Height = 236, ;
		Left = 12, ;
		Panel = 1, ;
		ReadOnly = .T., ;
		RecordSource = "vGridProdutos", ;
		Top = 78, ;
		Width = 456, ;
		GridLineColor = RGB(192,192,192), ;
		HighlightBackColor = RGB(255,255,128), ;
		HighlightForeColor = RGB(0,0,0), ;
		HighlightStyle = 1, ;
		Name = "Grid1", ;
		Column1.ControlSource = "vGridProdutos.PRODUTO", ;
		Column1.ReadOnly = .T., ;
		Column1.Name = "Column1", ;
		Column2.ControlSource = "vGridProdutos.DESC_PRODUTO", ;
		Column2.Width = 347, ;
		Column2.ReadOnly = .T., ;
		Column2.Name = "Column2"


	PROCEDURE grid1.init		
		this.column1.header1.caption = "C�digo"
		this.column2.header1.caption = "Descri��o do Produto"
	ENDPROC


	ADD OBJECT command1 AS commandbutton WITH ;
		Top = 25, ;
		Left = 445, ;
		Height = 23, ;
		Width = 23, ;
		Picture = "..\linx_sql_8\linx\exclusivos\lupa.gif", ;
		Caption = "", ;
		Name = "Command1"


	ADD OBJECT lblmensagem AS label WITH ;
		AutoSize = .T., ;
		FontBold = .T., ;
		Caption = "Retornou 0 registros.", ;
		Height = 17, ;
		Left = 108, ;
		Top = 54, ;
		Width = 122, ;
		ForeColor = RGB(255,0,0), ;
		Name = "lblMensagem"


	ADD OBJECT command2 AS commandbutton WITH ;
		Top = 48, ;
		Left = 416, ;
		Height = 27, ;
		Width = 52, ;
		Caption = "Limpar", ;
		Name = "Command2"


	ADD OBJECT btnselecionar AS commandbutton WITH ;
		Top = 319, ;
		Left = 398, ;
		Height = 27, ;
		Width = 72, ;
		Caption = "Selecionar", ;
		Name = "btnSelecionar"


	PROCEDURE pesquisa
		SET SAFETY OFF
		lcTexto = ALLTRIM(ThisForm.Text1.Value)

		IF !("%" $ lcTexto)
			thisform.text1.value = ALLTRIM(ThisForm.Text1.Value)+"%"
			lcTexto = ALLTRIM(ThisForm.Text1.Value)
		ENDIF

		IF ThisForm.Optiongroup1.Value = 1
			lcWhere = " PRODUTO LIKE '"+lcTexto+"'"
		ELSE
			lcWhere = " DESC_PRODUTO LIKE '"+lcTexto+"'"
		ENDIF

		TEXT TO lcSQL NOSHOW TEXTMERGE
			SELECT PRODUTO, DESC_PRODUTO, INATIVO 
			FROM PRODUTOS 
			WHERE <<lcWhere>>
		ENDTEXT

		f_select(lcSQL,"tmpProduto1")


		SELECT vGridProdutos
		ZAP
		APPEND FROM DBF("tmpProduto1")
		GO TOP
		ThisForm.lblMensagem.Caption = "Retornou "+LTRIM(TRANSFORM(RECCOUNT("vGridProdutos"),"9,999,999"))+" registros."
	ENDPROC


	PROCEDURE tecla_grid
		LPARAMETERS nKeyCode, nShiftAltCtrl
		IF nKeyCode=13
			thisform.fechar(13)
		ENDIF
		IF nKeyCode=27
			thisform.fechar(27)
		ENDIF
	ENDPROC


	PROCEDURE fechar
		LPARAMETERS nKeyCode
		IF nKeyCode=13 && ENTER
			SELECT vPRODUTO
			IF RECCOUNT("vPRODUTO")=0
				APPEND BLANK
			ENDIF
			REPLACE PRODUTO WITH vGridProdutos.PRODUTO

			***
			* carrega dados no combobox de sele��o de pack
			*/
			SET SAFETY off
			SELECT vCboPack
			ZAP
			
			TEXT TO lcSQL NOSHOW TEXTMERGE
				SELECT distinct PACK AS CODIGO_PACK 
				FROM PRODUTOS_PACKS_PERMITIDOS 
				WHERE PRODUTO = '<<ALLTRIM(vPRODUTO.PRODUTO)>>'
			ENDTEXT
			F_SELECT(lcSQL,"tmpPackProduto1")
			
			SELECT vCboPack
			APPEND FROM DBF("tmpPackProduto1")			
			GO top
			REPLACE vPRODUTO.CODIGO_PACK WITH vCboPack.CODIGO_PACK 

		ENDIF
		Thisform.Release
	ENDPROC


	PROCEDURE duplo_clique

		thisform.fechar(13)
	ENDPROC


	PROCEDURE Load

		CREATE CURSOR vGridProdutos ( ;
		PRODUTO C(12) NULL ,;
		DESC_PRODUTO C(40) NULL ,;
		INATIVO L )

	ENDPROC


	PROCEDURE Init
		
		FOR EACH loColumn IN ThisForm.Grid1.Columns
			BINDEVENT(loColumn.text1,"Keypress",;
			THIS,"tecla_grid")
		ENDFOR

		FOR EACH loColumn IN ThisForm.Grid1.Columns
			BINDEVENT(loColumn.text1,"DblClick",;
			THIS,"duplo_clique")
		ENDFOR
		
		IF !EMPTY(vPRODUTO.PRODUTO)
			thisform.pesquisa()
		ENDIF
		
	ENDPROC


	PROCEDURE text1.KeyPress
		LPARAMETERS nKeyCode, nShiftAltCtrl
		IF nKeyCode = 13
			thisform.pesquisa()
		ENDIF

	ENDPROC


	PROCEDURE command1.Click
		THISFORM.pesquisa()
		thisform.Refresh
	ENDPROC


	PROCEDURE command2.Click
		ThisForm.Text1.Value = ""

		SELECT vGridProdutos
		ZAP

		ThisForm.lblMensagem.Caption = "Retornou "+LTRIM(TRANSFORM(RECCOUNT("vGridProdutos"),"9,999,999"))+" registros."

		thisform.Refresh
	ENDPROC


	PROCEDURE btnselecionar.Click

		Thisform.fechar(13)
	ENDPROC


ENDDEFINE
*
*-- EndDefine: pesqproduto
**************************************************

***
* Tela para pegar a senha para liberar o pedido
* Retorna a vari�vel glSenha preenchida
* PAULO DEVIDE - 27/08/16
*/
DEFINE CLASS tsenhapedido AS form


	BorderStyle = 1
	Height = 108
	Width = 289
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Permiss�o para alterar pedido"
	ControlBox = .F.
	WindowType = 1
	senha = ""
	Name = "tsenhapedido"


	ADD OBJECT label1 AS label WITH ;
		AutoSize = .T., ;
		Caption = "Digite a senha:", ;
		Height = 17, ;
		Left = 12, ;
		Top = 24, ;
		Width = 85, ;
		Name = "Label1"


	ADD OBJECT text1 AS textbox WITH ;
		ControlSource = "thisform.senha", ;
		Format = "!", ;
		Height = 23, ;
		Left = 109, ;
		MaxLength = 15, ;
		Top = 24, ;
		Width = 134, ;
		PasswordChar = "*" ,;
		Name = "Text1"


	ADD OBJECT command1 AS commandbutton WITH ;
		Top = 72, ;
		Left = 110, ;
		Height = 27, ;
		Width = 84, ;
		Caption = "Cancel", ;
		Name = "Command1"


	ADD OBJECT command2 AS commandbutton WITH ;
		Top = 72, ;
		Left = 195, ;
		Height = 27, ;
		Width = 84, ;
		Caption = "OK", ;
		Name = "Command2"


	PROCEDURE Init
		thisform.senha = SPACE(15)
	ENDPROC

	PROCEDURE command1.Click
		thisform.senha = ""
		glSenha = ""
		thisform.Release
	ENDPROC


	PROCEDURE command2.Click
		glSenha = ALLTRIM(thisform.senha)
		thisform.Release
	ENDPROC


ENDDEFINE

***
* Listbox de valida��es de campos
*/
DEFINE CLASS lista_erro as ListBox
	Height = 160
	Left = 19
	Top = 30
	Width = 635
	Name = "lista_erro"
	
	PROCEDURE init
		this.Clear		
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE refresh
		** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
ENDDEFINE

DEFINE CLASS label_erro as label
	Height = 20
	Left = 19
	Top = 10
	Width = 200
	Name = "label_erro"
	Caption = "Lista de Erros"
	BackStyle = 0 
	FontBold = .T.
ENDDEFINE

***
* Listbox de valida��es de metricas
*/
DEFINE CLASS lista_metrica as ListBox
	Height = 200
	Left = 19
	Top = 215
	Width = 635
	Name = "lista_metrica"
	
	PROCEDURE init
		this.Clear		
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE refresh
		** Inclus�o/Altera��o/Exclus�o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
ENDDEFINE

DEFINE CLASS label_metrica as label
	Height = 20
	Left = 19
	Top = 195
	Width = 200
	Name = "label_erro"
	Caption = "Lista M�tricas com Erros"
	BackStyle = 0 
	FontBold = .T.
ENDDEFINE


***
* Tela para informar o motivo da altera��o
* da data de entrega
*/
DEFINE CLASS frmmotivo AS form

	Height = 130
	Width = 310
	ShowWindow = 1
	ShowTips = .T.
	AutoCenter = .T.
	Caption = "Motivo da altera��o"
	ControlBox = .F.
	WindowType = 1
	AlwaysOnTop = .T.
	Name = "frmmotivo"


	ADD OBJECT label1 AS label WITH ;
		AutoSize = .T., ;
		FontBold = .T., ;
		BackStyle = 0, ;
		Caption = "Informe o motivo", ;
		Height = 17, ;
		Left = 12, ;
		Top = 8, ;
		Width = 97, ;
		Name = "Label1"


	ADD OBJECT cbomotivo AS combobox WITH ;
		RowSourceType = 1, ;
		RowSource = "ALTERA��O DE COMPRAS,ALTERA��O DO FORNECEDOR", ;
		Height = 24, ;
		Left = 12, ;
		SpecialEffect = 1, ;
		Style = 2, ;
		Top = 32, ;
		Width = 288, ;
		Name = "cboMotivo"


	ADD OBJECT btnok AS commandbutton WITH ;
		Top = 96, ;
		Left = 216, ;
		Height = 27, ;
		Width = 84, ;
		Caption = "OK", ;
		Name = "btnOk"


	PROCEDURE gravarmotivo

			xmot = ALLTRIM(thisform.cboMotivo.value)
			f_insert("insert into CAEDU_COMPRAS_ENTREGA_LOG (PEDIDO, DATA_ALTERACAO_ENTREGA, DATA_ENTREGA, DATA_ENTREGA_NOVA, MOTIVO, USUARIO ) "+;
				" values (?V_COMPRAS_01.PEDIDO, getdate(), ?x_entreg_atu.entrega , ?v_compras_01_produtos.entrega, ?xmot, ?wusuario )")

			=REQUERY('V_CAEDU_LOG_ENTRADA')

	ENDPROC


	PROCEDURE btnok.Valid
		IF EMPTY(ThisForm.cboMotivo.Value)
			MESSAGEBOX("Informe um motivo!", 64, "Aviso")
			RETURN .f.
		ELSE
			thisform.gravarmotivo()
		ENDIF
		thisform.Release

	ENDPROC

ENDDEFINE

****
* CLASSE DE FUN��ES DE VALIDA��O
* DE M�TRICAS DEFINIDAS DO PEDIDO
*/
DEFINE CLASS funcoes_metricas AS custom
	***
	* Declara e inicia propriedades 
	* desta classe
	*/
	retorno = .f.
	err_message = ""
	metrica_erro = ""
	pedidoId = ""
	produtoId = ""
	custoOriginal = 0.000000
	vendaOriginal = 0.000000
	custoInformado =  0.000000
	margemCalculada = 0.000000
	oLista = .f.
	valorempenho = 0.00 && propriedade para armazenar o valor empenhado do pedido do Saldo de Verbas de OTB
	dataEntregaInformada = {} 
	metricaId = ""
	
	Name = "funcoes_metricas"
	
	PROCEDURE init
		PARAMETERS _oLista && recebe o Listbox de parametro
		IF PARAMETERS()>0
			this.oLista = _oLista
		ENDIF
			
	ENDPROC
	
	***
	* Procedure para chamar os m�todos conforme parametro passado
	*/
	PROCEDURE executa
		LPARAMETERS lcMetrica
		
		this.metricaId = lcMetrica
		
		DO CASE
		CASE lcMetrica = "01" && ALTERA��O DE QUANTIDADE
			this.retorno = this.VALIDA_METRICA_01()
		
		CASE lcMetrica = "02" && ALTERA��O DE VALOR
			this.retorno = this.VALIDA_METRICA_02()
		
		CASE lcMetrica = "03" && ALTERA��O DE CUSTO
			this.retorno = this.VALIDA_METRICA_03()
		
		CASE lcMetrica = "04" && DATA DE LIMITE DE ENTREGA
			this.retorno = this.VALIDA_METRICA_04()
		
		CASE lcMetrica = "05" && MARGEM DO PEDIDO
			this.retorno = this.VALIDA_METRICA_05()
		
		CASE lcMetrica = "06" && CONDI��O DE PAGAMENTO
			this.retorno = this.VALIDA_METRICA_06()
		
		CASE lcMetrica = "07" && SALDO OTB NACIONAL
			this.retorno = this.VALIDA_METRICA_07()

		ENDCASE
	ENDPROC
	
	PROCEDURE add_lista
		LPARAMETERS lcMsg, blnLimparLista
		IF PARAMETERS()=1
			blnLimparLista = .f.
		ENDIF
		ADICIONA_ERRO(this.oLista, lcMsg, blnLimparLista)
	ENDPROC
	
	***
	* VERIFICA SE O REGISTRO DA TABELA PAI EXISTE
	* CASO NECESS�RIO, ADICIONA
	* PAULO DEVIDE - ALTERA��O EM 16-01-17 ==> INCLUSAO DE PARAMETRO NA CLAUSULA WHERE and PRODUTO = '<<vPRODUTO.PRODUTO>>'
	*/
	PROCEDURE ADICIONA_CABECALHO_LOG
		
		this.pedidoId = v_compras_01.PEDIDO
		TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
			select * 
			from CAEDU_LOG_AUTORIZA_COMPRAS 
			WHERE PEDIDO='<<this.pedidoId>>' and PRODUTO = '<<vPRODUTO.PRODUTO>>'
		ENDTEXT
		
		F_SELECT(lcSQL, "vLogPedido")
		IF RECCOUNT("vLogPedido")=0

			SELECT distinct PRODUTO ;
			FROM v_compras_01_produtos WITH (BUFFERING = .T.) ;
			INTO ARRAY laProdutos1
			
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS
			FOR ixx=1 TO ALEN(laProdutos1,1)
				APPEND BLANK
				REPLACE PEDIDO WITH v_compras_01.PEDIDO
				REPLACE PRODUTO WITH laProdutos1[ixx]
				REPLACE DATA_LOG WITH DATE()
				REPLACE STATUS_PEDIDO WITH 3 && AGUARDANDO APROVA��O
			ENDFOR
			
						
		ELSE && Carrega o(s) registro(s) lido(s)
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS
			APPEND FROM DBF("vLogPedido")
			GO TOP
		ENDIF

	ENDPROC
	
	PROCEDURE ADICIONA_ITEM_LOG
		LPARAMETERS tcPedido, tcProduto, tcCorProduto, tcCodMetrica, ;
						tcValorAntes, tcValorDepois, tcObs
		LOCAL lnArea
		lnArea = SELECT()
		
		SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM 
		APPEND BLANK
		REPLACE PEDIDO WITH tcPedido
		REPLACE PRODUTO WITH tcProduto
		REPLACE COR_PRODUTO WITH tcCorProduto
		REPLACE COD_METRICA WITH tcCodMetrica
		REPLACE DATA_LOG WITH DATETIME()
		REPLACE TIPO_OP WITH o_004006.p_Tool_Status
		REPLACE VALOR_ANTES WITH tcValorAntes
		REPLACE VALOR_DEPOIS WITH tcValorDepois
		REPLACE APROVADO WITH .F.
		REPLACE USUARIO_PEDIDO WITH WUSUARIO
		REPLACE USUARIO_APROVADOR WITH NULL
		REPLACE OBS WITH tcObs
		
		SELECT (lnArea)
	ENDPROC
	

	***
	* VALIDA��O M�TRICA DE ALTERA��O DE QUANTIDADE
	*/
	PROCEDURE VALIDA_METRICA_01
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA��O M�TRICA DE ALTERA��O DE VALOR
	*/
	PROCEDURE VALIDA_METRICA_02
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA��O M�TRICA DE ALTERA��O DE CUSTO
	*/
	PROCEDURE VALIDA_METRICA_03
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA��O M�TRICA DE DATA DE LIMITE DE ENTREGA
	*/
	PROCEDURE VALIDA_METRICA_04
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		llCancela = (RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0) && se .T. deixa passar direto
		IF llCancela
			RETURN .t.
		ENDIF

		this.dataEntregaInformada = o_004006.px_entrega.Value

		SELECT v_Compras_01_Produtos
		GO TOP

		lc_pedido = ALLTRIM(v_Compras_01_Produtos.pedido)
		ld_limite_entrega = DTOC(v_Compras_01_Produtos.limite_entrega,1)
		TEXT TO lcsql noshow
		    select pedido, LIMITE_ENTREGA, DATEPART( wk , LIMITE_ENTREGA ) as semana,
		       ENTREGA,  DATEPART( wk , getdate() ) as semana_atual
			from
			COMPRAS_PRODUTO
			where pedido like ?lc_pedido
		ENDTEXT

		IF USED("x_entreg_atu")
			USE IN x_entreg_atu
		ENDIF
		f_select(lcsql,'x_entreg_atu')

		IF RECCOUNT("x_entreg_atu")  = 0 OR;
				f_vazio(x_entreg_atu.entrega)
			RETURN .T.
		ENDIF

		IF this.dataEntregaInformada <> TTOD(x_entreg_atu.entrega)
			frm = CREATEOBJECT("frmmotivo")
			frm.show(1)	
		ENDIF

		IF TTOD(x_entreg_atu.limite_entrega) != v_Compras_01_Produtos.limite_entrega
			LC_DATA_INI = DTOC(TTOD(x_entreg_atu.limite_entrega),1)
			LC_DATA_FIM = DTOC(DATETIME(),1)

			XWK_ENTEGA =  IIF( YEAR(x_entreg_atu.limite_entrega) > YEAR(DATE()), WEEK(TTOD(x_entreg_atu.limite_entrega)) +50 ,WEEK(TTOD(x_entreg_atu.limite_entrega)))

			XWK_ATUAL = WEEK(DATE( ))
			WKDIFF = XWK_ENTEGA - XWK_ATUAL
			ld_limite_entrega = DTOC(v_Compras_01_Produtos.limite_entrega,1)
			IF USED("x_entreg_new")
				USE IN x_entreg_new
			ENDIF

			TEXT TO lcsql noshow
				select  DATEDIFF ( wk , ?LC_DATA_FIM,  ?LC_DATA_INI )  as wk_dif
			ENDTEXT
			f_select(lcsql,'x_entreg_new')

			DO CASE
				CASE WKDIFF  <= 2 && 0

					tcValorAntes = DTOC(x_entreg_atu.entrega)
					tcValorDepois = DTOC(v_Compras_01_Produtos.entrega)
					this.metrica_erro = "Data de Entrega foi alterada de => "+tcValorAntes+" para => "+tcValorDepois
					SELECT v_compras_01_produtos
					GO top

					this.add_lista(this.metrica_erro)
					
					this.ADICIONA_ITEM_LOG(v_compras_01.PEDIDO, v_compras_01_produtos.produto, v_compras_01_produtos.cor_produto, ;
											"04", tcValorAntes, tcValorDepois, this.metrica_erro)
					llRetorno = .F.


					lcsql = ""
					lc_usuario = "Gerente Compras" && cursor aberto e usuario do diretor autenticado
					TEXT TO lcsql noshow
						INSERT INTO trigger_portal
						(id,login,pedido,entrega_antiga,entrega_nova,limite_entrega_antiga,	limite_entrega_nova,data_alteracao ,user_senha,	cargo_senha)
						VALUES	((select MAX(id)+1 from trigger_portal), ?wusuario, ?x_entreg_atu.pedido, ?x_entreg_atu.entrega, ?v_compras_01_produtos.entrega,
						  ?x_entreg_atu.limite_entrega, ?v_compras_01_produtos.limite_entrega, getdate(), ?lc_usuario, 'DIRETOR')
					ENDTEXT
					F_INSERT(lcsql)
					** (fim) PAULO DEVIDE --> 13-NOV-14


			ENDCASE


		ENDIF
		
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA��O M�TRICA DE MARGEM DE LUCRO SOBRE PRE�OS
	*/
	PROCEDURE VALIDA_METRICA_05
		LOCAL llRetorno as Boolean
		llRetorno = .T.

		IF ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,'')) = "ATACADO"
			RETURN llRetorno
		ENDIF
		
		SELECT v_compras_01_produtos
		** PAULO DEVIDE --> 28-05-2015
		DIMENSION laMargem[IIF(RECCOUNT("v_compras_01_produtos")=0,1,RECCOUNT("v_compras_01_produtos")),3]
		FOR itt=1 TO ALEN(laMargem,1)
			laMargem[itt,1]="" 			&& produto
			laMargem[itt,2]="" 			&& cor produto
			laMargem[itt,3]=0.000000 	&& Margem
		ENDFOR

		PRIVATE lnMargem, lcOrigem
		lnMargem = 0
		lcOrigem = ""
		lcMsg1 = ""

		llRetorno = .t.
		itt = 1
		SCAN

			lnPercMargem = 0
			
			** popula as propriedades custoOriginal e vendaOriginal
			this.produtoId = ALLTRIM(v_compras_01_produtos.produto)
			this.getPRECOS_PRODUTO()
			this.custoInformado = v_compras_01_produtos.CUSTO1
			
			** Calcula a margem e popula o parametro margemCalculada			
			this.margemCalculada = this.CALCULA_MARGEM_PEDIDO(this.vendaOriginal, this.custoInformado)
			lnPercMargem = this.margemCalculada
			
			** Valida a margem e retorna .T. ou .F.
			llStatus = this.validaMargem(lnPercMargem)
			
			laMargem[itt,1]=v_compras_01_produtos.produto 			&& produto
			laMargem[itt,2]=v_compras_01_produtos.cor_produto		&& cor produto
			laMargem[itt,3]=this.margemCalculada					&& Margem

			lcOrigem = IIF(this.ORIGEM_PRODUTO(this.produtoId)="N","nacional","importado")
			
			** Compara com o valor da margem gravado no item, se for igual, n�o pede a senha
			IF ( ROUND(NVL(v_compras_01_produtos.ERP_PERC_MARGEM,0.000000),6) = ROUND(lnPercMargem,6) )
				llStatus = .t.
			ENDIF

			IF !llStatus

				this.metrica_erro =	"Autoriza��o para Margem m�nima de produto "+ lcOrigem + " atingida ("+ ;
					ALLTRIM(TRANSFORM(lnPercMargem,"999,999.99"))+"%)"
				** Calcula a margem e popula o parametro margemCalculada			
				SELECT V_COMPRAS_PRODUTO_ANTES
				LOCATE FOR ALLTRIM(PRODUTO)=ALLTRIM(laMargem[itt,1]) AND ALLTRIM(COR_PRODUTO)=ALLTRIM(laMargem[itt,2])
				lnMargemAnterior = 0.000000
				IF FOUND()				
					lnMargemAnterior = this.CALCULA_MARGEM_PEDIDO(this.vendaOriginal, V_COMPRAS_PRODUTO_ANTES.custo1)
				ENDIF

				this.add_lista(this.metrica_erro)
				
				tcValorAntes = TRANSFORM(lnMargemAnterior)
				tcValorDepois = TRANSFORM(this.margemCalculada)
				
				this.ADICIONA_ITEM_LOG(v_compras_01.PEDIDO, v_compras_01_produtos.produto, v_compras_01_produtos.cor_produto, ;
										this.MetricaId, tcValorAntes, tcValorDepois, this.metrica_erro)

				llRetorno=.F.
			ENDIF

			SELECT v_compras_01_produtos
			itt = itt + 1

		ENDSCAN
		
		
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA��O M�TRICA DE CONDI��O DE PAGAMENTO
	*/
	PROCEDURE VALIDA_METRICA_06
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		IF o_004006.p_Tool_Status="I"
			RETURN llRetorno
		ENDIF
		
		IF o_004006.CONDICAO_PGTO_ANTES <> v_compras_01.condicao_pgto

				tcValorAntes = o_004006.CONDICAO_PGTO_ANTES
				tcValorDepois = v_compras_01.condicao_pgto
				this.metrica_erro = "Condi��o de Pagamento foi alterada de => "+tcValorAntes+" para => "+tcValorDepois
				SELECT v_compras_01_produtos
				GO top

				this.add_lista(this.metrica_erro)
				
				this.ADICIONA_ITEM_LOG(v_compras_01.PEDIDO, v_compras_01_produtos.produto, v_compras_01_produtos.cor_produto, ;
										this.metricaId, tcValorAntes, tcValorDepois, this.metrica_erro)
				llRetorno = .F.
		ENDIF
		
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA��O M�TRICA DE SALDO OTB NACIONAL
	*/
	PROCEDURE VALIDA_METRICA_07
		LOCAL llRetorno as Boolean
		llRetorno = .T.

		IF INLIST(o_004006.p_Tool_Status,'I','A') ;
			AND !ZORIGEM_PEDIDO_IMPORTADO() AND ;
				ALLTRIM(V_COMPRAS_01.erp_cups_segmento) = 'VAREJO'
			
			IF NOT This.verifica_verba_OTB()

				llRetorno = .F.

			ENDIF
			
		ENDIF
		


		RETURN llRetorno
	ENDPROC

	***
	* Calcula a Margem e retorna o valor da margem
	*/
	PROCEDURE CALCULA_MARGEM_PEDIDO
		PARAMETERS lnPrecoVenda, lnCustoInformado
		LOCAL lnMargem as Decimal
		IF lnPrecoVenda = 0 && tratamento para n�o dar divis�o por Zero
			lnMargem = 0
		ELSE
			lnMargem = ((lnPrecoVenda - lnCustoInformado)/lnPrecoVenda) * 100
		ENDIF
		RETURN lnMargem
	ENDPROC

	PROCEDURE getPRECOS_PRODUTO	
		LOCAL lnArea
		lnArea = SELECT()
		** RESET nos pre�os
		this.custoOriginal = 0.00
		this.vendaOriginal = 0.00
		
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
			AND PRODUTOS_PRECOS.PRODUTO = '<<this.produtoId>>'
		ENDTEXT

		f_select(lcSQL,"tmpMargem")
		SELECT tmpMargem
		** pega o pre�o de custo
		LOCATE FOR CODIGO_TAB_PRECO = "00"
		IF FOUND()
			this.custoOriginal = tmpMargem.PRECO1
		ENDIF
		** pega o pre�o de venda
		LOCATE FOR CODIGO_TAB_PRECO = "01"
		IF FOUND()
			this.vendaOriginal = tmpMargem.PRECO1
		ENDIF
		
		SELECT (lnArea)
	ENDPROC

	***
	* Origem do Produto 
	* Retorna Char(1) ==> N para nacional ou I para importado
	*/	
	PROCEDURE ORIGEM_PRODUTO
		PARAMETERS tcProduto
		LOCAL lcOrigem as String, lnArea as Integer
		lcOrigem = "N" && default
		lnArea = SELECT()
		F_SELECT("SELECT TRIBUT_ORIGEM FROM PRODUTOS WHERE PRODUTO = '"+;
					ALLTRIM(tcProduto)+"'","tmpTributOrigem")

		IF INLIST(ALLTRIM(NVL(tmpTributOrigem.TRIBUT_ORIGEM,"")),"1","2","6","7")
			lcOrigem = "I" && produto importado
		ENDIF
		
		SELECT (lnArea)
		
		RETURN lcOrigem
	ENDPROC

	PROCEDURE validaMargem
		LPARAMETERS lnMargem
		LOCAL lnArea, llStatus1
		lnArea = SELECT()
		
		llStatus1 = .T.
		IF (this.ORIGEM_PRODUTO(this.produtoId)="N") && Nacional = 51% (margem minima)

			IF lnMargem < o_004006.pp_palma_margem_minima_nac
				llStatus1 = .f.
			ENDIF
			
		ELSE && importado = 62% (margem minima)
							
			IF lnMargem < o_004006.pp_palma_margem_minima_imp
				llStatus1 = .f.
			ENDIF

		ENDIF
		SELECT (lnArea)
		RETURN llStatus1		
	ENDPROC

	****
	* Verifica se ha saldo para griffe, linha, grupo e subgrupo no ano/M�s do Limite de Entrega do pedido 
	* Tabela Caedu_verba_compras - atualizada diariamente pelo Ensemble
	* Paulo Devid� - 30-11-2015
	*/
	procedure verifica_verba_OTB
		LOCAL lnArea as Integer, llRet as Boolean

		llRet = .t.
		lnArea = SELECT()

		SELECT ;
			PRODUTO,;
			MAX(LIMITE_ENTREGA) AS LIMITE_ENTREGA, ;
			SUM(VALOR_ORIGINAL) AS VALOR_ORIGINAL, ;
			SUM(NVL(ERP_VERBAS_EMPENHO,0)) AS ERP_VERBAS_EMPENHO, ;
			MAX(NVL(ERP_VERBAS_DATA_EMPENHO,{})) AS ERP_VERBAS_DATA_EMPENHO, ;
			MAX(CAST(NVL(ERP_VERBAS_EMPENHO_ANO_MES,0) AS NUMERIC(6,0))) AS ERP_VERBAS_EMPENHO_ANO_MES, ;
			.f. AS ERP_VERBAS_STATUS_PR ;
		FROM ;
			V_COMPRAS_01_PRODUTOS WITH (BUFFERING = .T.) ;
		GROUP BY ;
			PRODUTO INTO CURSOR CURVERBAS READWRITE

		SELECT CURVERBAS 
		SCAN 

			TEXT TO lcSQL NOSHOW TEXTMERGE
			select 
				CV.* 
			from 
				Caedu_verba_compras CV
			inner join
				produtos PR on (PR.GRIFFE = CV.GRIFFE) AND (PR.LINHA = CV.LINHA) 
								AND (PR.GRUPO_PRODUTO = CV.grupo) AND (PR.SUBGRUPO_PRODUTO = CV.SUBGRUPO)
			WHERE (PR.PRODUTO = '<<ALLTRIM(CURVERBAS.produto)>>' ) AND (CV.mes = <<LEFT(DTOS(CURVERBAS.LIMITE_ENTREGA),6)>>) 
			ENDTEXT

			f_select(lcSQL,"curVerbas_OTB")
			
			IF RECCOUNT("curVerbas_OTB")=0
				MESSAGEBOX("N�o foi localizado Verba de OTB para o produto",16,"Aviso")
				SELECT (lnArea)
				RETURN .f.
			ENDIF
			

			lnEmpenho = curVerbas_OTB.empenho 
			** verifica se houve uma ocorr�ncia de altera��o de pedido no mesmo dia, ent�o estorna o saldo e coloca a nova quantidade original
			IF (DTOS(CURVERBAS.ERP_VERBAS_DATA_EMPENHO) = DTOS(DATE())) AND (LEFT(DTOS(CURVERBAS.LIMITE_ENTREGA),6) = TRANSFORM(curVerbas_OTB.mes,"999999")) 
				lnEmpenho = lnEmpenho - CURVERBAS.ERP_VERBAS_EMPENHO && Estorna a quantidade do dia
			ENDIF

			lnEmpenho = lnEmpenho + CURVERBAS.VALOR_ORIGINAL

			lnSaldo_OTB = curVerbas_OTB.otb_nac - lnEmpenho

			llERP_VERBAS_STATUS_PR = .f.
			IF CURVERBAS.VALOR_ORIGINAL <= lnSaldo_OTB
				llERP_VERBAS_STATUS_PR = .T.
			ENDIF

			SELECT CURVERBAS
			REPLACE ERP_VERBAS_STATUS_PR WITH llERP_VERBAS_STATUS_PR 
			REPLACE ERP_VERBAS_EMPENHO WITH CURVERBAS.VALOR_ORIGINAL
			REPLACE ERP_VERBAS_DATA_EMPENHO WITH DATE() 
			REPLACE ERP_VERBAS_EMPENHO_ANO_MES WITH CAST(LEFT(DTOS(CURVERBAS.LIMITE_ENTREGA),6) AS INT)

		ENDSCAN

		SELECT CURVERBAS
		SCAN
			IF NOT CURVERBAS.ERP_VERBAS_STATUS_PR 
				llRet = .F.
				this.valorempenho = CURVERBAS.ERP_VERBAS_EMPENHO
				***
				* preenche o listbox de m�tricas e gera o Log de Metrica
				*/
				
				tcValorAntes = ""
				tcValorDepois = TRANSFORM(this.valorempenho)
				lcMsg1 = "Saldo OTB Nacional para valida��o deste pedido � insuficiente! Saldo de Empenho = " + tcValorDepois
				
				this.metrica_erro = lcMsg1
				SELECT v_compras_01_produtos
				GO top

				this.add_lista(this.metrica_erro)
				
				this.ADICIONA_ITEM_LOG(v_compras_01.PEDIDO, v_compras_01_produtos.produto, v_compras_01_produtos.cor_produto, ;
										this.metricaId, tcValorAntes, tcValorDepois, this.metrica_erro)				
				*EXIT
			ENDIF
		ENDSCAN

		SELECT (lnArea)	
		RETURN llRet
	ENDPROC
		
ENDDEFINE
