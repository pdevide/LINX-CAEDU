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
	*- Nome do metodo/fun��o que os objetos linx v�o chamar.
	procedure metodo_usuario

		lparam xmetodo, xobjeto ,xnome_obj



		do case
			case UPPER(xmetodo) == 'USR_INIT'
			

     		Create Cursor xUserSenha(usuario Varchar(25), motivo Varchar(25))
     		
			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.SelectCmd TextMerge NoShow
			SELECT PRODUTOS_TAMANHOS.GRADE, PRODUTOS_TAMANHOS.NUMERO_QUEBRAS,  PRODUTOS_TAMANHOS.NUMERO_TAMANHOS,  PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, PRODUTOS_TAMANHOS.QUEBRA_1,  PRODUTOS_TAMANHOS.QUEBRA_2,
			 PRODUTOS_TAMANHOS.QUEBRA_3,  PRODUTOS_TAMANHOS.QUEBRA_4, PRODUTOS_TAMANHOS.QUEBRA_5,  PRODUTOS_TAMANHOS.TAMANHO_1, PRODUTOS_TAMANHOS.TAMANHO_2,  PRODUTOS_TAMANHOS.TAMANHO_3,
			  PRODUTOS_TAMANHOS.TAMANHO_4,  PRODUTOS_TAMANHOS.TAMANHO_5, PRODUTOS_TAMANHOS.TAMANHO_6,  PRODUTOS_TAMANHOS.TAMANHO_7, PRODUTOS_TAMANHOS.TAMANHO_8,  PRODUTOS_TAMANHOS.TAMANHO_9,
			   PRODUTOS_TAMANHOS.TAMANHO_10,  PRODUTOS_TAMANHOS.TAMANHO_11, PRODUTOS_TAMANHOS.TAMANHO_12,  PRODUTOS_TAMANHOS.TAMANHO_13, PRODUTOS_TAMANHOS.TAMANHO_14,  PRODUTOS_TAMANHOS.TAMANHO_15, 
			   PRODUTOS_TAMANHOS.TAMANHO_16,  PRODUTOS_TAMANHOS.TAMANHO_17, PRODUTOS_TAMANHOS.TAMANHO_18,  PRODUTOS_TAMANHOS.TAMANHO_19, PRODUTOS_TAMANHOS.TAMANHO_20,  PRODUTOS_TAMANHOS.TAMANHO_21,
			    PRODUTOS_TAMANHOS.TAMANHO_22,  PRODUTOS_TAMANHOS.TAMANHO_23, PRODUTOS_TAMANHOS.TAMANHO_24,  PRODUTOS_TAMANHOS.TAMANHO_25, PRODUTOS_TAMANHOS.TAMANHO_26,  PRODUTOS_TAMANHOS.TAMANHO_27,
			    PRODUTOS_TAMANHOS.TAMANHO_28,  PRODUTOS_TAMANHOS.TAMANHO_29, 
			PRODUTOS_TAMANHOS.TAMANHO_30,  PRODUTOS_TAMANHOS.TAMANHO_31, PRODUTOS_TAMANHOS.TAMANHO_32,  PRODUTOS_TAMANHOS.TAMANHO_33, PRODUTOS_TAMANHOS.TAMANHO_34,  PRODUTOS_TAMANHOS.TAMANHO_35, 
			PRODUTOS_TAMANHOS.TAMANHO_36,  PRODUTOS_TAMANHOS.TAMANHO_37, PRODUTOS_TAMANHOS.TAMANHO_38,  PRODUTOS_TAMANHOS.TAMANHO_39, PRODUTOS_TAMANHOS.TAMANHO_40,  PRODUTOS_TAMANHOS.TAMANHO_41, 
			PRODUTOS_TAMANHOS.TAMANHO_42,  PRODUTOS_TAMANHOS.TAMANHO_43, PRODUTOS_TAMANHOS.TAMANHO_44,  PRODUTOS_TAMANHOS.TAMANHO_45, PRODUTOS_TAMANHOS.TAMANHO_46,  PRODUTOS_TAMANHOS.TAMANHO_47, 
			PRODUTOS_TAMANHOS.TAMANHO_48,  PRODUTOS_TAMANHOS.TIMESTAMP,  PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA,  PRODUTOS_TAMANHOS.GRADE_BASE,INATIVO FROM PRODUTOS_TAMANHOS PRODUTOS_TAMANHOS			
			EndText			

			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.UpdatableFieldlist TextMerge NoShow			
			GRADE, NUMERO_QUEBRAS, NUMERO_TAMANHOS, TAMANHOS_DIGITADOS, QUEBRA_1, QUEBRA_2, QUEBRA_3, QUEBRA_4, QUEBRA_5, 
			TAMANHO_1, TAMANHO_2, TAMANHO_3, TAMANHO_4, TAMANHO_5, TAMANHO_6, TAMANHO_7, TAMANHO_8, TAMANHO_9, TAMANHO_10, 
			TAMANHO_11, TAMANHO_12, TAMANHO_13, TAMANHO_14, TAMANHO_15, TAMANHO_16, TAMANHO_17, TAMANHO_18, TAMANHO_19, TAMANHO_20, 
			TAMANHO_21, TAMANHO_22, TAMANHO_23, TAMANHO_24, TAMANHO_25, TAMANHO_26, TAMANHO_27, TAMANHO_28, TAMANHO_29, TAMANHO_30, 
			TAMANHO_31, TAMANHO_32, TAMANHO_33, TAMANHO_34, TAMANHO_35, TAMANHO_36, TAMANHO_37, TAMANHO_38, TAMANHO_39, TAMANHO_40, 
			TAMANHO_41, TAMANHO_42, TAMANHO_43, TAMANHO_44, TAMANHO_45, TAMANHO_46, TAMANHO_47, TAMANHO_48, TIMESTAMP, DATA_PARA_TRANSFERENCIA, 
			GRADE_BASE, INATIVO
			ENDTEXT
			
			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.UpdateNamelist TextMerge NoShow						
			GRADE PRODUTOS_TAMANHOS.GRADE, NUMERO_QUEBRAS PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, NUMERO_TAMANHOS PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, TAMANHOS_DIGITADOS PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, QUEBRA_1 PRODUTOS_TAMANHOS.QUEBRA_1, QUEBRA_2 PRODUTOS_TAMANHOS.QUEBRA_2, QUEBRA_3 PRODUTOS_TAMANHOS.QUEBRA_3, QUEBRA_4 PRODUTOS_TAMANHOS.QUEBRA_4, QUEBRA_5 PRODUTOS_TAMANHOS.QUEBRA_5, 
			TAMANHO_1 PRODUTOS_TAMANHOS.TAMANHO_1, TAMANHO_2 PRODUTOS_TAMANHOS.TAMANHO_2, TAMANHO_3 PRODUTOS_TAMANHOS.TAMANHO_3, TAMANHO_4 PRODUTOS_TAMANHOS.TAMANHO_4, TAMANHO_5 PRODUTOS_TAMANHOS.TAMANHO_5, TAMANHO_6 PRODUTOS_TAMANHOS.TAMANHO_6, TAMANHO_7 PRODUTOS_TAMANHOS.TAMANHO_7, TAMANHO_8 PRODUTOS_TAMANHOS.TAMANHO_8, TAMANHO_9 PRODUTOS_TAMANHOS.TAMANHO_9, TAMANHO_10 PRODUTOS_TAMANHOS.TAMANHO_10, 
			TAMANHO_11 PRODUTOS_TAMANHOS.TAMANHO_11, TAMANHO_12 PRODUTOS_TAMANHOS.TAMANHO_12, TAMANHO_13 PRODUTOS_TAMANHOS.TAMANHO_13, TAMANHO_14 PRODUTOS_TAMANHOS.TAMANHO_14, TAMANHO_15 PRODUTOS_TAMANHOS.TAMANHO_15, TAMANHO_16 PRODUTOS_TAMANHOS.TAMANHO_16, TAMANHO_17 PRODUTOS_TAMANHOS.TAMANHO_17, TAMANHO_18 PRODUTOS_TAMANHOS.TAMANHO_18, TAMANHO_19 PRODUTOS_TAMANHOS.TAMANHO_19, TAMANHO_20 PRODUTOS_TAMANHOS.TAMANHO_20, 
			TAMANHO_21 PRODUTOS_TAMANHOS.TAMANHO_21, TAMANHO_22 PRODUTOS_TAMANHOS.TAMANHO_22, TAMANHO_23 PRODUTOS_TAMANHOS.TAMANHO_23, TAMANHO_24 PRODUTOS_TAMANHOS.TAMANHO_24, TAMANHO_25 PRODUTOS_TAMANHOS.TAMANHO_25, TAMANHO_26 PRODUTOS_TAMANHOS.TAMANHO_26, TAMANHO_27 PRODUTOS_TAMANHOS.TAMANHO_27, TAMANHO_28 PRODUTOS_TAMANHOS.TAMANHO_28, TAMANHO_29 PRODUTOS_TAMANHOS.TAMANHO_29, TAMANHO_30 PRODUTOS_TAMANHOS.TAMANHO_30, 
			TAMANHO_31 PRODUTOS_TAMANHOS.TAMANHO_31, TAMANHO_32 PRODUTOS_TAMANHOS.TAMANHO_32, TAMANHO_33 PRODUTOS_TAMANHOS.TAMANHO_33, TAMANHO_34 PRODUTOS_TAMANHOS.TAMANHO_34, TAMANHO_35 PRODUTOS_TAMANHOS.TAMANHO_35, TAMANHO_36 PRODUTOS_TAMANHOS.TAMANHO_36, TAMANHO_37 PRODUTOS_TAMANHOS.TAMANHO_37, TAMANHO_38 PRODUTOS_TAMANHOS.TAMANHO_38, TAMANHO_39 PRODUTOS_TAMANHOS.TAMANHO_39, TAMANHO_40 PRODUTOS_TAMANHOS.TAMANHO_40, 
			TAMANHO_41 PRODUTOS_TAMANHOS.TAMANHO_41, TAMANHO_42 PRODUTOS_TAMANHOS.TAMANHO_42, TAMANHO_43 PRODUTOS_TAMANHOS.TAMANHO_43, TAMANHO_44 PRODUTOS_TAMANHOS.TAMANHO_44, TAMANHO_45 PRODUTOS_TAMANHOS.TAMANHO_45, TAMANHO_46 PRODUTOS_TAMANHOS.TAMANHO_46, TAMANHO_47 PRODUTOS_TAMANHOS.TAMANHO_47, TAMANHO_48 PRODUTOS_TAMANHOS.TAMANHO_48, TIMESTAMP PRODUTOS_TAMANHOS.TIMESTAMP, DATA_PARA_TRANSFERENCIA PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA, 
			GRADE_BASE PRODUTOS_TAMANHOS.GRADE_BASE,   INATIVO  PRODUTOS_TAMANHOS.INATIVO			
			ENDTEXT
			
			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.CaptionList TextMerge NoShow						
			GRADE Grade, NUMERO_QUEBRAS Numero Quebras, NUMERO_TAMANHOS Numero Tamanhos, TAMANHOS_DIGITADOS Tamanhos Digitados, QUEBRA_1 Quebra 1, QUEBRA_2 Quebra 2, QUEBRA_3 Quebra 3, QUEBRA_4 Quebra 4, QUEBRA_5 Quebra 5, TAMANHO_1 Tamanho 1, TAMANHO_2 Tamanho 2, TAMANHO_3 Tamanho 3, TAMANHO_4 Tamanho 4, TAMANHO_5 Tamanho 5, TAMANHO_6 Tamanho 6, TAMANHO_7 Tamanho 7, TAMANHO_8 Tamanho 8, TAMANHO_9 Tamanho 9, TAMANHO_10 Tamanho 10, TAMANHO_11 Tamanho 11, TAMANHO_12 Tamanho 12, TAMANHO_13 Tamanho 13, TAMANHO_14 Tamanho 14, TAMANHO_15 Tamanho 15, TAMANHO_16 Tamanho 16, TAMANHO_17 Tamanho 17, TAMANHO_18 Tamanho 18, TAMANHO_19 Tamanho 19, TAMANHO_20 Tamanho 20, TAMANHO_21 Tamanho 21, TAMANHO_22 Tamanho 22, TAMANHO_23 Tamanho 23, TAMANHO_24 Tamanho 24, TAMANHO_25 Tamanho 25, TAMANHO_26 Tamanho 26, TAMANHO_27 Tamanho 27, TAMANHO_28 Tamanho 28, TAMANHO_29 Tamanho 29, TAMANHO_30 Tamanho 30, TAMANHO_31 Tamanho 31, TAMANHO_32 Tamanho 32, TAMANHO_33 Tamanho 33, TAMANHO_34 Tamanho 34, TAMANHO_35 Tamanho 35, TAMANHO_36 Tamanho 36, TAMANHO_37 Tamanho 37, TAMANHO_38 Tamanho 38, TAMANHO_39 Tamanho 39, TAMANHO_40 Tamanho 40, TAMANHO_41 Tamanho 41, TAMANHO_42 Tamanho 42, TAMANHO_43 Tamanho 43, TAMANHO_44 Tamanho 44, TAMANHO_45 Tamanho 45, TAMANHO_46 Tamanho 46, TAMANHO_47 Tamanho 47, TAMANHO_48 Tamanho 48, TIMESTAMP Timestamp, DATA_PARA_TRANSFERENCIA Data Para Transferencia, GRADE_BASE Grade Base, INATIVO Inativo			
			ENDTEXT
			
			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.QueryList TextMerge NoShow						
			GRADE PRODUTOS_TAMANHOS.GRADE, NUMERO_QUEBRAS PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, NUMERO_TAMANHOS PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, TAMANHOS_DIGITADOS PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, QUEBRA_1 PRODUTOS_TAMANHOS.QUEBRA_1, QUEBRA_2 PRODUTOS_TAMANHOS.QUEBRA_2, QUEBRA_3 PRODUTOS_TAMANHOS.QUEBRA_3, QUEBRA_4 PRODUTOS_TAMANHOS.QUEBRA_4, QUEBRA_5 PRODUTOS_TAMANHOS.QUEBRA_5, 
			TAMANHO_1 PRODUTOS_TAMANHOS.TAMANHO_1, TAMANHO_2 PRODUTOS_TAMANHOS.TAMANHO_2, TAMANHO_3 PRODUTOS_TAMANHOS.TAMANHO_3, TAMANHO_4 PRODUTOS_TAMANHOS.TAMANHO_4, TAMANHO_5 PRODUTOS_TAMANHOS.TAMANHO_5, TAMANHO_6 PRODUTOS_TAMANHOS.TAMANHO_6, TAMANHO_7 PRODUTOS_TAMANHOS.TAMANHO_7, TAMANHO_8 PRODUTOS_TAMANHOS.TAMANHO_8, TAMANHO_9 PRODUTOS_TAMANHOS.TAMANHO_9, TAMANHO_10 PRODUTOS_TAMANHOS.TAMANHO_10, 
			TAMANHO_11 PRODUTOS_TAMANHOS.TAMANHO_11, TAMANHO_12 PRODUTOS_TAMANHOS.TAMANHO_12, TAMANHO_13 PRODUTOS_TAMANHOS.TAMANHO_13, TAMANHO_14 PRODUTOS_TAMANHOS.TAMANHO_14, TAMANHO_15 PRODUTOS_TAMANHOS.TAMANHO_15, TAMANHO_16 PRODUTOS_TAMANHOS.TAMANHO_16, TAMANHO_17 PRODUTOS_TAMANHOS.TAMANHO_17, TAMANHO_18 PRODUTOS_TAMANHOS.TAMANHO_18, TAMANHO_19 PRODUTOS_TAMANHOS.TAMANHO_19, TAMANHO_20 PRODUTOS_TAMANHOS.TAMANHO_20, 
			TAMANHO_21 PRODUTOS_TAMANHOS.TAMANHO_21, TAMANHO_22 PRODUTOS_TAMANHOS.TAMANHO_22, TAMANHO_23 PRODUTOS_TAMANHOS.TAMANHO_23, TAMANHO_24 PRODUTOS_TAMANHOS.TAMANHO_24, TAMANHO_25 PRODUTOS_TAMANHOS.TAMANHO_25, TAMANHO_26 PRODUTOS_TAMANHOS.TAMANHO_26, TAMANHO_27 PRODUTOS_TAMANHOS.TAMANHO_27, TAMANHO_28 PRODUTOS_TAMANHOS.TAMANHO_28, TAMANHO_29 PRODUTOS_TAMANHOS.TAMANHO_29, TAMANHO_30 PRODUTOS_TAMANHOS.TAMANHO_30, 
			TAMANHO_31 PRODUTOS_TAMANHOS.TAMANHO_31, TAMANHO_32 PRODUTOS_TAMANHOS.TAMANHO_32, TAMANHO_33 PRODUTOS_TAMANHOS.TAMANHO_33, TAMANHO_34 PRODUTOS_TAMANHOS.TAMANHO_34, TAMANHO_35 PRODUTOS_TAMANHOS.TAMANHO_35, TAMANHO_36 PRODUTOS_TAMANHOS.TAMANHO_36, TAMANHO_37 PRODUTOS_TAMANHOS.TAMANHO_37, TAMANHO_38 PRODUTOS_TAMANHOS.TAMANHO_38, TAMANHO_39 PRODUTOS_TAMANHOS.TAMANHO_39, TAMANHO_40 PRODUTOS_TAMANHOS.TAMANHO_40, 
			TAMANHO_41 PRODUTOS_TAMANHOS.TAMANHO_41, TAMANHO_42 PRODUTOS_TAMANHOS.TAMANHO_42, TAMANHO_43 PRODUTOS_TAMANHOS.TAMANHO_43, TAMANHO_44 PRODUTOS_TAMANHOS.TAMANHO_44, TAMANHO_45 PRODUTOS_TAMANHOS.TAMANHO_45, TAMANHO_46 PRODUTOS_TAMANHOS.TAMANHO_46, TAMANHO_47 PRODUTOS_TAMANHOS.TAMANHO_47, TAMANHO_48 PRODUTOS_TAMANHOS.TAMANHO_48, TIMESTAMP PRODUTOS_TAMANHOS.TIMESTAMP, DATA_PARA_TRANSFERENCIA PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA, 
			GRADE_BASE PRODUTOS_TAMANHOS.GRADE_BASE, INATIVO INATIVO			
			ENDTEXT

			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.Cursorschema TextMerge NoShow						
			GRADE C(25), NUMERO_QUEBRAS I, NUMERO_TAMANHOS I, TAMANHOS_DIGITADOS I, QUEBRA_1 C(1), QUEBRA_2 C(1), QUEBRA_3 C(1), QUEBRA_4 C(1), QUEBRA_5 C(1), TAMANHO_1 C(8), TAMANHO_2 C(8), TAMANHO_3 C(8), TAMANHO_4 C(8), TAMANHO_5 C(8), TAMANHO_6 C(8), TAMANHO_7 C(8), TAMANHO_8 C(8), TAMANHO_9 C(8), TAMANHO_10 C(8), TAMANHO_11 C(8), TAMANHO_12 C(8), TAMANHO_13 C(8), TAMANHO_14 C(8), TAMANHO_15 C(8), TAMANHO_16 C(8), TAMANHO_17 C(8), TAMANHO_18 C(8), TAMANHO_19 C(8), TAMANHO_20 C(8), TAMANHO_21 C(8), TAMANHO_22 C(8), TAMANHO_23 C(8), TAMANHO_24 C(8), TAMANHO_25 C(8), TAMANHO_26 C(8), TAMANHO_27 C(8), TAMANHO_28 C(8), TAMANHO_29 C(8), TAMANHO_30 C(8), TAMANHO_31 C(8), TAMANHO_32 C(8), TAMANHO_33 C(8), TAMANHO_34 C(8), TAMANHO_35 C(8), TAMANHO_36 C(8), TAMANHO_37 C(8), TAMANHO_38 C(8), TAMANHO_39 C(8), TAMANHO_40 C(8), TAMANHO_41 C(8), TAMANHO_42 C(8), TAMANHO_43 C(8), TAMANHO_44 C(8), TAMANHO_45 C(8), TAMANHO_46 C(8), TAMANHO_47 C(8), TAMANHO_48 C(8), TIMESTAMP M, DATA_PARA_TRANSFERENCIA D, GRADE_BASE C(25), INATIVO L			
            endtext 
						

				*thisformset.lx_form1.addobject('bt_copia', 'bt_estfilial')
			thisformset.lx_FORM1.addobject('CHKINATIVO', 'chk_inativo')
			
   		case UPPER(xmetodo) == 'USR_INCLUDE_AFTER'
   		
			Replace Inativo WITH .T. IN v_produtos_tamanho_00
			
			ThisFormSet.LX_FORM1.CHkinativo.REFRESH
			
			ThisFormSet.LX_FORM1.REFRESH()
						
			
   		case UPPER(xmetodo) == 'USR_SEARCH_BEFORE'

			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.SelectCmd TextMerge NoShow
			SELECT PRODUTOS_TAMANHOS.GRADE, PRODUTOS_TAMANHOS.NUMERO_QUEBRAS,  PRODUTOS_TAMANHOS.NUMERO_TAMANHOS,  PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, PRODUTOS_TAMANHOS.QUEBRA_1,  PRODUTOS_TAMANHOS.QUEBRA_2,
			 PRODUTOS_TAMANHOS.QUEBRA_3,  PRODUTOS_TAMANHOS.QUEBRA_4, PRODUTOS_TAMANHOS.QUEBRA_5,  PRODUTOS_TAMANHOS.TAMANHO_1, PRODUTOS_TAMANHOS.TAMANHO_2,  PRODUTOS_TAMANHOS.TAMANHO_3,
			  PRODUTOS_TAMANHOS.TAMANHO_4,  PRODUTOS_TAMANHOS.TAMANHO_5, PRODUTOS_TAMANHOS.TAMANHO_6,  PRODUTOS_TAMANHOS.TAMANHO_7, PRODUTOS_TAMANHOS.TAMANHO_8,  PRODUTOS_TAMANHOS.TAMANHO_9,
			   PRODUTOS_TAMANHOS.TAMANHO_10,  PRODUTOS_TAMANHOS.TAMANHO_11, PRODUTOS_TAMANHOS.TAMANHO_12,  PRODUTOS_TAMANHOS.TAMANHO_13, PRODUTOS_TAMANHOS.TAMANHO_14,  PRODUTOS_TAMANHOS.TAMANHO_15, 
			   PRODUTOS_TAMANHOS.TAMANHO_16,  PRODUTOS_TAMANHOS.TAMANHO_17, PRODUTOS_TAMANHOS.TAMANHO_18,  PRODUTOS_TAMANHOS.TAMANHO_19, PRODUTOS_TAMANHOS.TAMANHO_20,  PRODUTOS_TAMANHOS.TAMANHO_21,
			    PRODUTOS_TAMANHOS.TAMANHO_22,  PRODUTOS_TAMANHOS.TAMANHO_23, PRODUTOS_TAMANHOS.TAMANHO_24,  PRODUTOS_TAMANHOS.TAMANHO_25, PRODUTOS_TAMANHOS.TAMANHO_26,  PRODUTOS_TAMANHOS.TAMANHO_27,
			    PRODUTOS_TAMANHOS.TAMANHO_28,  PRODUTOS_TAMANHOS.TAMANHO_29, 
			PRODUTOS_TAMANHOS.TAMANHO_30,  PRODUTOS_TAMANHOS.TAMANHO_31, PRODUTOS_TAMANHOS.TAMANHO_32,  PRODUTOS_TAMANHOS.TAMANHO_33, PRODUTOS_TAMANHOS.TAMANHO_34,  PRODUTOS_TAMANHOS.TAMANHO_35, 
			PRODUTOS_TAMANHOS.TAMANHO_36,  PRODUTOS_TAMANHOS.TAMANHO_37, PRODUTOS_TAMANHOS.TAMANHO_38,  PRODUTOS_TAMANHOS.TAMANHO_39, PRODUTOS_TAMANHOS.TAMANHO_40,  PRODUTOS_TAMANHOS.TAMANHO_41, 
			PRODUTOS_TAMANHOS.TAMANHO_42,  PRODUTOS_TAMANHOS.TAMANHO_43, PRODUTOS_TAMANHOS.TAMANHO_44,  PRODUTOS_TAMANHOS.TAMANHO_45, PRODUTOS_TAMANHOS.TAMANHO_46,  PRODUTOS_TAMANHOS.TAMANHO_47, 
			PRODUTOS_TAMANHOS.TAMANHO_48,  PRODUTOS_TAMANHOS.TIMESTAMP,  PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA,  PRODUTOS_TAMANHOS.GRADE_BASE,INATIVO FROM PRODUTOS_TAMANHOS PRODUTOS_TAMANHOS			
			EndText			

			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.UpdatableFieldlist TextMerge NoShow			
			GRADE, NUMERO_QUEBRAS, NUMERO_TAMANHOS, TAMANHOS_DIGITADOS, QUEBRA_1, QUEBRA_2, QUEBRA_3, QUEBRA_4, QUEBRA_5, 
			TAMANHO_1, TAMANHO_2, TAMANHO_3, TAMANHO_4, TAMANHO_5, TAMANHO_6, TAMANHO_7, TAMANHO_8, TAMANHO_9, TAMANHO_10, 
			TAMANHO_11, TAMANHO_12, TAMANHO_13, TAMANHO_14, TAMANHO_15, TAMANHO_16, TAMANHO_17, TAMANHO_18, TAMANHO_19, TAMANHO_20, 
			TAMANHO_21, TAMANHO_22, TAMANHO_23, TAMANHO_24, TAMANHO_25, TAMANHO_26, TAMANHO_27, TAMANHO_28, TAMANHO_29, TAMANHO_30, 
			TAMANHO_31, TAMANHO_32, TAMANHO_33, TAMANHO_34, TAMANHO_35, TAMANHO_36, TAMANHO_37, TAMANHO_38, TAMANHO_39, TAMANHO_40, 
			TAMANHO_41, TAMANHO_42, TAMANHO_43, TAMANHO_44, TAMANHO_45, TAMANHO_46, TAMANHO_47, TAMANHO_48, TIMESTAMP, DATA_PARA_TRANSFERENCIA, 
			GRADE_BASE, INATIVO
			ENDTEXT
			
			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.UpdateNamelist TextMerge NoShow						
			GRADE PRODUTOS_TAMANHOS.GRADE, NUMERO_QUEBRAS PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, NUMERO_TAMANHOS PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, TAMANHOS_DIGITADOS PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, QUEBRA_1 PRODUTOS_TAMANHOS.QUEBRA_1, QUEBRA_2 PRODUTOS_TAMANHOS.QUEBRA_2, QUEBRA_3 PRODUTOS_TAMANHOS.QUEBRA_3, QUEBRA_4 PRODUTOS_TAMANHOS.QUEBRA_4, QUEBRA_5 PRODUTOS_TAMANHOS.QUEBRA_5, 
			TAMANHO_1 PRODUTOS_TAMANHOS.TAMANHO_1, TAMANHO_2 PRODUTOS_TAMANHOS.TAMANHO_2, TAMANHO_3 PRODUTOS_TAMANHOS.TAMANHO_3, TAMANHO_4 PRODUTOS_TAMANHOS.TAMANHO_4, TAMANHO_5 PRODUTOS_TAMANHOS.TAMANHO_5, TAMANHO_6 PRODUTOS_TAMANHOS.TAMANHO_6, TAMANHO_7 PRODUTOS_TAMANHOS.TAMANHO_7, TAMANHO_8 PRODUTOS_TAMANHOS.TAMANHO_8, TAMANHO_9 PRODUTOS_TAMANHOS.TAMANHO_9, TAMANHO_10 PRODUTOS_TAMANHOS.TAMANHO_10, 
			TAMANHO_11 PRODUTOS_TAMANHOS.TAMANHO_11, TAMANHO_12 PRODUTOS_TAMANHOS.TAMANHO_12, TAMANHO_13 PRODUTOS_TAMANHOS.TAMANHO_13, TAMANHO_14 PRODUTOS_TAMANHOS.TAMANHO_14, TAMANHO_15 PRODUTOS_TAMANHOS.TAMANHO_15, TAMANHO_16 PRODUTOS_TAMANHOS.TAMANHO_16, TAMANHO_17 PRODUTOS_TAMANHOS.TAMANHO_17, TAMANHO_18 PRODUTOS_TAMANHOS.TAMANHO_18, TAMANHO_19 PRODUTOS_TAMANHOS.TAMANHO_19, TAMANHO_20 PRODUTOS_TAMANHOS.TAMANHO_20, 
			TAMANHO_21 PRODUTOS_TAMANHOS.TAMANHO_21, TAMANHO_22 PRODUTOS_TAMANHOS.TAMANHO_22, TAMANHO_23 PRODUTOS_TAMANHOS.TAMANHO_23, TAMANHO_24 PRODUTOS_TAMANHOS.TAMANHO_24, TAMANHO_25 PRODUTOS_TAMANHOS.TAMANHO_25, TAMANHO_26 PRODUTOS_TAMANHOS.TAMANHO_26, TAMANHO_27 PRODUTOS_TAMANHOS.TAMANHO_27, TAMANHO_28 PRODUTOS_TAMANHOS.TAMANHO_28, TAMANHO_29 PRODUTOS_TAMANHOS.TAMANHO_29, TAMANHO_30 PRODUTOS_TAMANHOS.TAMANHO_30, 
			TAMANHO_31 PRODUTOS_TAMANHOS.TAMANHO_31, TAMANHO_32 PRODUTOS_TAMANHOS.TAMANHO_32, TAMANHO_33 PRODUTOS_TAMANHOS.TAMANHO_33, TAMANHO_34 PRODUTOS_TAMANHOS.TAMANHO_34, TAMANHO_35 PRODUTOS_TAMANHOS.TAMANHO_35, TAMANHO_36 PRODUTOS_TAMANHOS.TAMANHO_36, TAMANHO_37 PRODUTOS_TAMANHOS.TAMANHO_37, TAMANHO_38 PRODUTOS_TAMANHOS.TAMANHO_38, TAMANHO_39 PRODUTOS_TAMANHOS.TAMANHO_39, TAMANHO_40 PRODUTOS_TAMANHOS.TAMANHO_40, 
			TAMANHO_41 PRODUTOS_TAMANHOS.TAMANHO_41, TAMANHO_42 PRODUTOS_TAMANHOS.TAMANHO_42, TAMANHO_43 PRODUTOS_TAMANHOS.TAMANHO_43, TAMANHO_44 PRODUTOS_TAMANHOS.TAMANHO_44, TAMANHO_45 PRODUTOS_TAMANHOS.TAMANHO_45, TAMANHO_46 PRODUTOS_TAMANHOS.TAMANHO_46, TAMANHO_47 PRODUTOS_TAMANHOS.TAMANHO_47, TAMANHO_48 PRODUTOS_TAMANHOS.TAMANHO_48, TIMESTAMP PRODUTOS_TAMANHOS.TIMESTAMP, DATA_PARA_TRANSFERENCIA PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA, 
			GRADE_BASE PRODUTOS_TAMANHOS.GRADE_BASE,   INATIVO  PRODUTOS_TAMANHOS.INATIVO			
			ENDTEXT
			
			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.CaptionList TextMerge NoShow						
			GRADE Grade, NUMERO_QUEBRAS Numero Quebras, NUMERO_TAMANHOS Numero Tamanhos, TAMANHOS_DIGITADOS Tamanhos Digitados, QUEBRA_1 Quebra 1, QUEBRA_2 Quebra 2, QUEBRA_3 Quebra 3, QUEBRA_4 Quebra 4, QUEBRA_5 Quebra 5, TAMANHO_1 Tamanho 1, TAMANHO_2 Tamanho 2, TAMANHO_3 Tamanho 3, TAMANHO_4 Tamanho 4, TAMANHO_5 Tamanho 5, TAMANHO_6 Tamanho 6, TAMANHO_7 Tamanho 7, TAMANHO_8 Tamanho 8, TAMANHO_9 Tamanho 9, TAMANHO_10 Tamanho 10, TAMANHO_11 Tamanho 11, TAMANHO_12 Tamanho 12, TAMANHO_13 Tamanho 13, TAMANHO_14 Tamanho 14, TAMANHO_15 Tamanho 15, TAMANHO_16 Tamanho 16, TAMANHO_17 Tamanho 17, TAMANHO_18 Tamanho 18, TAMANHO_19 Tamanho 19, TAMANHO_20 Tamanho 20, TAMANHO_21 Tamanho 21, TAMANHO_22 Tamanho 22, TAMANHO_23 Tamanho 23, TAMANHO_24 Tamanho 24, TAMANHO_25 Tamanho 25, TAMANHO_26 Tamanho 26, TAMANHO_27 Tamanho 27, TAMANHO_28 Tamanho 28, TAMANHO_29 Tamanho 29, TAMANHO_30 Tamanho 30, TAMANHO_31 Tamanho 31, TAMANHO_32 Tamanho 32, TAMANHO_33 Tamanho 33, TAMANHO_34 Tamanho 34, TAMANHO_35 Tamanho 35, TAMANHO_36 Tamanho 36, TAMANHO_37 Tamanho 37, TAMANHO_38 Tamanho 38, TAMANHO_39 Tamanho 39, TAMANHO_40 Tamanho 40, TAMANHO_41 Tamanho 41, TAMANHO_42 Tamanho 42, TAMANHO_43 Tamanho 43, TAMANHO_44 Tamanho 44, TAMANHO_45 Tamanho 45, TAMANHO_46 Tamanho 46, TAMANHO_47 Tamanho 47, TAMANHO_48 Tamanho 48, TIMESTAMP Timestamp, DATA_PARA_TRANSFERENCIA Data Para Transferencia, GRADE_BASE Grade Base, INATIVO Inativo			
			ENDTEXT
			
			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.QueryList TextMerge NoShow						
			GRADE PRODUTOS_TAMANHOS.GRADE, NUMERO_QUEBRAS PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, NUMERO_TAMANHOS PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, TAMANHOS_DIGITADOS PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, QUEBRA_1 PRODUTOS_TAMANHOS.QUEBRA_1, QUEBRA_2 PRODUTOS_TAMANHOS.QUEBRA_2, QUEBRA_3 PRODUTOS_TAMANHOS.QUEBRA_3, QUEBRA_4 PRODUTOS_TAMANHOS.QUEBRA_4, QUEBRA_5 PRODUTOS_TAMANHOS.QUEBRA_5, 
			TAMANHO_1 PRODUTOS_TAMANHOS.TAMANHO_1, TAMANHO_2 PRODUTOS_TAMANHOS.TAMANHO_2, TAMANHO_3 PRODUTOS_TAMANHOS.TAMANHO_3, TAMANHO_4 PRODUTOS_TAMANHOS.TAMANHO_4, TAMANHO_5 PRODUTOS_TAMANHOS.TAMANHO_5, TAMANHO_6 PRODUTOS_TAMANHOS.TAMANHO_6, TAMANHO_7 PRODUTOS_TAMANHOS.TAMANHO_7, TAMANHO_8 PRODUTOS_TAMANHOS.TAMANHO_8, TAMANHO_9 PRODUTOS_TAMANHOS.TAMANHO_9, TAMANHO_10 PRODUTOS_TAMANHOS.TAMANHO_10, 
			TAMANHO_11 PRODUTOS_TAMANHOS.TAMANHO_11, TAMANHO_12 PRODUTOS_TAMANHOS.TAMANHO_12, TAMANHO_13 PRODUTOS_TAMANHOS.TAMANHO_13, TAMANHO_14 PRODUTOS_TAMANHOS.TAMANHO_14, TAMANHO_15 PRODUTOS_TAMANHOS.TAMANHO_15, TAMANHO_16 PRODUTOS_TAMANHOS.TAMANHO_16, TAMANHO_17 PRODUTOS_TAMANHOS.TAMANHO_17, TAMANHO_18 PRODUTOS_TAMANHOS.TAMANHO_18, TAMANHO_19 PRODUTOS_TAMANHOS.TAMANHO_19, TAMANHO_20 PRODUTOS_TAMANHOS.TAMANHO_20, 
			TAMANHO_21 PRODUTOS_TAMANHOS.TAMANHO_21, TAMANHO_22 PRODUTOS_TAMANHOS.TAMANHO_22, TAMANHO_23 PRODUTOS_TAMANHOS.TAMANHO_23, TAMANHO_24 PRODUTOS_TAMANHOS.TAMANHO_24, TAMANHO_25 PRODUTOS_TAMANHOS.TAMANHO_25, TAMANHO_26 PRODUTOS_TAMANHOS.TAMANHO_26, TAMANHO_27 PRODUTOS_TAMANHOS.TAMANHO_27, TAMANHO_28 PRODUTOS_TAMANHOS.TAMANHO_28, TAMANHO_29 PRODUTOS_TAMANHOS.TAMANHO_29, TAMANHO_30 PRODUTOS_TAMANHOS.TAMANHO_30, 
			TAMANHO_31 PRODUTOS_TAMANHOS.TAMANHO_31, TAMANHO_32 PRODUTOS_TAMANHOS.TAMANHO_32, TAMANHO_33 PRODUTOS_TAMANHOS.TAMANHO_33, TAMANHO_34 PRODUTOS_TAMANHOS.TAMANHO_34, TAMANHO_35 PRODUTOS_TAMANHOS.TAMANHO_35, TAMANHO_36 PRODUTOS_TAMANHOS.TAMANHO_36, TAMANHO_37 PRODUTOS_TAMANHOS.TAMANHO_37, TAMANHO_38 PRODUTOS_TAMANHOS.TAMANHO_38, TAMANHO_39 PRODUTOS_TAMANHOS.TAMANHO_39, TAMANHO_40 PRODUTOS_TAMANHOS.TAMANHO_40, 
			TAMANHO_41 PRODUTOS_TAMANHOS.TAMANHO_41, TAMANHO_42 PRODUTOS_TAMANHOS.TAMANHO_42, TAMANHO_43 PRODUTOS_TAMANHOS.TAMANHO_43, TAMANHO_44 PRODUTOS_TAMANHOS.TAMANHO_44, TAMANHO_45 PRODUTOS_TAMANHOS.TAMANHO_45, TAMANHO_46 PRODUTOS_TAMANHOS.TAMANHO_46, TAMANHO_47 PRODUTOS_TAMANHOS.TAMANHO_47, TAMANHO_48 PRODUTOS_TAMANHOS.TAMANHO_48, TIMESTAMP PRODUTOS_TAMANHOS.TIMESTAMP, DATA_PARA_TRANSFERENCIA PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA, 
			GRADE_BASE PRODUTOS_TAMANHOS.GRADE_BASE, INATIVO INATIVO			
			ENDTEXT

			Text TO  thisformset.dataenvironment.cur_v_produtos_tamanho_00.Cursorschema TextMerge NoShow						
			GRADE C(25), NUMERO_QUEBRAS I, NUMERO_TAMANHOS I, TAMANHOS_DIGITADOS I, QUEBRA_1 C(1), QUEBRA_2 C(1), QUEBRA_3 C(1), QUEBRA_4 C(1), QUEBRA_5 C(1), TAMANHO_1 C(8), TAMANHO_2 C(8), TAMANHO_3 C(8), TAMANHO_4 C(8), TAMANHO_5 C(8), TAMANHO_6 C(8), TAMANHO_7 C(8), TAMANHO_8 C(8), TAMANHO_9 C(8), TAMANHO_10 C(8), TAMANHO_11 C(8), TAMANHO_12 C(8), TAMANHO_13 C(8), TAMANHO_14 C(8), TAMANHO_15 C(8), TAMANHO_16 C(8), TAMANHO_17 C(8), TAMANHO_18 C(8), TAMANHO_19 C(8), TAMANHO_20 C(8), TAMANHO_21 C(8), TAMANHO_22 C(8), TAMANHO_23 C(8), TAMANHO_24 C(8), TAMANHO_25 C(8), TAMANHO_26 C(8), TAMANHO_27 C(8), TAMANHO_28 C(8), TAMANHO_29 C(8), TAMANHO_30 C(8), TAMANHO_31 C(8), TAMANHO_32 C(8), TAMANHO_33 C(8), TAMANHO_34 C(8), TAMANHO_35 C(8), TAMANHO_36 C(8), TAMANHO_37 C(8), TAMANHO_38 C(8), TAMANHO_39 C(8), TAMANHO_40 C(8), TAMANHO_41 C(8), TAMANHO_42 C(8), TAMANHO_43 C(8), TAMANHO_44 C(8), TAMANHO_45 C(8), TAMANHO_46 C(8), TAMANHO_47 C(8), TAMANHO_48 C(8), TIMESTAMP M, DATA_PARA_TRANSFERENCIA D, GRADE_BASE C(25), INATIVO L			
            endtext 
			
			


	   		case UPPER(xmetodo) == 'USR_VALID'			
			
		    ****thisformset.dataenvironment.cur_v_produtos_tamanho_00.Query()
		    
		    
