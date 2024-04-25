//namespace Allium.Pimics.Shopware
table 50300 "Property Group Option"
{
    DataClassification = CustomerContent;
    Caption = 'Property Group Option';

    fields
    {
        field(1; "Publication Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Publication Code';
            TableRelation = "PIMX Publication Header";
        }
        field(2; "Feature Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Feature Id';
            TableRelation = "PIMX Feature".SystemId;
        }
        field(3; Value; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Value';
        }
        field(4; "Shopware Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Shopware Id';
        }
    }

    keys
    {
        key(PK; "Publication Code", "Feature Id", Value)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        UpdateShopware: Codeunit "Update Shopware";
        PIMXPubLineGUID: Guid;

    trigger OnInsert()
    begin
        if Rec.IsTemporary() then
            exit;

        UpdateShopware.CreatePropertyGroup(Rec."Feature Id", Rec.Value, Rec."Publication Code", PIMXPubLineGUID);
        if not IsNullGuid(Rec."Shopware Id") then
            UpdateShopware.CreatePropertyGroupValue(Rec."Feature Id", Rec.Value, Rec."Shopware Id", Rec."Publication Code", PIMXPubLineGUID)
    end;

    trigger OnModify()
    begin
        if Rec.IsTemporary() then
            exit;

        if (Rec."Shopware Id" <> xRec."Shopware Id") then
            UpdateShopware.CreatePropertyGroupValue(Rec."Feature Id", Rec.Value, Rec."Shopware Id", Rec."Publication Code", PIMXPubLineGUID);
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    #region InitFrom
    #endregion

    procedure PubLineGuid_Set(LineGuid: Guid)
    begin
        PIMXPubLineGUID := LineGuid;
    end;
}