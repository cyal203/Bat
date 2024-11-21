#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include <EditConstants.au3>
#include <StaticConstants.au3>

; Define a senha
Global $sSenhaCorreta = "123"

; Função para exibir a janela de autenticação
Func AuthWindow()
    Local $hAuthGUI = GUICreate("Autenticação", 250, 120)
    Local $hLabelSenha = GUICtrlCreateLabel("Digite a senha:", 10, 10, 230, 20)
    Local $hInputSenha = GUICtrlCreateInput("", 10, 30, 230, 20, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
    Local $hBotaoOKAuth = GUICtrlCreateButton("&OK", 10, 60, 230, 30)
    
    GUISetState(@SW_SHOW, $hAuthGUI)

    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                GUIDelete($hAuthGUI)
                Return False
            Case $hBotaoOKAuth
                If GUICtrlRead($hInputSenha) = $sSenhaCorreta Then
                    GUIDelete($hAuthGUI)
                    Return True
                Else
                    MsgBox($MB_ICONERROR, "Erro", "Senha errada. Tente novamente.")
                    GUICtrlSetData($hInputSenha, "") ; Limpa o campo de senha
                EndIf
        EndSwitch
    WEnd
EndFunc

; Verifica a autenticação antes de prosseguir
If Not AuthWindow() Then Exit

; Cria a janela
$hGUI = GUICreate("FX", 200, 152, 192, 124)

; Cria o ComboBox para os estados
$hComboEstado = GUICtrlCreateCombo("Selecione o Estado", 32, 24, 150, 25)
GUICtrlSetData($hComboEstado, "SP|MG|BA|ES")

; Cria o ComboBox para as opções
$hComboOpcao = GUICtrlCreateCombo("Selecione a Opção", 32, 58, 150, 25)

; Cria o botão OK
$hBotaoOK = GUICtrlCreateButton("&OK", 32, 97, 75, 25)

; Cria um rótulo para exibir a versão
$hLabelVersao = GUICtrlCreateLabel("", 115, 100, 100, 20)

; Exibe a janela
GUISetState(@SW_SHOW, $hGUI)

; Loop principal
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $hComboEstado
            ; Limpa o ComboBox de opções
            GUICtrlSetData($hComboOpcao, "")

            ; Verifica o estado selecionado e define as opções correspondentes
            Switch GUICtrlRead($hComboEstado)
                Case "SP"
                    GUICtrlSetData($hComboOpcao, "V1|WCF|V1/WCF")
                Case "MG"
                    GUICtrlSetData($hComboOpcao, "V1|WCF|V1/WCF")
                Case "BA"
                    GUICtrlSetData($hComboOpcao, "V1|WCF|V1/WCF")
                Case "ES"
                    GUICtrlSetData($hComboOpcao, "")
            EndSwitch
        Case $hComboOpcao
            ; Verifica as condições e exibe as versões corretas
            If GUICtrlRead($hComboEstado) = "SP" Then
                Switch GUICtrlRead($hComboOpcao)
                    Case "V1"
                        GUICtrlSetData($hLabelVersao, "V1-1.1.0.4")
                    Case "WCF"
                        GUICtrlSetData($hLabelVersao, "WCF-1.1.0.3")
                    Case "V1/WCF"
                        GUICtrlSetData($hLabelVersao, "1.1.0.4 / 1.1.0.3")
                    Case Else
                        GUICtrlSetData($hLabelVersao, "")
                EndSwitch
            Else
                GUICtrlSetData($hLabelVersao, "")
            EndIf
        Case $hBotaoOK
            ; Ação ao clicar no botão OK
            Switch GUICtrlRead($hComboEstado)
                Case "SP"
                    Switch GUICtrlRead($hComboOpcao)
                        Case "V1"
                            Run("notepad.exe")
                        Case "WCF"
                            Run("cmd.exe")
                        Case "V1/WCF"
                            Run("explorer.exe")
                    EndSwitch
                Case "MG"
                    Switch GUICtrlRead($hComboOpcao)
                        Case "V1"
                            Run("mspaint.exe")
                        Case "WCF"
                            Run("explorer.exe")
                    EndSwitch
                Case "BA"
                    Run("cmd.exe")
                Case "ES"
                    Run("powershell.exe")
            EndSwitch
    EndSwitch
WEnd

; Fecha a janela
GUIDelete($hGUI)
