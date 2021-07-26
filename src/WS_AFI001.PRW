#include 'protheus.ch'
#include 'parmtype.ch'
#include 'restful.ch'
#include 'tbiconn.ch'
#Include "Totvs.Ch"
#Include "RESTFUL.Ch"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CONTASPAGAR
Webservice REST que realiza a inclusÃ£o do JSON na tabela de fila do REST (ZZM) 

@return .T. ou .F. + Estrutura Json

@since   21/07/2021
@version 2.0
/*/
//-------------------------------------------------------------------
WsRestFul CONTASPAGAR DESCRIPTION "Permite a inclusão de JSON na fila para inclusão de contas a pagar (SE2)"

    WSMETHOD POST DESCRIPTION "Permite a inclusão de JSON na fila para inclusão de contas a pagar (SE2)"

End WsRestFul

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Method POST

@since   25/02/2020
@version 2.0
/*/
//-------------------------------------------------------------------
WsMethod POST WSRECEIVE idUrlParam WsService CONTASPAGAR

    Local cJSON      := Self:GetContent() // Pega a string do JSON
    Local cError     := ""
    Local oJson      := Nil

    // define o tipo de retorno do metodo
    Self:SetContentType("application/json")
    oJson  := JsonObject():New()
    cError := oJSon:FromJson(cJson) 

   If ValType(cError) != "U"

        cErro := '{"msg": "Erro no Parser do jSon "}'
        SetRestFault(400, cErro)
    Else
		U_ACADS01I(cJson, "1")	// Folha
	
		cJSONRet := '{ "msg": "Sucesso", "ID": "' + ZZM->ZZM_SEQ + '" } '
        Self:SetResponse( cJSONRet )
    EndIf

Return(.T.)
