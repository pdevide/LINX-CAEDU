******************************************************
*- Programa Base de Criação de Objeto de Entrada
********************************************************************
*- O programa deve ser texto com o nome = OBJ_xxxxxx.prg onde x=numero da tela
*- Este arquivo deve ser colocado no diretorio \Linx_sql\Linx\Exclusivos 
*******************************************************************************
*- Existem 2 parametros que influem nos objetos de Entrada:  
*  utiliza_objeto_entrada = .f. desliga os objetos de entrada para testar telas sem os mesmos
*  mostra_nome_obj = .t. mostra o nome dos objetos no tooltip em tempo de execução para facilitar o desenvolvimento
*********************************************************************************


*********************************************************************************
* - Atencao !!!!!!!!!!!														   -*
* - Toda vez que houver qualquer alteracao no PRG deve-se apagar o arquivo FXP -*
*********************************************************************************

*
*                 Abaixo segue Programa objeto sem Codigo 
*
*
*- Definindo a classe do objeto de entrada que sera criado na Form.
define class obj_entrada as custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	procedure metodo_usuario
		*- Parametros do metodo:
		*- Xmetodo= nome do metodo
		*- Xobjeto= variavel com a referencia ao objeto
		*- Xnome_obj  = nome do objeto
		lparam xmetodo, xobjeto ,xnome_obj
		
		******************** Metodos chamados pelo FORMSET
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
		*
		***************** Metodos que ocorrem dentro da Transaction do Banco de Dados
		*	USR_TRIGGER_AFTER ->Return .f. Para o Salvamento e da Rollback
		*	USR_TRIGGER_BEFORE ->Return .f. Para o Salvamento e da Rollback


		******************** Metodo chamado pelos Objetos na Validação
		*   USR_VALID -> Return .f. Não deixa o Usuario sair do objeto.

		*- Inicio dos procedimentos do Usuario
		*- Testando qual o metodo que esta chamando o metodo entrada
		
		
*!*	         A010,065, 0 , 3 , 2 , 2 , N ,"CAIXA:"
*!*	      |       |    |   |   |    |    |         |    
*!*	      |       |    |   |   |    |    |         +------>  Texto
*!*	      |       |    |   |   |    |    +-------------> 
*!*	      |       |    |   |   |    +---------------->  Espessura da fonte
*!*	      |       |    |   |   +-------------------->  Largura da fonte
*!*	      |       |    |   +----------------------->  Altura da fonte
*!*	      |       |    +-------------------------->  Rotação
*!*	      |       +------------------------------>  Linha
*!*	      +----------------------------------->  Coluna

		do case
			case UPPER(xmetodo) == 'USR_INIT'
			
			* MIT - Diana C. Figueiredo - 14/05/2012
			* Cria o objeto checkbox para identificar qual etiqueta será impressa
			With ThisFormSet.lx_Form1

					.AddObject("ck_mini_etq", "tx_check")
					.ck_mini_etq.Anchor = 0
					.ck_mini_etq.Top  = 165
					.ck_mini_etq.Left = 367
					.ck_mini_etq.width = 52
					.ck_mini_etq.Caption = 'Mini Etiqueta'
					.ck_mini_etq.Alignment = 0
					.ck_mini_etq.FontBold = .T.
					.ck_mini_etq.ForeColor = 16711680
					
					Thisformset.Refresh()

			EndWith
			
			*- metodo do inicio da form
			
			
			case UPPER(xmetodo) == 'USR_SAVE_BEFORE'
				
				*IF V_FATURAMENTO_CAIXAS_00.CAIXA_FECHADA = .t. AND UPPER(V_FATURAMENTO_CAIXAS_00.EMBALADOR) = 'AUTOMATICO'
				*IF V_FATURAMENTO_CAIXAS_00.CAIXA_FECHADA = .t. AND UPPER(V_FATURAMENTO_CAIXAS_00.EMBALADOR) = 'AUTOMATICO'
					replace V_FATURAMENTO_CAIXAS_00.EMBALADOR WITH UPPER(wusuario)
					replace V_FATURAMENTO_CAIXAS_00.DATA_EMBALAGEM WITH DATE()
				*endif
			
			
			case UPPER(xmetodo) == 'USR_SAVE_AFTER'
			
		

