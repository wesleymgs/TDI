object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'FrmPrincipal'
  ClientHeight = 295
  ClientWidth = 487
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object MainMenu1: TMainMenu
    Left = 344
    Top = 48
    object Clientes1: TMenuItem
      Caption = 'Adicionar aba'
      object Clientes2: TMenuItem
        Caption = 'Clientes'
        OnClick = Clientes2Click
      end
      object Fornecedores1: TMenuItem
        Caption = 'Fornecedores'
        OnClick = Fornecedores1Click
      end
    end
  end
end
