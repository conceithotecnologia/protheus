#include 'protheus.ch'
#include 'parmtype.ch'
#include 'restful.ch'
#include 'tbiconn.ch'
#Include "Totvs.Ch"
#Include "RESTFUL.Ch"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecAuto
Webservice REST que permite a Execucao da ExecAuto de uma rotina do Protheus 

@return .T. ou .F. + Estrutura Json

@since   25/02/2020
@version 2.0
/*/
//-------------------------------------------------------------------
WsRestFul ExecFolh DESCRIPTION "Permite a Execucao da ExecAuto de uma rotina do Protheus"

    WSMETHOD POST DESCRIPTION "Permite a Execucao da ExecAuto de uma rotina do Protheus"

End WsRestFul

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Method POST

@since   25/02/2020
@version 2.0
/*/
//-------------------------------------------------------------------
WsMethod POST WSRECEIVE idUrlParam WsService ExecFolh

    Local cJSON      := Self:GetContent() // Pega a string do JSON
    Local oParseJSON := Nil
    Local aDados     := {} 
    Local aMatriz    := {}
    Local cErro      := ""
    Local lRet       := .T.
    Local item, i
    Local cExecAuto
    Local cJSONRet

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .F.

    Default cOpc := "3"

    // define o tipo de retorno do metodo
    Self:SetContentType("application/json")
    oJson  := JsonObject():New()
    cError := oJSon:FromJson(cJson) 

   If ValType(cError) != "U"

        cErro := '{"msg": "Erro no Parser do jSon "}'
        SetRestFault(400, cErro)
        lRet := .F.
    Else
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
            //iTem[i]:GetJsonObject('CT2_VALOR'), NIL})
            aadd(aDados,aMatriz)
        next

// Monta Bloco para execucao da rotina
        cExecAuto := "MsExecAuto({|x,y| " + oParseJson['ExecFolh'] + "(x,y)}, aDados, " + cOpc + ")"

        // Executa rotina automatica
        &cExecAuto

        If lMsErroAuto

            cErro := MostraErro("\log_cli")
            SetRestFault(400, EncodeUtf8(cErro))
            lRet := .F.

        Else

            cJSONRet := '{"msg": "Sucesso"}'
            Self:SetResponse( cJSONRet )

        EndIf

    EndIf

Return(lRet)