*!*				
*!*					xarquivo="PRINTER.TXT"
*!*					xarquivo= "c:\temp" +'\'+   xarquivo
				xalias  = ALIAS()
				
				** PAULO DEVIDE --> 16-10-2014
				* QUERY PARA PEGAR A ROTA
				F_select('select * from filiais ','FILFIL1')

				
				SELECT v_faturamento_caixas_00_embalados
				GO top

				xarquivo="PR"+ALLTRIM(V_FATURAMENTO_CAIXAS_00.CAIXA) + ".TXT"
				xarquivo= SYS(2023) +'\'+   xarquivo

				
				SELECT &xalias
				
				IF !FILE(xarquivo)
					xarq2     = FCREATE(xarquivo)
				ELSE
					DELETE FILE xarquivo
					xarq2     = FCREATE(xarquivo)	
				ENDIF
*!*					F_Select('SELECT TIPO_PRODUTO,GRIFFE,LINHA,COLECOES.COLECAO,COLECOES.DESC_COLECAO FROM PRODUTOS INNER JOIN COLECOES ON PRODUTOS.COLECAO = COLECOES.COLECAO '+;
*!*							'WHERE PRODUTO=?v_faturamento_caixas_00_embalados.produto','v_prod',ALIAS())

				F_Select('SELECT TIPO_PRODUTO,GRIFFE,LINHA,COLECOES.COLECAO,COLECOES.DESC_COLECAO, '+;
					 "case when COD_CATEGORIA = '2' THEN 'CABIDE' else '      ' end categoria "+;
					 ' FROM PRODUTOS INNER JOIN COLECOES ON PRODUTOS.COLECAO = COLECOES.COLECAO '+;
					'WHERE PRODUTO=?v_faturamento_caixas_00_embalados.produto','v_prod',ALIAS())
	
				STORE "" TO xdet
				
				** PAULO DEVIDE --> 16/10/2014
				SELECT filfil1
				LOCATE FOR filial = V_FATURAMENTO_CAIXAS_00.NOME_CLIFOR_ENTREGA
				IF FOUND()
					xx_rota = ALLTRIM(NVL(filfil1.ERP_COD_ROTA,""))+"-"+RIGHT(ALLTRIM(filfil1.cod_filial),3)
				ELSE
					xx_rota = "N/D" && não encontrou a filial
				ENDIF
				** PAULO DEVIDE --> 16/10/2014
				
				IF thisformset.lx_form1.ck_mini_etq.value = 1
					** MIT - Se o check estiver marcado imprime a etiqueta pequena
					xCtrlB  = ''	
					xCtrlN  = 'N'
					xCtrlZB = 'ZB'
					xCtrlRB = 'R050,0'
					xini    = xCtrlB + chr(13) + chr(10) + xCtrlN + chr(13) + chr(10) + xCtrlZB + chr(13) + chr(10) + xCtrlRB + chr(13) + chr(10)
