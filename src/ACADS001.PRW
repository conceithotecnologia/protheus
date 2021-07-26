/*/{Protheus.doc} ACADA001
Função para processamento do JSON do ZZM
@author Wagner Mobile Costa
@since 25/07/2021
@version 1.0
	@return Nil, Função não tem retorno
	@example
	u_ACADS001()
/*/
User Function ACADS001()

	Local oJson    := JsonObject():New()
    Local aMatriz  := {}
	Local cRetorno := ""   
	Local aItem    := {}
	Local i        := 0

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .F.

    cError := oJSon:FromJson(ZZM->ZZM_JSON)

	If ValType(cError) != "U"
		ZZM->(RECLOCK("ZZM", .F.))
		ZZM->ZZM_STATUS := "2"	// Processado com Erro
		ZZM->ZZM_DPROC  := Date()
		ZZM->ZZM_HPROC  := StrTran(Time(), ":", "")
		ZZM->ZZM_RETORN := 'Erro no Parser do jSon'
		ZZM->(MsUnLock())
		Return
	EndIf
	
	IF ZZM->ZZM_TIPO == "0"	// Contabil
		aItem  := oJson:GetJsonObject('lancamentos') 
		for i := 1 to len(aItem)
			aMatriz := {}
			aadd(aMatriz, {"CT2_FILIAL", ALLTRIM(aItem[i]:GetJsonObject('CT2_FILIAL')),NIL})
			aadd(aMatriz, {"CT2_LOTE",   ALLTRIM(aItem[i]:GetJsonObject('CT2_LOTE')),  NIL})
			aadd(aMatriz, {"CT2_SBLOTE", ALLTRIM(aItem[i]:GetJsonObject('CT2_SBLOTE')),NIL})
			aadd(aMatriz, {"CT2_DATA",   STOD(SUBS(aItem[i]:GetJsonObject('CT2_DATA'),9,2) +;
											  SUBS(aItem[i]:GetJsonObject('CT2_DATA'),6,2) +;
											  SUBS(aItem[i]:GetJsonObject('CT2_DATA'),1,4)),NIL})
			aadd(aMatriz, {"CT2_DOC",    ALLTRIM(aItem[i]:GetJsonObject('CT2_DOC')),   NIL})
			aadd(aMatriz, {"CT2_VALOR",  aItem[i]:GetJsonObject('CT2_VALOR'), NIL})
			aadd(aMatriz, {"CT2_HIST",   ALLTRIM(aItem[i]:GetJsonObject('CT2_HIST')),  NIL})
			aadd(aMatriz, {"CT2_DEBITO", ALLTRIM(aItem[i]:GetJsonObject('CT2_DEBITO')),NIL})
			aadd(aMatriz, {"CT2_CREDIT", ALLTRIM(aItem[i]:GetJsonObject('CT2_CREDIT')),NIL})
			aadd(aMatriz, {"CT2_CCD",    ALLTRIM(aItem[i]:GetJsonObject('CT2_CCD')),   NIL})
			aadd(aMatriz, {"CT2_CCC",    ALLTRIM(aItem[i]:GetJsonObject('CT2_CCC')),   NIL})
		next
	ElseIF ZZM->ZZM_TIPO == "1"	// Financeiro
		aItem := oJson:GetJsonObject('titulos') 
		for i := 1 to len(aItem)
			aMatriz := {}
			M->E2_NUM := ALLTRIM(aItem[i]:GetJsonObject('E2_NUM'))
			aadd(aMatriz, {"E2_FILIAL",  ALLTRIM(aItem[i]:GetJsonObject('E2_FILIAL')),NIL})
			aadd(aMatriz, {"E2_PREFIXO", ALLTRIM(aItem[i]:GetJsonObject('E2_PREFIXO')),  NIL})
			aadd(aMatriz, {"E2_NUM",     M->E2_NUM,NIL})
			aadd(aMatriz, {"E2_PARCELA", ALLTRIM(aItem[i]:GetJsonObject('E2_PARCELA')),   NIL})
			aadd(aMatriz, {"E2_TIPO",    ALLTRIM(aItem[i]:GetJsonObject('E2_TIPO')),   NIL})
			aadd(aMatriz, {"E2_NATUREZ", ALLTRIM(aItem[i]:GetJsonObject('E2_NATUREZ')),  NIL})
			aadd(aMatriz, {"E2_FORNECE", ALLTRIM(aItem[i]:GetJsonObject('E2_FORNECE')),NIL})
			aadd(aMatriz, {"E2_LOJA",    ALLTRIM(aItem[i]:GetJsonObject('E2_LOJA')),NIL})
			aadd(aMatriz, {"E2_EMISSAO", STOD(SUBS(aItem[i]:GetJsonObject('E2_EMISSAO'),9,2) +;
											  SUBS(aItem[i]:GetJsonObject('E2_EMISSAO'),6,2) +;
											  SUBS(aItem[i]:GetJsonObject('E2_EMISSAO'),1,4)),NIL})
			aadd(aMatriz, {"E2_VENCTO",  STOD(SUBS(aItem[i]:GetJsonObject('E2_VENCTO'),9,2) +;
											  SUBS(aItem[i]:GetJsonObject('E2_VENCTO'),6,2) +;
											  SUBS(aItem[i]:GetJsonObject('E2_VENCTO'),1,4)),NIL})
			aadd(aMatriz, {"E2_VENCREA", STOD(SUBS(aItem[i]:GetJsonObject('E2_VENCREA'),9,2) +;
											  SUBS(aItem[i]:GetJsonObject('E2_VENCREA'),6,2) +;
											  SUBS(aItem[i]:GetJsonObject('E2_VENCREA'),1,4)),NIL})
			aadd(aMatriz, {"E2_VALOR",   aItem[i]:GetJsonObject('E2_VALOR'),   NIL})
			aadd(aMatriz, {"E2_HIST",    ALLTRIM(aItem[i]:GetJsonObject('E2_HIST')),   NIL})

			MsExecAuto({|x,y| FINA050(x,y)}, aMatriz, 3)

			If lMsErroAuto
				If ! Empty(cRetorno)
					cRetorno += CHR(13) + Chr(10)
				EndIF
				cRetorno += "Titulo: " + M->E2_NUM

				cRetorno += "Erro: " + MostraErro("\log_cli")
			EndIF
		Next
	EndIF


	ZZM->(RECLOCK("ZZM", .F.))
	ZZM->ZZM_STATUS := If(Empty(cRetorno), "1", "2")	// Processado com sucesso ou erro
	ZZM->ZZM_DPROC  := Date()
	ZZM->ZZM_HPROC  := StrTran(Time(), ":", "")
	ZZM->ZZM_RETORN := cRetorno
	ZZM->(MsUnLock())

Return

/*/{Protheus.doc} ACADS01I
Inclusão do registro ZZM para processamento
@author Wagner Mobile Costa
@since 25/07/2021
@version 1.0
	@return Nil, Função não tem retorno
	@example
	u_ACADS01I(cJson, cTipo)
/*/

User Function ACADS01I(cJson, cTipo)

	DbSelectArea("ZZM")
	RECLOCK("ZZM", .T.)
	ZZM->ZZM_FILIAL := xFilial("ZZM")
	ZZM->ZZM_SEQ    := GetSxeNum("ZZM", "ZZM_SEQ")
	ZZM->ZZM_TIPO   := cTipo
	ZZM->ZZM_STATUS := "0"		// Pendente
	ZZM->ZZM_DTLEIT := Date()
	ZZM->ZZM_HLEIT  := StrTran(Time(), ":", "")
	ZZM->ZZM_JSON   := cJson

	MsUnLock()

Return ZZM->ZZM_SEQ
