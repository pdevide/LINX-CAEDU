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


		do case
		   case UPPER(xmetodo) == 'USR_INIT'
  			   
			  ***thisformset.lx_form1.addobject('bt_copia', 'bt_estfilial')
   			  thisformset.lx_FORM1.lx_pageframe1.page11.addobject('bt_prod', 'bt_produtos')
  			  thisformset.lx_FORM1.lx_pageframe1.page11.addobject('bt_copia', 'bt_estfilial')
  			    

		ENDCASE
		
	ENDPROC
	
enddefine


DEFINE CLASS bt_estfilial as botao

	caption = 'Gerar Arq Final'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 120
	top = 2
	left = 280
	HEIGHT =  20
	enabled = .T.
	visible  = .T.
	
	
	****backcolor =  RGB(64,128,128)
	

	
	
	PROCEDURE click
	
	        SELECT V_ESTOQUE_PRODUTOS_VERTICAL
	        COUNT TO nTotal_reg
	        
	        IF nTotal_reg <= 1
	           Messagebox("Por favor, selecione os dados!",16, 'Aviso')
	           RETURN .f.
	        Endif
	       
	         WAIT WINDOW "Processando, aguarde.." nowait
	        
	        SELECT V_ESTOQUE_PRODUTOS_VERTICAL
	        GO top
	        
	        lc_filial = alltrim(V_ESTOQUE_PRODUTOS_VERTICAL.FILIAL)
	
			TEXT TO l_sql  NOSHOW
			select preco.codigo_tab_preco, preco.produto, preco.preco1
			from
			   produtos_precos preco
			join LOJA_OPERACOES_VENDA oper
			      on preco.codigo_tab_preco = oper.codigo_tab_preco
			join      
				parametros_loja param
			    on rtrim(param.valor_atual) = oper.operacao_venda
			    and  param.parametro like 'OPERACAO_VENDA'
			 join filiais fi
			    on   param.codigo_filial = fi.cod_filial 
			    where fi.filial like ?lc_filial
			 ENDTEXT
			 
			IF USED("xpreco_filial")
			  USE IN xpreco_filial
			endif
			 

			 f_select(l_sql ,'xpreco_filial') 
			 
			IF RECCOUNT("xpreco_filial")  = 0

				TEXT TO l_sql  NOSHOW
				select preco.codigo_tab_preco, preco.produto, preco.preco1
				from
				   produtos_precos preco
				    where codigo_tab_preco = '01'
				 ENDTEXT
				 
				IF USED("xpreco_filial")
				  USE IN xpreco_filial
				endif
				 
				 f_select(l_sql ,'xpreco_filial') 			 
				 
			endif	 


			IF USED("x_exporta")
			  USE IN x_exporta
			endif

*** PAULO DEVIDE --> 26-06-2013 - inclusão da clausula WITH (BUFFERING=.T.)

			select;
			RTRIM(griffe)+'|'+RTRIM(linha)+'|'+;
			RTRIM(subgrupo_produto)+'|'+RTRIM(V_ESTOQUE_PRODUTOS_VERTICAL.produto)+'|'+RTRIM(cor_produto);
			+'|'+RTRIM(NVL(V_ESTOQUE_PRODUTOS_VERTICAL.produto,""))+RTRIM(cor_produto)+RTRIM(tamanho)+'|';
			 +RTRIM(desc_produto)+'|'+RTRIM(desc_cor_produto)+'|'+;
			allTRIM(TRANSFORM(estoque,'999999'))+'|'+;
			allTRIM(TRANSFORM(NVL(preco.preco1,0),'999,999.99'))  as linha;
			from V_ESTOQUE_PRODUTOS_VERTICAL;
			WITH (BUFFERING=.T.) ;
			left join xpreco_filial preco;
			on V_ESTOQUE_PRODUTOS_VERTICAL.PRODUTO = PRECO.PRODUTO;
			order by griffe,linha,subgrupo_produto, preco.produto, cor_produto;
			into cursor x_exporta

			

			SELECT x_exporta
			**BROWSE TITLE ALIAS()
			
			xarquivo=GETFILE('txt', 'Criar arquivo a .txt:','Browse', 1, 'Criar arquivo')

            WAIT clear
            
			IF !EMPTY(xarquivo)
			

				***COPY TO &xarquivo. TYPE SDF
			
			ELSE
				
				xarquivo = 'c:\arquivo_stk_inv.txt'
				
				IF FILE(lc_arquivo)
				   DELETE FILE &xarquivo.
				endif
				
				***********COPY TO 'c:\arquivo_stk_inv.txt' TYPE SDF
			endif	
			
			SET STEP ON 

			IF !FILE(xarquivo)
			      xarq2     = FCREATE(xarquivo)
			ELSE
			      DELETE FILE xarquivo
			      xarq2     = FCREATE(xarquivo) 
			ENDIF
			

			SELECT x_exporta
			SCAN
			      IF !ISNULL(x_exporta.linha)
			            xdet = ALLTRIM(x_exporta.linha)
			            =FPUTS(xarq2,xdet)
			      endif 
			ENDSCAN

			=FCLOSE(xarq2) 
			
   			MESSAGEBOX("Arquivo criado !")
			
			

	ENDPROC
