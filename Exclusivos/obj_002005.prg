define class obj_entrada as custom
	procedure metodo_usuario
		lparam xmetodo, xobjeto ,xnome_obj
		DO CASE
			CASE UPPER(xmetodo) == 'USR_INIT'
				WAIT WINDOW 'OBJ' NOWAIT

**** ALTERAÇÃO DO CURSOR ADAPTER ****
** primeiro remove objeto, depois cria um novo, incluindo nova coluna ERP_CUPS_DESCRICAO_IMPORTACAO 
Thisformset.dataEnvironment.RemoveObject("Cur_v_produtos_grifes_00") && remove objeto da tela
AddNewObject(Thisformset.dataenvironment, "Cur_v_produtos_grifes_00","ccursoradapter")

With Thisformset.dataenvironment
.Cur_v_produtos_grifes_00.DataSourceType			="ADO"
Text to .Cur_v_produtos_grifes_00.SelectCmd TextMerge NoShow
SELECT PRODUTOS_GRIFFES.COD_GRIFFE,PRODUTOS_GRIFFES.GRIFFE, PRODUTOS_GRIFFES.LICENCIADO,  PRODUTOS_GRIFFES.LICENCIADOR, PRODUTOS_GRIFFES.ROYALTIES 
,PRODUTOS_GRIFFES.ERP_CUPS_DESCRICAO_IMPORTACAO
FROM PRODUTOS_GRIFFES PRODUTOS_GRIFFES 
ORDER BY PRODUTOS_GRIFFES.GRIFFE
ENDTEXT

Text to .Cur_v_produtos_grifes_00.CursorSchema TextMerge NoShow
COD_GRIFFE C(2), GRIFFE C(25), LICENCIADO C(25), LICENCIADOR C(25), ROYALTIES N(10,5), ERP_CUPS_DESCRICAO_IMPORTACAO C(50)
ENDTEXT

zupdL = ""
zupdL = zupdL +"GRIFFE PRODUTOS_GRIFFES.GRIFFE, LICENCIADO PRODUTOS_GRIFFES.LICENCIADO, ROYALTIES PRODUTOS_GRIFFES.ROYALTIES, "
zupdL = zupdL +"LICENCIADOR PRODUTOS_GRIFFES.LICENCIADOR, COD_GRIFFE PRODUTOS_GRIFFES.COD_GRIFFE, ERP_CUPS_DESCRICAO_IMPORTACAO PRODUTOS_GRIFFES.ERP_CUPS_DESCRICAO_IMPORTACAO"

.Cur_v_produtos_grifes_00.UpdateNameList = zupdL

Text to .Cur_v_produtos_grifes_00.UpdatableFieldList TextMerge NoShow
GRIFFE, LICENCIADO, ROYALTIES, LICENCIADOR, COD_GRIFFE, ERP_CUPS_DESCRICAO_IMPORTACAO
ENDTEXT

.Cur_v_produtos_grifes_00.Tables			="PRODUTOS_GRIFFES"
.Cur_v_produtos_grifes_00.KeyFieldList		="GRIFFE"
		
Text to .Cur_v_produtos_grifes_00.QueryList TextMerge NoShow
COD_GRIFFE PRODUTOS_GRIFFES.COD_GRIFFE, GRIFFE PRODUTOS_GRIFFES.GRIFFE, LICENCIADO PRODUTOS_GRIFFES.LICENCIADO, 
LICENCIADOR PRODUTOS_GRIFFES.LICENCIADOR, ROYALTIES PRODUTOS_GRIFFES.ROYALTIES, ERP_CUPS_DESCRICAO_IMPORTACAO PRODUTOS_GRIFFES.ERP_CUPS_DESCRICAO_IMPORTACAO
ENDTEXT
		
Text to .Cur_v_produtos_grifes_00.CaptionList TextMerge NoShow
COD_GRIFFE Cod Griffe, GRIFFE Griffe, LICENCIADO Licenciado, LICENCIADOR Licenciador, ROYALTIES Royalties, ERP_CUPS_DESCRICAO_IMPORTACAO ERP_CUPS_DESCRICAO_IMPORTACAO
ENDTEXT
		
.Cur_v_produtos_grifes_00.DefaultsValuesList = ""

.Cur_v_produtos_grifes_00.FTableList		= "" 
.Cur_v_produtos_grifes_00.Alias		="v_produtos_grifes_00"
.Cur_v_produtos_grifes_00.ParentCursor	=""
.Cur_v_produtos_grifes_00.BufferModeOverride	=5
.Cur_v_produtos_grifes_00.NoDataOnLoad	=.T.
.Cur_v_produtos_grifes_00.IsUpdateCursor	=.T.
.Cur_v_produtos_grifes_00.IsMaster		=.T.
.Cur_v_produtos_grifes_00.UpdateType		=1
.Cur_v_produtos_grifes_00.WhereType		=3
.Cur_v_produtos_grifes_00.FetchMemo		=.T.
.Cur_v_produtos_grifes_00.SendUpdates	=.F.
.Cur_v_produtos_grifes_00.UseMemoSize	=255
.Cur_v_produtos_grifes_00.FetchSize		=-1
.Cur_v_produtos_grifes_00.MaxRecords		=-1
.Cur_v_produtos_grifes_00.Prepared		=.F.
.Cur_v_produtos_grifes_00.CompareMemo	=.F.
.Cur_v_produtos_grifes_00.BatchUpdateCount	=1
.Cur_v_produtos_grifes_00.OpenCursor()

EndWith


				IF "CUPS" $ SET( "ClassLib" )
					** Ok, Registry carregado
				ELSE
					SET CLASSLIB TO CUPS.vcx ADDITIVE
				ENDIF
				
				thisformset.lx_form1.minbutton=.f.
				thisformset.lx_form1.maxbutton=.f.								
				
				WITH thisformset.lx_form1
					.width = 707
					.Lx_TitleBar.Width=707
					.Lx_frame_3d1.Width = 700
					.label_GRIFFE.Left = 0
					.tx_COD_GRIFFE.Left = 85
					.tx_GRIFFE.Left = 112
					.addobject("lbl_Descricao1","label")
					.lbl_descricao1.left = 300
					.lbl_descricao1.caption = "Descrição Importado"
					.lbl_descricao1.autosize=.t.
					.lbl_descricao1.top = .label_GRIFFE.top
					.lbl_descricao1.visible=.t.					

					.addobject("txt_Griffe_Desc_Importado1","txt_Griffe_Desc_Importado")
					.txt_Griffe_Desc_Importado1.left = .lbl_descricao1.left + .lbl_descricao1.width + 10
					.txt_Griffe_Desc_Importado1.top = .label_GRIFFE.top - 3
					.txt_Griffe_Desc_Importado1.ControlSource = "v_produtos_grifes_00.ERP_CUPS_DESCRICAO_IMPORTACAO"
					.txt_Griffe_Desc_Importado1.visible=.t.					
					
				ENDWITH
				
				thisformset.l_limpa()

			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'
			OTHERWISE
				RETURN .t.
		ENDCASE
	ENDPROC
ENDDEFINE
