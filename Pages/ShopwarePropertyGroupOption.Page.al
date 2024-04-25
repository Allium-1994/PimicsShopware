page 50300 ShopwarePropertyGroupOption
{
    Caption = 'Shopware Property Group Option';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Property Group Option";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Publication Code"; Rec."Publication Code")
                {
                    ApplicationArea = All;
                    ToolTip = '!!!Publication Code';
                }
                field("Feature Id"; Rec."Feature Id")
                {
                    ApplicationArea = All;
                    ToolTip = '!!!Feature Id';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = '!!!Value';
                }
                field("Shopware Id"; Rec."Shopware Id")
                {
                    ApplicationArea = All;
                    ToolTip = '!!!Shopware Id';
                }
            }
        }
        area(Factboxes)
        {

        }
    }
}