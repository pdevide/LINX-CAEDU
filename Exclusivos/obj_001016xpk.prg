define class obj_entrada as custom
	procedure metodo_usuario
	lparam xmetodo, xobjeto ,xnome_obj
	DO CASE
		CASE UPPER(xmetodo) == 'USR_INIT'	
			WAIT WINDOW 'OBJ' NOWAIT

			STORE 0 TO lnTop, lnLeft	
*							.lx_FORM1.lx_pageframe1.page1.Lx_cabecalho_contato1.Cmb_STATUS_CONTATO.DisplayValue
			WITH thisformset.lx_FORM1.lx_pageframe1.page1.Lx_cabecalho_contato1.Lx_label3
				lnTop = .top - 2
				lnLeft = .parent.Cmb_STATUS_CONTATO.Left - 30
			ENDWITH
			WITH thisformset.lx_FORM1.lx_pageframe1.page1.Lx_cabecalho_contato1
				.AddObject("LABEL_ID_ORACLE","LABEL")
				.LABEL_ID_ORACLE.top = lnTop + 2
				.LABEL_ID_ORACLE.left = lnLeft - 50
				.LABEL_ID_ORACLE.Caption = "ID ORACLE"
				.LABEL_ID_ORACLE.BackStyle = 0
				.LABEL_ID_ORACLE.visible = .t.
				
				.AddObject("txt_Id_Oracle1","txt_Id_Oracle")
				.txt_Id_Oracle1.visible=.t.
*!*					.bt_lecodigo1.top = lnTop
*!*					.bt_lecodigo1.left = lnLeft
			ENDWITH


		CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'
		    IF THISFORMSET.P_TOOL_STATUS != 'E'
				lcAlias = ALIAS()
				SELECT v_FORNECEDORES_01	
				IF EMPTY(NVL(v_FORNECEDORES_01.razao_social, ''))
					MESSAGEBOX('Antes de salvar Informe a raz„o social.', 0+64, 'OBJ - RAZAO SOCIAL INV¡LIDA')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_FORNECEDORES_01.cgc_cpf, ''))
					MESSAGEBOX('Antes de salvar Informe o CNPJ.', 0+64, 'OBJ - CGC INV¡LIDO')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_FORNECEDORES_01.rg_ie, ''))
					MESSAGEBOX('Antes de salvar Informe a InscriÁ„o Estadual.', 0+64, 'OBJ - INSCRI«√O INV¡LIDA')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_FORNECEDORES_01.CEP, ''))
					MESSAGEBOX('Antes de salvar Informe o CEP.', 0+64, 'OBJ - CEP INV¡LIDO')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_FORNECEDORES_01.ENDERECO, ''))
					MESSAGEBOX('Antes de salvar Informe o EndereÁo.', 0+64, 'OBJ - ENDERE«O INV¡LIDO')
					RETURN .F.
				ENDIF
			
				IF EMPTY(NVL(v_FORNECEDORES_01.cidade, ''))
					MESSAGEBOX('Antes de salvar Informe a Cidade.', 0+64, 'OBJ - CIDADE INV¡LIDO')
					RETURN .F.
				ENDIF
							
				IF EMPTY(NVL(v_FORNECEDORES_01.bairro, ''))
					MESSAGEBOX('Antes de salvar Informe o Bairro.', 0+64, 'OBJ - BAIRRO INV¡LIDO')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_FORNECEDORES_01.uf, ''))
					MESSAGEBOX('Antes de salvar Informe o Estado.', 0+64, 'OBJ - ESTADO INV¡LIDO')
					RETURN .F.
				ENDIF
							
				IF EMPTY(NVL(v_FORNECEDORES_01.numero, ''))
					MESSAGEBOX('Antes de salvar Informe o Numero do EndereÁo.', 0+64, 'OBJ - NUMERO INV¡LIDO')
					RETURN .F.
				ENDIF
			
				IF EMPTY(NVL(v_FORNECEDORES_01.pais, ''))
					MESSAGEBOX('Antes de salvar Informe o Pais.', 0+64, 'OBJ - PAIS INV¡LIDO')
					RETURN .F.
				ENDIF

				IF UPPER(ALLTRIM(v_FORNECEDORES_01.pais)) = 'BRASIL'
			  		F_SELECT("select * from LCF_LX_MUNICIPIO A JOIN LCF_LX_UF B ON A.ID_UF = B.ID_UF " +;
						 "WHERE UF=?v_FORNECEDORES_01.uf AND DESC_MUNICIPIO =?v_FORNECEDORES_01.CIDADE ",'CUR_VER',ALIAS())
						 
 					IF RECCOUNT('CUR_VER') =0
 					   MESSAGEBOX('A cidade+uf n„o esta cadastrada no SEFAZ,Favor Verificar a CIDADE e o ESTADO!!', 0+64, 'OBJ - CIDADE-UF INV¡LIDA')
					   RETURN .F.
				    ENDIF
				ENDIF  

				xCaracterInv = "¡…Õ”⁄·ÈÌÛ˙¿»Ã“Ÿ‡ËÏÚ˘¬ Œ‘€‚ÍÓÙ˚ƒÀœ÷‹‰ÎÔˆ¸√’„ı«Á—Ò∫"
				FOR x=1 TO LEN(xCaracterInv)
				    xCarac = SUBSTR(xCaracterInv ,x,1)
				    IF xCarac $ ALLTRIM(v_FORNECEDORES_01.NOME_CLIFOR)
					   MESSAGEBOX("N„o pode Salvar Fornecedor com Acento!!", 0+64, "OBJ - FORNECEDOR COM ACENTO")
					   RETURN .F.
				    ENDIF
				ENDFOR
				SELECT &lcAlias 
             ENDIF 
		OTHERWISE
			RETURN .t.
	ENDCASE
	ENDPROC
ENDDEFINE

DEFINE CLASS txt_Id_Oracle as textbox

	Top=10
	left=266
	width=132
	height=22
	controlsource="V_FORNECEDORES_01.EBS_ID_FORNECEDOR"
	readonly = .F.
	visible=.t.
	
*!*		PROCEDURE WHEN

*!*			RETURN .F.		
*!*			
*!*		ENDPROC

	PROCEDURE refresh
		** Inclus„o/AlteraÁ„o/Exclus„o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","L")
	ENDPROC

ENDDEFINE
