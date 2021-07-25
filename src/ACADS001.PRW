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

	Local oJson		 := JsonObject():New() 
	Local aDados     := {} 
    Local aMatriz    := {}

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .F.

    cError := oJSon:FromJson(cJson) 
	If cError 
		cErro := '{"msg": "Erro no Parser do jSon "}'
	EndIf

        item    := oJson:GetJsonObject('titulos') 
        for i := 1 to len(iTem)
            aMatriz := {}
            aadd(aMatriz, {"E2_FILIAL",  ALLTRIM(iTem[i]:GetJsonObject('E2_FILIAL')),NIL})
            aadd(aMatriz, {"E2_PREFIXO", ALLTRIM(iTem[i]:GetJsonObject('E2_PREFIXO')),  NIL})
            aadd(aMatriz, {"E2_NUM",     ALLTRIM(iTem[i]:GetJsonObject('E2_NUM')),NIL})
            aadd(aMatriz, {"E2_PARCELA", ALLTRIM(iTem[i]:GetJsonObject('E2_PARCELA')),   NIL})
            aadd(aMatriz, {"E2_TIPO",    ALLTRIM(iTem[i]:GetJsonObject('E2_TIPO')),   NIL})
            aadd(aMatriz, {"E2_NATUREZ", ALLTRIM(iTem[i]:GetJsonObject('E2_NATUREZ')),  NIL})
            aadd(aMatriz, {"E2_FORNECE", ALLTRIM(iTem[i]:GetJsonObject('E2_FORNECE')),NIL})
            aadd(aMatriz, {"E2_LOJA",    ALLTRIM(iTem[i]:GetJsonObject('E2_LOJA')),NIL})
            aadd(aMatriz, {"E2_EMISSAO", STOD(SUBS(iTem[i]:GetJsonObject('E2_EMISSAO'),9,2) +;
                                              SUBS(iTem[i]:GetJsonObject('E2_EMISSAO'),6,2) +;
                                              SUBS(iTem[i]:GetJsonObject('E2_EMISSAO'),1,4)),NIL})
            aadd(aMatriz, {"E2_VENCTO",  STOD(SUBS(iTem[i]:GetJsonObject('E2_VENCTO'),9,2) +;
                                              SUBS(iTem[i]:GetJsonObject('E2_VENCTO'),6,2) +;
                                              SUBS(iTem[i]:GetJsonObject('E2_VENCTO'),1,4)),NIL})
            aadd(aMatriz, {"E2_VENCREA", STOD(SUBS(iTem[i]:GetJsonObject('E2_VENCREA'),9,2) +;
                                              SUBS(iTem[i]:GetJsonObject('E2_VENCREA'),6,2) +;
                                              SUBS(iTem[i]:GetJsonObject('E2_VENCREA'),1,4)),NIL})
            aadd(aMatriz, {"E2_VALOR",   iTem[i]:GetJsonObject('E2_VALOR'),   NIL})
            aadd(aMatriz, {"E2_HIST",    ALLTRIM(iTem[i]:GetJsonObject('E2_HIST')),   NIL})
            aadd(aDados,aMatriz)


        item    := oJson:GetJsonObject('lancamentos') 
        for i := 1 to len(iTem)
            aMatriz := {}
            aadd(aMatriz, {"CT2_FILIAL", ALLTRIM(iTem[i]:GetJsonObject('CT2_FILIAL')),NIL})
            aadd(aMatriz, {"CT2_LOTE",   ALLTRIM(iTem[i]:GetJsonObject('CT2_LOTE')),  NIL})
            aadd(aMatriz, {"CT2_SBLOTE", ALLTRIM(iTem[i]:GetJsonObject('CT2_SBLOTE')),NIL})
            aadd(aMatriz, {"CT2_DATA",   STOD(SUBS(iTem[i]:GetJsonObject('CT2_DATA'),9,2) +;
                                              SUBS(iTem[i]:GetJsonObject('CT2_DATA'),6,2) +;
                                              SUBS(iTem[i]:GetJsonObject('CT2_DATA'),1,4)),NIL})
            aadd(aMatriz, {"CT2_DOC",    ALLTRIM(iTem[i]:GetJsonObject('CT2_DOC')),   NIL})
            aadd(aMatriz, {"CT2_VALOR",  iTem[i]:GetJsonObject('CT2_VALOR'), NIL})
            aadd(aMatriz, {"CT2_HIST",   ALLTRIM(iTem[i]:GetJsonObject('CT2_HIST')),  NIL})
            aadd(aMatriz, {"CT2_DEBITO", ALLTRIM(iTem[i]:GetJsonObject('CT2_DEBITO')),NIL})
            aadd(aMatriz, {"CT2_CREDIT", ALLTRIM(iTem[i]:GetJsonObject('CT2_CREDIT')),NIL})
            aadd(aMatriz, {"CT2_CCD",    ALLTRIM(iTem[i]:GetJsonObject('CT2_CCD')),   NIL})
            aadd(aMatriz, {"CT2_CCC",    ALLTRIM(iTem[i]:GetJsonObject('CT2_CCC')),   NIL})
            aadd(aDados,aMatriz)
        next

        // Monta Bloco para execucao da rotina 
        cExecAuto := "MsExecAuto({|x,y| " + oParseJson['EXECCUR'] + "(x,y)}, aDados, " + cOpc + ")"
        //Execauto para tabela para pesquisa?


        // Executa rotina automatica
        &cExecAuto

        If lMsErroAuto

            cErro := MostraErro("\log_cli")
            SetRestFault(400, EncodeUtf8(cErro))
            lRet := .F.

        EndIF



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
	ZZM->ZZM_HRPROC := StrTran(Time(), ":", "")
	ZZM->ZZM_JSON   := cJson

	MsUnLock()

Return ZZM->ZZM_SEQ