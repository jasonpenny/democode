object frmDelphiSnarlDemo: TfrmDelphiSnarlDemo
  Left = 0
  Top = 0
  Caption = 'Snarl Demo'
  ClientHeight = 469
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    635
    469)
  PixelsPerInch = 96
  TextHeight = 13
  object lblTitle: TLabel
    Left = 162
    Top = 52
    Width = 20
    Height = 13
    Caption = 'Title'
    FocusControl = eTitle
  end
  object lblText: TLabel
    Left = 162
    Top = 98
    Width = 22
    Height = 13
    Caption = 'Text'
    FocusControl = eText
  end
  object lblMessages: TLabel
    Left = 162
    Top = 221
    Width = 47
    Height = 13
    Caption = 'Messages'
  end
  object lblDuration: TLabel
    Left = 162
    Top = 144
    Width = 361
    Height = 13
    Caption = 
      'Duration (0 for "Sticky Notification", it won'#39't fade and disappe' +
      'ar on its own)'
  end
  object btnRegister: TButton
    Left = 24
    Top = 12
    Width = 125
    Height = 25
    Caption = 'Register with Snarl'
    TabOrder = 0
    OnClick = btnRegisterClick
  end
  object btnSendText: TButton
    Left = 24
    Top = 69
    Width = 125
    Height = 25
    Caption = 'Send just text'
    TabOrder = 1
    OnClick = btnSendTextClick
  end
  object btnSendTextWithImage: TButton
    Left = 24
    Top = 115
    Width = 125
    Height = 25
    Caption = 'Send text with image'
    TabOrder = 2
    OnClick = btnSendTextWithImageClick
  end
  object btnUnregister: TButton
    Left = 24
    Top = 238
    Width = 125
    Height = 25
    Caption = 'Unregister with Snarl'
    TabOrder = 3
    OnClick = btnUnregisterClick
  end
  object eTitle: TEdit
    Left = 162
    Top = 71
    Width = 459
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    Text = 'A Test Title'
  end
  object eText: TEdit
    Left = 162
    Top = 117
    Width = 459
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    Text = 'Some Test Text'
  end
  object mmMessages: TMemo
    Left = 162
    Top = 240
    Width = 465
    Height = 221
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object eDuration: TEdit
    Left = 162
    Top = 163
    Width = 459
    Height = 21
    TabOrder = 7
    Text = '60'
  end
  object btnTestWideChars: TButton
    Left = 27
    Top = 149
    Width = 119
    Height = 25
    Hint = 
      'Snarl accepts UTF-8 text, Delphi versions before 2009 should use' +
      ' snShowMessageExWide()'
    Caption = 'Test sending widechars'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    OnClick = btnTestWideCharsClick
  end
end
