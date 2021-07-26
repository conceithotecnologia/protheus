//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas

/*/{Protheus.doc} ACADA001
Função para cadastro de Fila de REST
@author Fabio Carvalho
@since 21/07/2021
@version 1.0
	@return Nil, Função não tem retorno
	@example
	u_ACADA001()
	@obs Não se pode executar função MVC dentro do fórmulas
/*/
User Function ACADA001()
	Local aArea   := GetArea()
	Local oBrowse
	
	Private cCadastro := "Fila de Integracao"
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZZM")
	oBrowse:SetDescription(cCadastro)
	
	//Legendas
	oBrowse:AddLegend( "ZZM->ZZM_STATUS == '0'", "YELLOW",	"Nao Processado" )
	oBrowse:AddLegend( "ZZM->ZZM_STATUS == '1'", "GRREN",	"Processado" )
	oBrowse:AddLegend( "ZZM->ZZM_STATUS == '2'", "RED",	    "Processamento com Erro" )
	
	//Ativa a Browse
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil


/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Fabio Carvalho                                               |
 | Data:  21/07/2021                                                   |
 | Desc:  Criação do menu MVC                                        |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ACADA001' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Processar'  ACTION 'u_ACADS001'     OPERATION MODEL_OPERATION_UPDATE  ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_ACAD001L'     OPERATION MODEL_OPERATION_INSERT  ACCESS 0 //OPERATION X
Return aRot


/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Fabio Carvalho                                               |
 | Data:  21/07/2021                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel := Nil
	
	//Criação da estrutura de dados utilizada na interface
	Local oStru := FWFormStruct(1, "ZZM")
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("ACADM001",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZZM",/*cOwner*/,oStru)
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZM_FILIAL','ZM_SEQ'})
	
	//Adicionando descrição ao modelo
	oModel:SetDescription(cCadastro)
	
	//Setando a descrição do formulário
	oModel:GetModel("FORMzzm"):SetDescription(cCadastro)
Return oModel


/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Fabio Carvalho                                               |
 | Data:  21/07/2021                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("ACADA001")
	
	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStru := FWFormStruct(2, "ZZM")
	
	//Criando oView como nulo
	Local oView := Nil
	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZZM", oStru, "FORMZZM")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando título do formulário
	oView:EnableTitleView('VIEW_ZZM', 'Fila do Rest' )  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZZM","TELA")
Return oView


/*---------------------------------------------------------------------*
 | Func:  ACADA001L                                                    |
 | Autor: Fabio Carvalho                                               |
 | Data:  21/07/2021                                                   |
 | Desc:  Mostrar Legendas                                             |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

User Function ACAD001L()
	Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_AMARELO",	"N�o Processado"})
	AADD(aLegenda,{"BR_VERDE",		"Processado"  })
	AADD(aLegenda,{"BR_VERMELHO",	"Processado com Erro"})
	
	BrwLegenda("Status Servico REST", "Status", aLegenda)
Return
