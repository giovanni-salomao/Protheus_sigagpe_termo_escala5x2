#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

/*/{Protheus.doc} TERMADIT
Termo Aditivo ao Contrato Individual de Trabalho - EC 141/2026
Modulo Gestao de Pessoas (SIGAGPE)
Author: Giovanni Salomao Pereira
Data: 23/11/2026
/*/
User Function TERMADIT()
    Local aPergs := {}
    Local aRet   := {}
    Local nTam   := TamSX3("RA_MAT")[1]

    aAdd(aPergs, {1, "De Matrícula",  Space(nTam),                 "", "", "SRA", "", 60, .F.})
    aAdd(aPergs, {1, "Até Matrícula", Replicate("Z", nTam),        "", "", "SRA", "", 60, .T.})

    If !ParamBox(aPergs, "Termo Aditivo - EC 141/2026", @aRet)
        Return
    EndIf

    Processa({|| ImpTermo(aRet[1], aRet[2])}, "Termo Aditivo", "Gerando relatório...")
Return

Static Function ImpTermo(cDe, cAte)
    Local oPrn
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local oFNeg  := TFont():New("Arial",,-14,,.T.)
    Local oFTit  := TFont():New("Arial",,-16,,.T.)
    Local oFTxt  := TFont():New("Arial",,-12,,.F.)
    Local nLin   := 0
    Local cDtExt := ""
    Local cTurno := ""
    Local cNome := ""
    Local cCPF  := ""

    cQuery := "SELECT RA_MAT, RA_NOMECMP, RA_NOME, RA_CIC, RA_TNOTRAB "
    cQuery += "FROM " + RetSqlName("SRA") + " SRA "
    cQuery += "WHERE SRA.D_E_L_E_T_ = ' ' "
    cQuery += "AND RA_FILIAL = '" + xFilial("SRA") + "' "
    cQuery += "AND RA_MAT BETWEEN '" + cDe + "' AND '" + cAte + "' "
    cQuery += "ORDER BY RA_MAT"
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)

    If (cAlias)->(Eof())
        MsgInfo("Nenhum funcionário encontrado no intervalo informado.", "Atenção")
        (cAlias)->(dbCloseArea())
        Return
    EndIf

    oPrn := FWMSPrinter():New("termo_aditivo_ec141", IMP_PDF, .F., , .T.)
    oPrn:SetPortrait()
    oPrn:SetPaperSize(9) // A4
    oPrn:SetMargin(40,40,40,40)

    cDtExt := "Nova Friburgo-RJ, " + cValToChar(Day(dDataBase)) + " de " + ;
              MesExtenso(Month(dDataBase)) + " de " + cValToChar(Year(dDataBase)) + "."

    While !(cAlias)->(Eof())
        cNome  := AllTrim((cAlias)->RA_NOMECMP)
        If Empty(cNome)
            cNome := AllTrim((cAlias)->RA_NOME)
        EndIf
        cCPF   := Transform((cAlias)->RA_CIC, "@R 999.999.999-99")
        cTurno := AllTrim(Posicione("SR6", 1, xFilial("SR6") + (cAlias)->RA_TNOTRAB, "R6_DESC"))

        oPrn:StartPage()
        nLin := 80

        // Título centralizado
        oPrn:SayAlign(nLin, 0, "TERMO ADITIVO AO CONTRATO INDIVIDUAL DE TRABALHO", oFTit, 595, 20, , 2, 0)
        nLin += 25
        oPrn:SayAlign(nLin, 0, "Alterações conforme Emenda Constitucional 141/2026", oFTit, 595, 20, , 2, 0)
        nLin += 50

        nLin := Par(oPrn, nLin, "EMPREGADOR: INJETEC DE FRIBURGO IND. E COM. LTDA, inscrita sob o nº 39.243.407/0001-85, com sede na AVENIDA ANTONIO MARIO DE AZEVEDO, nº 3516, ÁREA 1, CÓRREGO DANTAS, NOVA FRIBURGO/RJ - CEP 28630-310, neste ato representada por seu representante legal abaixo assinado.", oFTxt, 60)

        nLin := Par(oPrn, nLin, "EMPREGADO: " + cNome + " inscrito no CPF sob o nº " + cCPF + ".", oFTxt, 40)

        nLin := Par(oPrn, nLin, "As partes acima qualificadas resolvem, de comum acordo, aditar o Contrato Individual de Trabalho vigente, sob a égide do artigo 468 da CLT e em estrito cumprimento às determinações da Emenda Constitucional nº 141, de 16 de outubro de 2026, mediante as seguintes cláusulas e condições:", oFTxt, 60)

        oPrn:Say(nLin, 40, "CLÁUSULA PRIMEIRA - DA REDUÇÃO DA JORNADA DE TRABALHO E ESCALA", oFNeg)
        nLin += 25
        nLin := Par(oPrn, nLin, "Em cumprimento à transição da EC nº 141/2026, a partir de 01/12/2026, a jornada normal de trabalho do EMPREGADO passa a ser de 42 (quarenta e duas) horas semanais. A prestação de serviços ocorrerá sob o regime da escala 5x2 (cinco dias de trabalho por dois dias de descanso). Os novos horários de entrada, saída e intervalos intrajornada ficam alterados de: Foi alterado para: Segunda à Sexta.", oFTxt, 75)
        nLin := Par(oPrn, nLin, "Expediente: " + cTurno + "; Sábado – Folga e Domingo - Folga", oFTxt, 40)

        oPrn:Say(nLin, 40, "CLÁUSULA SEGUNDA - DA IRREDUTIBILIDADE SALARIAL", oFNeg)
        nLin += 25
        nLin := Par(oPrn, nLin, "A redução da carga horária semanal operada por este instrumento não acarretará qualquer redução nominal, proporcional ou de outra natureza sobre o salário percebido pelo EMPREGADO, mantendo-se o valor integral de sua remuneração.", oFTxt, 60)

        oPrn:Say(nLin, 40, "CLÁUSULA TERCEIRA - RATIFICAÇÃO", oFNeg)
        nLin += 25
        nLin := Par(oPrn, nLin, "Ficam ratificadas todas as demais cláusulas e condições do contrato original de trabalho que não colidirem com as disposições deste Termo Aditivo.", oFTxt, 40)

        nLin := Par(oPrn, nLin, "E, por estarem assim justos e contratados, assinam o presente instrumento em 2 (duas) vias de igual teor e forma.", oFTxt, 40)

        oPrn:Say(nLin, 40, cDtExt, oFTxt)
        nLin += 90

        oPrn:Line(nLin, 40, nLin, 270)
        oPrn:Line(nLin, 320, nLin, 555)
        nLin += 15
        oPrn:Say(nLin, 40,  "INJETEC DE FRIBURGO IND. E COM. LTDA", oFTxt)
        oPrn:Say(nLin, 320, Left(cNome, 38), oFTxt)

        oPrn:EndPage()
        (cAlias)->(dbSkip())
    EndDo

    (cAlias)->(dbCloseArea())
    oPrn:Preview()
Return

// Imprime parágrafo justificado com quebra automática; retorna nova linha
Static Function Par(oPrn, nLin, cTxt, oFnt, nEspaco)
    Local nLarg   := 515
    Local nAlt    := 14
    Local nQtd    := Int(Len(cTxt) / 85) + 1
    Local nTotal  := nQtd * nAlt + 4

    oPrn:SayAlign(nLin, 40, cTxt, oFnt, nLarg, nTotal, , 3, 0)
Return nLin + nTotal + 12

//Static Function AjustaSX1(cPerg)
// Pergunta cadastrada via configurador (SX1) ou PutSx1 conforme release
//    PutSx1(cPerg,"01","De Matrícula ?","","","mv_ch1","C",6,0,0,"G","","SRA","","","mv_par01")
//    PutSx1(cPerg,"02","Até Matrícula ?","","","mv_ch2","C",6,0,0,"G","","SRA","","","mv_par02")
//Return