*!*	   			IF 'INATIVO'$UPPER(xnome_obj)
*!*	   			
*!*					If InList(ThisFormSet.p_Tool_Status, "I", "A")
*!*					
*!*						Local inppass
*!*						*	Password (masked)
*!*						inppass = rbInputBox2( "Senha", "SENHA de [DIRETOR]", "", , , "!", , "*")
*!*						inppass = Alltrim(inppass)
*!*						ll_senha_OK  = .F.


*!*						**** senha do diretor ****
*!*						TEXT TO lcsql noshow
*!*						 				  SELECT par.usuario FROM  PARAMETROS_USERS par
*!*							   	     	  WHERE parametro like 'PALMA_DIRETOR_CPA_ENT'
*!*				   		   		     	  and usuario like ?xUserSenha.usuario
*!*						ENDTEXT

*!*						If Used("x_Diretor")
*!*							Use In x_Diretor
*!*						Endif

*!*						f_select(lcsql,"x_Diretor")


*!*						If Reccount("x_Diretor") = 0
*!*							Messagebox("Usuario sem permiss�o de [diretor] p/ liberar altera��o!",16,"Avisos")
*!*							Return .F.
*!*						Endif

*!*						Select x_Diretor
*!*						Scan

*!*							lc_usuario = Alltrim(x_Diretor.usuario)
*!*							f_select("select passw from users where usuario like ?lc_usuario ", 'X_CURSENHALINX')

