object FrameFileBrowser: TFrameFileBrowser
  Left = 0
  Top = 0
  Width = 390
  Height = 173
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  AutoSize = True
  TabOrder = 0
  DesignSize = (
    390
    173)
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 31
    Height = 13
    Caption = 'Label1'
    Color = clBtnFace
    ParentColor = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 18
    Width = 390
    Height = 155
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 185
      Top = 0
      Height = 155
    end
    object PanelFolder: TPanel
      Left = 0
      Top = 0
      Width = 185
      Height = 155
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'PanelFolder'
      TabOrder = 0
    end
    object PanelFiles: TPanel
      Left = 188
      Top = 0
      Width = 202
      Height = 155
      Align = alClient
      BevelOuter = bvNone
      Caption = 'PanelFiles'
      TabOrder = 1
    end
  end
end