ENDDEFINE





DEFINE CLASS bt_produtos as botao

	caption = 'Gerar Arquivo inicial'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 120
	top = 2
	left = 100
	HEIGHT =  20
	enabled = .T.
	visible  = .T.
	
	
	****backcolor =  RGB(64,128,128)
	

	
	
	PROCEDURE click
	
	        SELECT V_ESTOQUE_PRODUTOS_VERTICAL
	        COUNT TO nTotal_reg
	        
	        IF nTotal_reg <= 1
	           Messagebox("Por favor, selecione os dados!",16, 'Aviso')
	           RETURN .f.
	        Endif
	       
	        WAIT WINDOW "Processando, aguarde.." nowait
	        
	        SELECT V_ESTOQUE_PRODUTOS_VERTICAL
	        GO top
	        
	        xxfilial = alltrim(V_ESTOQUE_PRODUTOS_VERTICAL.FILIAL)
	
		
				TEXT TO xy NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
				select a.valor_atual 
				from PARAMETROS_LOJA a  inner join FILIAIS B
				on a.CODIGO_FILIAL = b.COD_FILIAL 
				where PARAMETRO = 'CODIGO_TAB_PRECO'
				and b.FILIAL = '<<xxfilial>>'
				ENDTEXT

				F_select( xy, 'matriz2')

				xxtabpreco = IIF( EMPTY(ALLTRIM(NVL(matriz2.valor_atual,''))),'01',ALLTRIM(NVL(matriz2.valor_atual,'')) )


				TEXT TO x NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
				SELECT x.tamanho, x.grade,
				x.produto, x.cor_produto, x.codigo_barra, x.desc_produto, x.estoque ,y.preco1,
				X.ES1,X.ES2,X.ES3,X.ES4,X.ES5,X.ES6,X.ES7,X.ES8,X.ES9,X.ES10,X.ES11,X.ES12,X.ES13,X.ES14,X.ES15,X.ES16,X.ES17,
				X.ES18,X.ES19,X.ES20,X.ES21,X.ES22,X.ES23,X.ES24,X.ES25,X.ES26,X.ES27,X.ES28,X.ES29,X.ES30,X.ES31,X.ES32,X.ES33,
				X.ES34,X.ES35,X.ES36,X.ES37,X.ES38,X.ES39,X.ES40,X.ES41,X.ES42,X.ES43,X.ES44,X.ES45,X.ES46,X.ES47,X.ES48
				from (
						select a.tamanho, a.grade,c.produto, a.cor_produto, a.codigo_barra, D.desc_produto , sum(b.estoque )  as estoque,
						 SUM(B.ES1) as ES1,SUM(B.ES2) as ES2,SUM(B.ES3) as ES3,SUM(B.ES4) as ES4,SUM(B.ES5) as ES5,SUM(B.ES6) as ES6,
							SUM(B.ES7) as ES7,SUM(B.ES8) as ES8,SUM(B.ES9) as ES9,SUM(B.ES10) as ES10,SUM(B.ES11) as ES11,SUM(B.ES12) as ES12,
							SUM(B.ES13) as ES13,SUM(B.ES14) as ES14,SUM(B.ES15) as ES15,SUM(B.ES16) as ES16,SUM(B.ES17) as ES17,SUM(B.ES18) as ES18,
							SUM(B.ES19) as ES19,SUM(B.ES20) as ES20,SUM(B.ES21) as ES21,SUM(B.ES22) as ES22,SUM(B.ES23) as ES23,SUM(B.ES24) as ES24,
							SUM(B.ES25) as ES25,SUM(B.ES26) as ES26,SUM(B.ES27) as ES27,SUM(B.ES28) as ES28,SUM(B.ES29) as ES29,SUM(B.ES30) as ES30,
							SUM(B.ES31) as ES31,SUM(B.ES32) as ES32,SUM(B.ES33) as ES33,SUM(B.ES34) as ES34,SUM(B.ES35) as ES35,SUM(B.ES36) as ES36,
							SUM(B.ES37) as ES37,SUM(B.ES38) as ES38,SUM(B.ES39) as ES39,SUM(B.ES40) as ES40,SUM(B.ES41) as ES41,SUM(B.ES42) as ES42,
							SUM(B.ES43) as ES43,SUM(B.ES44) as ES44,SUM(B.ES45) as ES45,SUM(B.ES46) as ES46,SUM(B.ES47) as ES47,SUM(B.ES48) as ES48
						from ESTOQUE_PRODUTOS B left join  PRODUTOS_barra a 
							on a.produto = b.produto
							and a.COR_PRODUTO = b.COR_PRODUTO 
							inner join PRODUTO_CORES  C
							on a.produto = c.produto
							and a.COR_PRODUTO = c.COR_PRODUTO 
							and b.COR_PRODUTO = c.COR_PRODUTO 
							and c.produto = b.produto
							inner join PRODUTOS D
							on a.PRODUTO = d.produto
							where  D.DATA_CADASTRAMENTO >= '19000101' and 
							b.filial = '<<xxfilial>>'
							group by a.tamanho, a.grade,c.produto, a.cor_produto, a.codigo_barra, d.desc_produto
					) X 
					LEFT JOIN 	
					(
						Select cur2.PRODUTO,Venda, PRODUTOS_PRECOS.preco1
						from
							(Select PRODUTO,SUM(Venda) as Venda
							from
									(SELECT A.PRODUTO, ISNULL(sum(QTDE),0)AS VENDA 
									From LOJA_VENDA_PRODUTO B 
									join produtos A on A.PRODUTO = B.PRODUTO
									WHERE B.DATA_VENDA  <= getdate() 
									group by A.PRODUTO
									union all 		
									SELECT A.PRODUTO, ISNULL(sum(QTDE),0) * (-1) AS VENDA 
									From LOJA_VENDA_TROCA B 
									join produtos A on A.PRODUTO = B.PRODUTO 	
									WHERE B.DATA_VENDA <= getdate() 
									group by A.PRODUTO
				 					union All
									SELECT A.PRODUTO, ISNULL(sum(qtde),0)AS VENDA 
									From loja_pedido B
									Left join LOJA_PEDIDO_PRODUTO C on B.PEDIDO = C.PEDIDO and B.CODIGO_FILIAL_ORIGEM = C.CODIGO_FILIAL_ORIGEM
									Left Join Produtos A  on A.produto = c.produto
									Where B.tipo_pedido = 3 and C.cancelado = 0  AND B.DATA  <= GETDATE()  
									group by A.PRODUTO
									/*
				 					union All
									select a.produto, 0 as venda
									from ESTOQUE_PRODUTOS a 
									group by A.PRODUTO
									*/
									) cur
							group by PRODUTO	
							) Cur2
									LEFT JOIN PRODUTOS_PRECOS
									ON PRODUTOS_PRECOS.CODIGO_TAB_PRECO = '<<xxtabpreco>>'
									and cur2.produto = PRODUTOS_PRECOS.produto
							) Y	
						on x.produto = y.produto
					order by LTRIM(RTRIM( x.codigo_barra))	
				ENDTEXT

				F_select( x, 'matriz')

				** PAULO DEVIDE - 06-02-2014
				** #1 - INICIO
				xx_executa = .F.
				
				IF xx_executa
					*------------------------------------------------------------------------------------
					stok_temp = DTOS(DATE())+'I'+SUBSTR(STRTRAN(UPPER(wusuario), 'CCP\', ''),1,AT('.',STRTRAN(UPPER(wusuario), 'CCP\', ''))-1)
					
					

					TEXT TO xyz9 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
					IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[<<stok_temp>>]') AND type in (N'U'))
					DROP TABLE [dbo].[<<stok_temp>>]
					ENDTEXT
					F_select( xyz9, 'matriz3')



					TEXT TO xyz2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
					CREATE TABLE [dbo].[<<stok_temp>>](
						[produto] [char](12) NOT NULL,
						[cor_produto] [char](10) NOT NULL,
						[codigo_barra] [varchar](25) NOT NULL,
						[desc_produto] [varchar](40) NOT NULL,
						[estoque] [int] NULL,
						[preco1] [numeric](14, 2) NULL
					) ON [PRIMARY]
					ENDTEXT

					F_select( xyz2, 'matriz3')



					TEXT TO xyz3 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
					DELETE [<<stok_temp>>]
					ENDTEXT

					F_select( xyz3, 'matriz3')
				ELSE
					
					stok_temp =	"CAEDU_ARQ_CONSULTA_ESTOQUE"
					
					xkey_user = SYS(2015)
					
				ENDIF
				** PAULO DEVIDE - 06-02-2014
				** #1 - FIM
				
				*SET STEP on
				 

				*-----------------------------------------------------------------------------------
				*!*	TEXT TO xyz NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
				*!*	DELETE stok_temp 
				*!*	ENDTEXT

				*!*	F_select( xyz, 'matriz3')



				SELECT matriz
				SCAN
					xpro	= matriz.produto
					xcor	= matriz.cor_produto
					xbar	= matriz.codigo_barra
					xdesc	= matriz.desc_produto
					xpre	= matriz.preco1

					lin =  ALLTRIM(STR(matriz.tamanho))
					xref = 'matriz.es'+lin
					xest	= &xref
					IF xx_executa
					
						f_select("insert into [" + stok_temp + "] (produto,cor_produto,codigo_barra,desc_produto,estoque,preco1) values (	?xpro,	?xcor,	?xbar,	?xdesc, ?xest	,?xpre ) ","as")
					
					ELSE
						** PAULO DEVIDE - 06-02-14
						f_select("insert into [" + stok_temp + "] (produto,cor_produto,codigo_barra,desc_produto,estoque,preco1,USER_KEY) values (	?xpro,	?xcor,	?xbar,	?xdesc, ?xest	,?xpre, ?xkey_user ) ","as")
					
					ENDIF
						
					
				ENDSCAN




				TEXT TO xyzw NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
				SELECT 
				rtrim(ltrim(b.GRIFFE))+'|'+
				rtrim(ltrim(b.linha))+'|'+ 
				rtrim(ltrim(b.GRUPO_PRODUTO))+'|'+ 
				rtrim(ltrim(a.produto))+'|'+rtrim(ltrim(a.cor_produto))+'|'+ 
				rtrim(ltrim(a.codigo_barra))+'|'+
				substring(rtrim(ltrim(replace(a.desc_produto,';',''))),1,30)  +'|'+
				rtrim(ltrim(c.desc_cor_produto))+'|'+
				rtrim(ltrim(convert(char(10),a.estoque)))+'|'+
				rtrim(ltrim(CONVERT(char(10),a.preco1))) as linha
				from [<<stok_temp>>]  A inner join PRODUTOS b 
				on a.produto = b.produto
				inner join produto_cores c
				on a.produto = c.produto
				and a.cor_produto = c.COR_produto 
				ENDTEXT

				IF !xx_executa 
					xyzw = xyzw + " where USER_KEY = '"+ALLTRIM(xkey_user)+"'"
				ENDIF
									


				F_select( xyzw , 'basedesc')

				xarquivo=GETFILE('csv', 'Browse or Create a .csv:','Browse', 1, 'Browse or Create')

				IF !FILE(xarquivo)
					xarq2     = FCREATE(xarquivo)
				ELSE
					DELETE FILE xarquivo
					xarq2     = FCREATE(xarquivo)	
				ENDIF

				SELECT basedesc
				SCAN
					IF !ISNULL(basedesc.linha)
						xdet = ALLTRIM(basedesc.linha)
						=FPUTS(xarq2,xdet)
					endif	

				ENDSCAN

				=FCLOSE(xarq2) 

				IF xx_executa
					TEXT TO xyz7 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
					DROP table [<<stok_temp>>] 
					ENDTEXT
				ELSE
					TEXT TO xyz7 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
					delete [<<stok_temp>>] where USER_KEY = '<<ALLTRIM(xkey_user)>>'
					ENDTEXT
				ENDIF
								

				F_select( xyz7, 'matriz3')


				MESSAGEBOX("Arquivo gerado ")
				***************************************************
							
							

					ENDPROC
				ENDDEFINE

				**************************************************

