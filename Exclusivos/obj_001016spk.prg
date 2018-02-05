define class obj_entrada as custom
	procedure metodo_usuario
	lparam xmetodo, xobjeto ,xnome_obj
	DO CASE
		CASE UPPER(xmetodo) == 'USR_INIT'	
			WAIT WINDOW 'OBJ' NOWAIT


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