*!*							If UPPER(inppass) = UPPER(F_DS_CR(Alltrim(X_CURSENHALINX.Passw)))
*!*								ll_senha_OK = .T.
*!*							ENDIF
*!*							SELECT x_Diretor

*!*						Endscan

*!*						If !ll_senha_OK
*!*							Messagebox("Senha n�o confere com Diretores cadastrados!!!",16,"Aten��o")
*!*							
*!*							xobjeto.value = !xobjeto.value
*!*							
*!*							Return .F.
*!*						Endif
*!*						
*!*					ENDIF			
*!*					
*!*				ENDIF	
		    
		
		
			IF 'TX_TAMANHO_'$UPPER(xnome_obj)
			    		IF  ThisFormSet.p_tool_status $ 'I'

		*!*				FOR IND1 = 1 TO 48

		*!*					pDescTamanho = "V_PRODUTOS_TAMANHO_00.TAMANHO_"+ALLTRIM(PADR(IND1,2," "))
		*!*					 
					    
					      
					        
							pDescTamanho = 	xobjeto.Value 				    
							FOR IND = 1 TO LEN(ALLTRIM(pDescTamanho))
							  
							  
							    lc_var =  SUBSTR(ALLTRIM(pDescTamanho),IND,1)    

								IF  !(lc_var $ 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.')

									F_Msg(["A utiliza��o de caracter especial '"+ lc_var + "' na descri��o do tamanho � Inv�lida. Utilize outro valor!", 0+48, "Aten��o"])
									Return .F.
								
								ENDIF
								
					      	ENDFOR
							
							
					***ENDFOR
						
					ENDIF
			ENDIF
    
		
   													
		
		
   		case UPPER(xmetodo) == 'USR_ALTER_AFTER'		    

			If InList(ThisFormSet.p_Tool_Status, "I", "A")
				ThisFormSet.LX_FORM1.CHkinativo.Enabled = .T. 
			eNDIF			
			
		otherwise
				return .t.
		ENDCASE
		
	ENDPROC
	
enddefine




DEFINE CLASS chk_inativo as lx_checkbox

    controlsource = "v_produtos_tamanho_00.inativo"
	caption = 'Inativo'
	autosize = .T.
	backstyle =0
	alignment = 0
	WIDTH = 100
	top = 28
	left = 567
	HEIGHT =  27
	enabled = .T.
	visible  = .T.
	backcolor =  RGB(240,240,240)


	Procedure InteractiveChange
	
	  
   			
				If InList(ThisFormSet.p_Tool_Status, "I", "A")
				

				   
				   llHabilita_old = ThisFormSet.LX_FORM1.CHkinativo.value
				   

                    IF !This.Value
                      lc_messagebox = "Deseja [ATIVAR] esta grade?"  
                    ELSE
                      lc_messagebox = "Deseja [DESABILITAR/INATIVAR] esta grade?"    
                    ENDIF
                    
   		
                    
                    IF MESSAGEBOX(lc_messagebox,4+32+256,"Confirma") != 6
 					   ThisFormSet.LX_FORM1.CHkinativo.value = !llHabilita_old
                      RETURN .F.
                    Endif

					Select xUserSenha
					Zap
					Append Blank
						
				
					Local inppass
					*	Password (masked)
					inppass = rbInputBox2( "Senha", "SENHA de [DIRETOR]", "", , , "!", , "*")
					inppass = Alltrim(inppass)
					ll_senha_OK  = .F.


					**** senha do diretor ****
					TEXT TO lcsql noshow
					 				  SELECT par.usuario FROM  PARAMETROS_USERS par
						   	     	  WHERE parametro like 'PALMA_DIRETOR_CPA_ENT'
			   		   		     	  and usuario like ?xUserSenha.usuario
					ENDTEXT

					If Used("x_Diretor")
						Use In x_Diretor
					Endif

					f_select(lcsql,"x_Diretor")
                 
                 

					If Reccount("x_Diretor") = 0
						Messagebox("Usuario sem permiss�o de [diretor] p/ liberar altera��o!",16,"Avisos")
						ThisFormSet.LX_FORM1.CHkinativo.value= !llHabilita_old 
						Return .F.
					Endif

					Select x_Diretor
					Scan

						lc_usuario = Alltrim(x_Diretor.usuario)
						f_select("select passw from users where usuario like ?lc_usuario ", 'X_CURSENHALINX')

						If UPPER(inppass) = UPPER(F_DS_CR(Alltrim(X_CURSENHALINX.Passw)))
							ll_senha_OK = .T.
						ENDIF
						SELECT x_Diretor

					ENDSCAN
					
					

					If !ll_senha_OK
					
						Messagebox("Senha n�o confere com Diretores cadastrados!!!",16,"Aten��o")
						ThisFormSet.LX_FORM1.CHkinativo.value = !llHabilita_old 
						
						Return .F.
					ENDIF
					
					
					
				ENDIF		
	
	
	Endproc

	
	
ENDDEFINE



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





**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
Define Class rbInputBox2 As Form


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


	Add Object lbluser As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Usu�rio", ;
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
		Width = 110, ;
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
		Width = 110, ;
		Name = "txtInputBox"


	Add Object cmdok As CommandButton With ;
		Top = 72, ;
		Left = 84, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 5, ;
		Name = "cmdOK"


	Add Object cmdcancel As CommandButton With ;
		Top = 72, ;
		Left = 172, ;
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
	
	    IF f_vazio(.txtUser.Value)
	       MESSAGEBOX("Informe o Usu�rio!")
	       RETURN 
	    endif
	
		.xreturnvalue = .txtinputbox.Value

*!*			Select xUserSenha
*!*			Zap
*!*			Append Blank
		Replace usuario With Alltrim(.txtUser.Value) IN xUserSenha



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
	ENDWITH
	
	ENDPROC
	

Enddefine
*
*-- EndDefine: btn_exp
**************************************************