******* comentado por PAULO DEVIDE --> 16/10/2014
*!*	*!*						xA1 = 'A000,010,0,2,1,2,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.NOME_CLIFOR_ENTREGA) + '"'+ chr(13) + chr(10)
*!*	*!*						xA2 = 'A000,045,0,2,1,2,N,"'+ALLTRIM(v_prod.GRIFFE) + '"'+ chr(13) + chr(10)
*!*	*!*						xA3 = 'A000,080,0,2,1,2,N,"'+ALLTRIM(v_prod.LINHA) + '"'+ chr(13) + chr(10)
*!*	*!*						xA4 = 'A000,110,0,2,2,2,N,"'+IIF(f_vazio(v_prod.DESC_COLECAO),'COLEÇÃO '+ALLTRIM(v_prod.COLECAO),SUBSTR(ALLTRIM(v_prod.DESC_COLECAO),1,30)) + '"'+ chr(13) + chr(10)
*!*	*!*						xA5 = 'B200,002,0,1,3,5,110,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.CAIXA)+ '"'+ chr(13) + chr(10)
*!*	*!*						xA6 = 'A200,118,0,3,2,1,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.CAIXA) + '"'+ chr(13) + chr(10)
*!*	*!*						***xA7 = 'A380,118,0,1,1,1,N,"N.Pack/Caixa'+ '"'+ chr(13) + chr(10)
*!*	*!*						xA7 = 'A400,118,0,1,1,1,N,"'+ LEFT(ALLTRIM(v_prod.categoria),6)+ '"'+ chr(13) + chr(10)
*!*	*!*						xA8 = 'A605,005,0,3,2,3,N,"QTD'+ '"'+ chr(13) + chr(10)
*!*	*!*						xA9 = 'A620,060,0,3,2,3,N,"'+ALLTRIM(STR(v_faturamento_caixas_00.qtde_caixa,5))+ '"'+ chr(13) + chr(10)
*!*	*!*						xA10= 'A600,115,0,2,1,1,N,"CD CAEDU'+ '"'+ chr(13) + chr(10)
*!*	*!*						xA11= 'P1'
******* comentado por PAULO DEVIDE --> 16/10/2014					
						xA0 = 'A000,010,0,2,1,2,N,"'+ [P: ]+ '"'+ chr(13) + chr(10) && SEM PEDIDOS --> pedido em Branco
						xA1= 'A480,010,0,3,2,3,N," '+ xx_rota+ '"'+ chr(13) + chr(10)

						xA2 = 'A000,045,0,2,1,2,N,"'+ALLTRIM(v_prod.GRIFFE) + '"'+ chr(13) + chr(10)
						xA3 = 'A000,080,0,2,1,2,N,"'+ALLTRIM(v_prod.LINHA) + '"'+ chr(13) + chr(10)
						xA4 = 'A000,110,0,2,1,2,N,"'+IIF(f_vazio(v_prod.DESC_COLECAO),'COLEÇÃO '+ALLTRIM(v_prod.COLECAO),SUBSTR(ALLTRIM(v_prod.DESC_COLECAO),1,30)) + '"'+ chr(13) + chr(10)
						xA5 = 'B200,002,0,1,3,5,110,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.CAIXA)+ '"'+ chr(13) + chr(10)
						xA6 = 'A200,118,0,3,2,1,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.CAIXA) + '"'+ chr(13) + chr(10)
						
						xA7 = 'A400,118,0,1,1,1,N,"'+ LEFT(ALLTRIM(v_prod.categoria),6)+ '"'+ chr(13) + chr(10)
						xA8 = "" &&'A605,005,0,3,2,3,N,"QTD'+ '"' + chr(13) + chr(10)
						xA9 = 'A500,075,0,2,1,2,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.NOME_CLIFOR_ENTREGA) + '"'+ chr(13) + chr(10)

						xA10 = 'A520,115,0,3,2,1,N,"'+"QTD. "+ALLTRIM(STR(v_faturamento_caixas_00.qtde_caixa,5))+ '"'+ chr(13) + chr(10)

						xA11= 'P1'
						x_Allegro = xini+xA0+xA1+xA2+xA3+xA4+xA5+xA6+xA7+xA8+xA9+xA10+xA11
					
					
				
				ELSE
					
					xCtrlB  = ''	
					xCtrlN  = 'N'
					xCtrlZB = 'ZB'
					xCtrlRB = 'R080,0'
					xini    = xCtrlB + chr(13) + chr(10) + xCtrlN + chr(13) + chr(10) + xCtrlZB + chr(13) + chr(10) + xCtrlRB + chr(13) + chr(10)
					xA1 = 'A000,020,0,3,2,4,N,"'+ALLTRIM(v_prod.GRIFFE) + '"'+ chr(13) + chr(10)
					xA2 = 'A000,100,0,3,2,4,N,"CAIXA:'+ '"'+ chr(13) + chr(10)
					xA3 = 'A000,175,0,3,2,4,N,"'+ALLTRIM(v_prod.TIPO_PRODUTO) + '"'+ chr(13) + chr(10)
					xA4 = 'A000,250,0,2,2,2,N,"REMETENTE:'+ '"'+ + chr(13) + chr(10)
					xA5 = 'A000,290,0,3,2,3,N,"CENTRO DE DISTRIBUICAO'+ '"'+ chr(13) + chr(10)
					xA6 = 'A000,360,0,2,2,2,N,"DESTINATARIO:' + '"'+ chr(13) + chr(10)
					xA7 = 'A000,415,0,4,2,4,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.NOME_CLIFOR_ENTREGA) + '"'+ chr(13) + chr(10)
					xA8 = 'A000,530,0,2,2,4,N,"QUANTIDADE:'+ '"'+ chr(13) + chr(10)
					xA9 = 'A260,530,0,2,2,4,N,"'+STR(v_faturamento_caixas_00.qtde_caixa,5)+' PCS'+ '"'+ chr(13) + chr(10)
					xA10= 'B500,070,0,1,2,4,85,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.CAIXA)+ '"'+ chr(13) + chr(10)
					xA11= 'A510,165,0,3,2,4,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.CAIXA) + '"'+ chr(13) + chr(10)
					xA12= 'A000,300,0,2,1,2,N," "'+ chr(13) + chr(10)
					xA13= 'A000,610,0,4,2,4,N,"'+ALLTRIM(V_FATURAMENTO_CAIXAS_00.EMBALADOR)+ '"'+ chr(13) + chr(10)
					xA14= 'P1'
					x_Allegro = xini+xA1+xA2+xA3+xA4+xA5+xA6+xA7+xA8+xA9+xA10+xA11+xA12+xA13+xA14
				ENDIF 
				
				xdet = x_Allegro  
				=FPUTS(xarq2,xdet)
				=FCLOSE(xarq2) 
