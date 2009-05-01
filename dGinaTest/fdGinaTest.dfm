object frmdGinaTest: TfrmdGinaTest
  Left = 0
  Top = 0
  Caption = 'dGina.dll test with BtMemoryModule'
  ClientHeight = 133
  ClientWidth = 399
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    399
    133)
  PixelsPerInch = 96
  TextHeight = 13
  object btnLoad: TButton
    Left = 151
    Top = 23
    Width = 97
    Height = 25
    Anchors = []
    Caption = 'Load'
    TabOrder = 0
    OnClick = btnLoadClick
  end
  object btnDisableTaskbar: TButton
    Left = 151
    Top = 54
    Width = 97
    Height = 25
    Anchors = []
    Caption = 'Disable Taskbar'
    TabOrder = 1
    OnClick = btnDisableTaskbarClick
  end
  object btnUnload: TButton
    Left = 151
    Top = 85
    Width = 97
    Height = 25
    Anchors = []
    Caption = 'Unload'
    TabOrder = 2
    OnClick = btnUnloadClick
  end
end
