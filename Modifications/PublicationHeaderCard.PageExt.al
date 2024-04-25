pageextension 50300 "Publication Header Card" extends "PIMX Publication Card"
{
    layout
    {
        addafter(General)
        {
            group(Shopware)
            {
                field(TaxId; Rec.TaxId)
                {
                    ApplicationArea = PIMXBase;
                    ToolTip = '!!!Tax Id';
                }
                field(CurrencyId; Rec.CurrencyId)
                {
                    ApplicationArea = PIMXBase;
                    ToolTip = '!!!Currency Id';
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}