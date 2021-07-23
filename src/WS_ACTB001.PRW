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
WsRestFul ExecCur DESCRIPTION "Permite a Execucao da ExecAuto de uma rotina do Protheus"

    WSMETHOD POST DESCRIPTION "Permite a Execucao da ExecAuto de uma rotina do Protheus"

End WsRestFul

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Method POST

@since   25/02/2020
@version 2.0
/*/
//-------------------------------------------------------------------
WsMethod POST WSRECEIVE idUrlParam WsService ExecCur

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

        Else

            cJSONRet := '{"msg": "Sucesso"}'
            Self:SetResponse( cJSONRet )

        EndIf

    EndIf

Return(lRet)
