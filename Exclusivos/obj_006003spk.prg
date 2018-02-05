define class obj_entrada as custom
	procedure metodo_usuario
		lparam xmetodo, xobjeto ,xnome_obj
		DO CASE
			CASE UPPER(xmetodo) == 'USR_INIT'
				WAIT WINDOW 'OBJ' NOWAIT

				WITH thisformset
					.lx_FORM1.lx_pageframe1.page1.AddObject("bt_excel1","bt_excel")
					.lx_FORM1.lx_pageframe1.page1.bt_excel1.filial_selecionada = ALLTRIM(.px_filial_selecionada)
					.lx_FORM1.lx_pageframe1.page1.bt_excel1.visible=.t.
				ENDWITH
				
			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

			OTHERWISE
				RETURN .t.
		ENDCASE
	ENDPROC
ENDDEFINE


DEFINE CLASS bt_excel as botao

	Top=80
	left=3
	width=32
	height=32
	caption=""
	visible=.t.
	picture = LOCFILE("excel-icon-32x32.png","png","Icone Excel")
	disabledpicture = LOCFILE("excel-icon-32x32_disable.png","png","Icone Excel")
	filial_selecionada = ""


	PROCEDURE when
		this.filial_selecionada = ALLTRIM(thisformset.px_filial_selecionada)
	ENDPROC
	
	PROCEDURE click

		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Exportar dados da Consulta para o Excel?",292,"Aviso")=6

		IF !llRet
			RETURN 
		ENDIF
			
		SELECT ;
		MATERIAL, DESC_MATERIAL,  CAST(ESTOQUE AS INT) AS ESTOQUE, UNID_ESTOQUE, GRUPO, ;
		CAST(0 AS N(12,2)) AS VALOR_UM, CAST(0 AS N(12,2)) AS VALOR_TOTAL ;
		FROM V_ESTOQUE_MATERIAIS_01 ;
		INTO CURSOR VXLS_ESTOQUE_MATERIAIS_01 READWRITE
		
		SELECT VXLS_ESTOQUE_MATERIAIS_01
		SCAN 		
			f_wait("Aguarde processando material = "+ALLTRIM(VXLS_ESTOQUE_MATERIAIS_01.MATERIAL))
			IF ALLTRIM(this.filial_selecionada) = "( TODAS AS FILIAIS )" 
				lnCusto = custo_est1(VXLS_ESTOQUE_MATERIAIS_01.MATERIAL)
			ELSE
				lnCusto = custo_est1(VXLS_ESTOQUE_MATERIAIS_01.MATERIAL,ALLTRIM(this.filial_selecionada))
			ENDIF
			
			SELECT VXLS_ESTOQUE_MATERIAIS_01
			REPLACE VALOR_UM WITH lnCusto
			REPLACE VALOR_TOTAL WITH lnCusto * VXLS_ESTOQUE_MATERIAIS_01.ESTOQUE	
		ENDSCAN
		f_wait()
		=exporta_excel1("VXLS_ESTOQUE_MATERIAIS_01")
		
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


FUNCTION custo_est1
**********************************
* FUNÇÃO PARA PESQUISAR O CUSTO DA 
* ULTIMA ENTRADA NO ESTOQUE
* AUTOR: PAULO DEVIDÉ
*/
PARAMETERS tcMaterial, tcFilial
lnParms = PARAMETERS()
lnArea = SELECT()
IF lnParms=2
	TEXT TO lcSQL NOSHOW TEXTMERGE
	select top 1 a.custo
	from ENTRADAS_MATERIAL a
	inner join ENTRADAS b on a.nf_entrada=b.nf_entrada and a.serie_nf_entrada=b.SERIE_NF_ENTRADA
		and a.NOME_CLIFOR=b.NOME_CLIFOR
	where MATERIAL = '<<tcMaterial>>'
	and b.FILIAL = '<<tcFilial>>'
	order by b.EMISSAO desc
	ENDTEXT
ELSE
	TEXT TO lcSQL NOSHOW TEXTMERGE
	select top 1 a.custo
	from ENTRADAS_MATERIAL a
	inner join ENTRADAS b on a.nf_entrada=b.nf_entrada and a.serie_nf_entrada=b.SERIE_NF_ENTRADA
		and a.NOME_CLIFOR=b.NOME_CLIFOR
	where MATERIAL = '<<tcMaterial>>'
	order by b.EMISSAO desc
	ENDTEXT
ENDIF
	
F_SELECT(lcSQL,"tmpCusto1")
nRet = NVL(tmpCusto1.CUSTO,0)
SELECT (lnArea)
RETURN nRet
ENDFUNC

