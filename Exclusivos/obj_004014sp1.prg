define class obj_entrada as custom
	procedure metodo_usuario
		lparam xmetodo, xobjeto ,xnome_obj
		DO CASE
			CASE UPPER(xmetodo) == 'USR_INIT'
				WAIT WINDOW 'OBJ' NOWAIT

				WITH thisformset
					.lx_FORM1.lx_pageframe1.page1.AddObject("bt_excel1","bt_excel")
					.lx_FORM1.lx_pageframe1.page1.bt_excel1.visible=.t.
				ENDWITH
				
			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

			OTHERWISE
				RETURN .t.
		ENDCASE
	ENDPROC
ENDDEFINE


DEFINE CLASS bt_excel as botao

	Top=170
	left=0
	width=32
	height=32
	caption=""
	visible=.t.
	picture = LOCFILE("excel-icon-32x32.png","png","Icone Excel")
	disabledpicture = LOCFILE("excel-icon-32x32_disable.png","png","Icone Excel")


	PROCEDURE click

		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Exportar dados da Consulta para o Excel?",292,"Aviso")=6

		IF !llRet
			RETURN 
		ENDIF
		
		select PRODUTO,COR_PRODUTO,DESC_COR_PRODUTO,PEDIDO,ENTREGA,LIMITE_ENTREGA,REQUISICAO,CUSTO1,CUSTO2,CUSTO3,CUSTO4,;
		CUSTO_MOEDA1,VALOR_ENTREGAR,VALOR_ENTREGAR_PADRAO,CUSTO_MOEDA2,CUSTO_MOEDA3,CUSTO_MOEDA4,IPI,DESCONTO_ITEM,VALOR_ORIGINAL,;
		VALOR_ORIGINAL_PADRAO,VALOR_ENTREGUE,VALOR_ENTREGUE_PADRAO,PACKS,QTDE_CANCELADA,QTDE_ENTREGUE,QTDE_ENTREGAR,CO1,CO2,CO3,CO4,;
		CO5,CO6,CO7,CO8,CO9,CO10,CO11,CO12,CO13,CO14,CO15,CO16,CO17,CO18,CO19,CO20,CO21,CO22,CO23,CO24,CO25,CO26,CO27,CO28,CO29,CO30,;
		CO31,CO32,CO33,CO34,CO35,CO36,CO37,CO38,CO39,CO40,CO41,CO42,CO43,CO44,CO45,CO46,CO47,CO48,CE1,CE2,CE3,CE4,CE5,CE6,CE7,CE8,CE9,;
		CE10,CE11,CE12,CE13,CE14,CE15,CE16,CE17,CE18,CE19,CE20,CE21,CE22,CE23,CE24,CE25,CE26,CE27,CE28,CE29,CE30,CE31,CE32,CE33,CE34,;
		CE35,CE36,CE37,CE38,CE39,CE40,CE41,CE42,CE43,CE44,CE45,CE46,CE47,CE48,TRANSPORTADORA,FORNECEDOR,CGC_CPF,FILIAL_A_ENTREGAR,;
		MOEDA,EMISSAO,CONDICAO_PGTO,QTDE_ORIGINAL,DESC_COND_PGTO,PEDIDO_FORNECEDOR,CADASTRAMENTO,DESCONTO,ENCARGO,;
		VALOR_IPI,FRETE_A_PAGAR,TOT_QTDE_ORIGINAL,TOT_QTDE_ENTREGAR,TOT_VALOR_ORIGINAL,TOT_VALOR_ENTREGAR,CTRL_MULT_ENTREGAS,;
		ENTREGA_ACEITAVEL,PEDIDO1,FILIAL_COBRANCA,FILIAL_A_FATURAR,COD_TRANSACAO,APROVADOR_POR,REQUERIDO_POR,TABELA_FILHA,PROGRAMACAO,;
		TIPO_COMPRA,STATUS_APROVACAO,DATA_APROVACAO,ORIGEM_DA_COMPRA,STATUS_COMPRA,PEDIDO_VENDA,TIPO_PRODUTO,DESC_PRODUTO,;
		TABELA_MEDIDAS,TABELA_OPERACOES,PERIODO_PCP,GRUPO_PRODUTO,SUBGRUPO_PRODUTO,COLECAO,GRADE,LINHA,GRIFFE,CARTELA,;
		REFER_FABRICANTE,REVENDA,FABRICANTE,GIRO_ENTREGA,STATUS_PRODUTO,TIPO_STATUS_PRODUTO,EMPRESA,VALOR_MULTIPLICAR ;
		from V_COMPRAS_PRODUTOS_ANALITICO_01 ;
		INTO CURSOR XLS_COMPRAS_PRODUTOS_ANALITICO
 
		=exporta_excel1("XLS_COMPRAS_PRODUTOS_ANALITICO")
		
	ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC

ENDDEFINE


FUNCTION exporta_excel1
***************************************
* FUNÇÃO PARA EXPORTAR CURSOR DO FOXPRO 
* PARA EXCEL 2007 ou SUPERIOR
* AUTOR: PAULO DEVIDÉ
*/
PARAMETERS lcCursor, lcListaFields 

IF PARAMETERS()<2
	lcListaFields = ""
ENDIF

IF NOT USED(lcCursor)
	RETURN
ENDIF
	
SELECT (lcCursor)
IF RECCOUNT(lcCursor)=0
	MESSAGEBOX("Não há dados para exportar para o Excel!"+ CHR(13)+;
				"Selecione outro filtro.", 64, "Aviso")
	RETURN
ENDIF

IF NOT EMPTY(lcListaFields) 
	SET FIELDS TO &lcListaFields.
ENDIF

GO top

** Formata cursor no excel
lcOldPoint = SET("Point")
lcOldSeparator = SET("Separator")

SET SEPARATOR TO ","
SET POINT TO "."

LOCAL oExcel as Object

oExcel = CREATEOBJECT("Excel.application")

WITH oExcel
	.Application.ErrorCheckingOptions.BackgroundChecking = .f.
	.SheetsInNewWorkbook = 1 && quantas sheets vai criar dentro do workbook = 1
	.workbooks.Add
	.Sheets(1).Name = lcCursor
	
	.visible = .f.
	
	** formata as celulas no excel, conforme se tipo no cursor
	lcColsDateFormat = ""
	
	lnFields = AFIELDS(laFields,lcCursor)
	FOR lnCount=1 TO ALEN(laFields,1)
		
		.Cells(1,lnCount).Select
		lcAdress = SUBSTR(.ActiveCell.Address,2,ATC("$",.ActiveCell.Address,2)-2)
		.Columns(lcAdress+":"+lcAdress).Select
		
		DO CASE
			CASE INLIST(laFields[lnCount,2],'C','M','V') && caracter
				.Selection.NumberFormat = "@" && formata a celula para TEXTO
				
			CASE laFields[lnCount,2] = 'Y' && moeda
				.Selection.NumberFormat = [_(* #,##0.00_);_(* (#,##0.00);_(* ""-""??_);_(@_)]
				
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

	SELECT (lcCursor)
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
	
	.cells(1,1).select	
	.visible = .T.
	
	
ENDWITH
SET SEPARATOR TO &lcOldSeparator.
SET POINT TO &lcOldPoint.

IF SET("Fields")<>""
	SET FIELDS TO 
ENDIF
	
RELEASE oExcel
MESSAGEBOX("Processamento Concluído!",64,"Aviso")
RETURN
ENDFUNC


