object Form1: TForm1
  Left = 195
  Top = 105
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Simple Webserver'
  ClientHeight = 505
  ClientWidth = 314
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 180
    Top = 458
    Width = 32
    Height = 13
    Caption = 'Label3'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 486
    Width = 314
    Height = 19
    Panels = <
      item
        Width = 0
      end
      item
        Text = 'dddddddddd, dd. mmmmmmmmm yyyy - hh:nn:ss'
        Width = 50
      end>
    ExplicitTop = 420
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 313
    Height = 417
    ActivePage = TabSheet1
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Einstellungen'
      object GroupBox1: TGroupBox
        Left = 0
        Top = 128
        Width = 305
        Height = 97
        Caption = 'Error 404 Fehler Seite'
        TabOrder = 0
        object Label5: TLabel
          Left = 8
          Top = 16
          Width = 135
          Height = 13
          Caption = 'Bei ung'#252'ltigem Seiten aufruf:'
        end
        object RadioButton1: TRadioButton
          Left = 16
          Top = 32
          Width = 201
          Height = 17
          Caption = 'Standard Error 404 Seite senden'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton1Click
        end
        object RadioButton2: TRadioButton
          Left = 16
          Top = 48
          Width = 241
          Height = 17
          Caption = 'eigene definierte 404 (html) Seite verwenden:'
          TabOrder = 1
          OnClick = RadioButton2Click
        end
        object Edit3: TEdit
          Left = 32
          Top = 64
          Width = 121
          Height = 21
          TabOrder = 2
        end
        object Button4: TButton
          Left = 160
          Top = 64
          Width = 33
          Height = 25
          Caption = '...'
          TabOrder = 3
          OnClick = Button4Click
        end
      end
      object GroupBox2: TGroupBox
        Left = 0
        Top = 4
        Width = 305
        Height = 113
        Caption = 'Ben'#246'tigte informationen zum Starten des Webservers'
        TabOrder = 1
        object Label1: TLabel
          Left = 8
          Top = 16
          Width = 22
          Height = 13
          Caption = 'Port:'
        end
        object Label2: TLabel
          Left = 8
          Top = 64
          Width = 88
          Height = 13
          Caption = 'Arbeitsverzeichnis:'
        end
        object Label9: TLabel
          Left = 141
          Top = 16
          Width = 156
          Height = 13
          Caption = 'Max. gleichzeitige Verbindungen:'
        end
        object Edit1: TEdit
          Left = 8
          Top = 32
          Width = 73
          Height = 21
          TabOrder = 0
          Text = '80'
        end
        object Edit2: TEdit
          Left = 8
          Top = 80
          Width = 209
          Height = 21
          TabOrder = 1
          Text = 'C:\Projekte\DELPHI\webserver test\'
        end
        object Button5: TButton
          Left = 224
          Top = 80
          Width = 33
          Height = 25
          Caption = '...'
          TabOrder = 2
          OnClick = Button5Click
        end
        object Edit4: TEdit
          Left = 141
          Top = 32
          Width = 70
          Height = 21
          TabOrder = 3
          Text = '20'
        end
      end
      object Button1: TButton
        Left = 48
        Top = 352
        Width = 75
        Height = 25
        Caption = 'Start'
        TabOrder = 2
        OnClick = Button1Click
      end
      object Button2: TButton
        Left = 176
        Top = 352
        Width = 75
        Height = 25
        Caption = 'Stop'
        TabOrder = 3
        OnClick = Button2Click
      end
      object GroupBox3: TGroupBox
        Left = 0
        Top = 232
        Width = 305
        Height = 105
        Caption = 'Bei Verzeichnis Aufruf ohne index.html (/index.htm)'
        TabOrder = 4
        object Label6: TLabel
          Left = 8
          Top = 16
          Width = 251
          Height = 13
          Caption = 'Wenn der Client ein Verzeichnis im Arbeitsverzeichnis'
        end
        object Label7: TLabel
          Left = 8
          Top = 32
          Width = 242
          Height = 13
          Caption = #246'ffnet, in der keine index.html (bzw. index.htm) liegt,'
        end
        object Label8: TLabel
          Left = 8
          Top = 48
          Width = 256
          Height = 13
          Caption = 'welche man anzeigen k'#246'nnte, dann mache folgendes:'
        end
        object RadioButton3: TRadioButton
          Left = 8
          Top = 64
          Width = 113
          Height = 17
          Caption = 'Error 404 Ausgeben'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object RadioButton4: TRadioButton
          Left = 8
          Top = 80
          Width = 289
          Height = 17
          Caption = 'Dateiinhalt des Verzeichnisses '#252'bermitteln  (FTP Ansicht)'
          TabOrder = 1
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Server Anfragen Anzeigen'
      ImageIndex = 1
      object Label4: TLabel
        Left = 0
        Top = 0
        Width = 80
        Height = 13
        Caption = 'Server Anfragen:'
      end
      object Memo1: TMemo
        Left = 0
        Top = 16
        Width = 305
        Height = 369
        Color = cl3DLight
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
  end
  object Button3: TButton
    Left = 226
    Top = 453
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 2
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 128
    Top = 440
  end
  object OpenDialog1: TOpenDialog
    Left = 96
    Top = 432
  end
  object MainMenu1: TMainMenu
    Top = 432
    object Datei1: TMenuItem
      Caption = 'Datei'
      object Systray: TMenuItem
        Caption = 'Systray'
        OnClick = SystrayClick
      end
      object Beenden: TMenuItem
        Caption = 'Beenden'
        OnClick = BeendenClick
      end
    end
    object Info1: TMenuItem
      Caption = 'Info'
      object Hilfe1: TMenuItem
        Caption = 'Hilfe'
        OnClick = Hilfe1Click
      end
      object Update1: TMenuItem
        Caption = 'Update'
        OnClick = Update1Click
      end
      object Info2: TMenuItem
        Caption = 'Info'
        OnClick = Info2Click
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 32
    Top = 440
    object Programm: TMenuItem
      Caption = 'Programm'
      OnClick = ProgrammClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Beenden2: TMenuItem
      Caption = 'Beenden'
      OnClick = Beenden2Click
    end
  end
end
