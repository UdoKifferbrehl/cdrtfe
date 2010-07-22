object FrameTopBanner: TFrameTopBanner
  Left = 0
  Top = 0
  Width = 345
  Height = 53
  Anchors = [akLeft, akTop, akRight]
  TabOrder = 0
  DesignSize = (
    345
    53)
  object Bevel1: TBevel
    Left = 0
    Top = 50
    Width = 345
    Height = 3
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 345
    Height = 50
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      345
      50)
    object Image2: TImage
      Left = 175
      Top = 0
      Width = 170
      Height = 50
      Anchors = [akLeft, akTop, akRight, akBottom]
      Stretch = True
    end
    object LabelDescription: TLabel
      Left = 16
      Top = 27
      Width = 78
      Height = 13
      Caption = 'LabelDescription'
      Transparent = True
    end
    object LabelCaption: TLabel
      Left = 8
      Top = 8
      Width = 62
      Height = 13
      Caption = 'LabelCaption'
      Transparent = True
    end
  end
end