*!*					SET DEVICE TO print
*!*					SET PRINTER TO LPT1
				
				
				
*!*	SET CONSOLE OFF

*!*	SET PRINTER TO name "ZDesigner GK420t (EPL)"

*!*	SET DEVICE TO PRINTER

*!*	SET PRINTER ON
				
				
*!*					!COPY &xarquivo lpt1
*!*					SET DEVICE TO SCREEN


*************************************************************************
thisform.LockScreen = .T. 					    

F_SELECT("SELECT * FROM PARAMETROS_USERS WHERE PARAMETRO = 'PALMA_IMP_ZEBRA'","TMPUSERS")

SELECT TMPUSERS
LOCATE FOR UPPER(ALLTRIM(USUARIO)) = UPPER(ALLTRIM(WUSUARIO))

IF FOUND()
	
	strComando = "CALL C:\LINX_SQL_8\LINX\IMPZEBRA.BAT"
	RUN &strComando.
	WAIT WINDOW "Aguarde mapeando impressora..." TIMEOUT 3
	
	TYPE &xarquivo WRAP to LPT2 && PROMPT
	
ELSE
	TYPE &xarquivo WRAP to LPT1 && PROMPT
ENDIF
	

clear

DELETE FILE &xarquivo

thisform.LockScreen = .f. 	
*************************************************************************				
				
				
				
				
		otherwise
				return .t.				
		endcase
	endproc
enddefine

** MIT - Define classe para checkbox
Define Class tx_check as lx_checkbox
	Visible       = .T.
	Left 		  = 83

ENDDEFINE