tableextension 50300 "Publication Header" extends "PIMX Publication Header"
{
    fields
    {
        field(50301; TaxId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Tax Id';
        }
        field(50302; CurrencyId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Id';
        }
    }
}