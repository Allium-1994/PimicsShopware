codeunit 50301 "Shopware Helper"
{
    var
        PIMXPublicationQueueHelper: Codeunit "PIMX Publication Queue Helper";

    procedure FormatId(Id: Guid): Text
    begin
        if not IsNullGuid(Id) then
            exit(Format(Id).Replace('{', '').Replace('}', '').Replace('-', '').ToLower())
        else
            exit('');
    end;

    procedure GetAuth(BaseUrl: Text[250]; var PIMXAuthentication: Record "PIMX Authentication"): Boolean
    begin
        PIMXAuthentication.Reset();
        PIMXAuthentication.SetRange("Default Url", BaseUrl);
        if PIMXAuthentication.FindFirst() then
            exit(true)
        else
            exit(false);
    end;

    procedure GetPathFromPubLineData(Data: Text): Text
    var
        JsonReq: JsonObject;
        JsonTok: JsonToken;
        PathTxt: Text;
    begin
        if not JsonReq.ReadFrom(Data) then
            if not JsonReq.ReadFrom(Data.Replace('[', '').Replace(']', '')) then
                exit('');

        JsonReq.Get('post', JsonTok);
        JsonTok.WriteTo(PathTxt);
        PathTxt := PathTxt.Replace('"', '');
        exit(PathTxt);
    end;

    procedure GetGuidFromParent(MasterGuid: Guid; var MasterDataGuid: Guid): Boolean
    var
        PIMXPublicationLineMaster: Record "PIMX Publication Line";
    begin
        if PIMXPublicationLineMaster.GetByLineGuid(MasterGuid) then begin
            MasterDataGuid := PIMXPublicationLineMaster."Data GUID";
            exit(true);
        end else
            exit(false);
    end;

    procedure CompareJsonRequest(NewJsonReq: JsonObject; CurJsonTxt: Text): Boolean
    var
        CurJsonReq: JsonObject;
    begin
        if not CurJsonReq.ReadFrom(CurJsonTxt) then
            exit(false);
    end;

    procedure GetShopwareProductId(Type: Enum "PIMX Master Data Type"; Code: Code[20]; var ShopwareProductId: Text): Boolean
    var
        PIMXCatalogGroup: Record "PIMX Catalog Group";
        PIMXChapter: Record "PIMX Chapter";
        PIMXProductGroup: Record "PIMX Product Group";
        PIMXItemGroup: Record "PIMX Item Group";
        PIMXItem: Record Item;
        PIMXItemVariant: Record "Item Variant";
        PIMXNonstockItem: Record "Nonstock Item";
    begin
        case Type of
            Type::"Catalog Group":
                if PIMXCatalogGroup.Get(Code) then begin
                    ShopwareProductId := FormatId(PIMXCatalogGroup.SystemId);
                    exit(false);
                end;
            Type::Chapter:
                if PIMXChapter.Get(Code) then begin
                    ShopwareProductId := FormatId(PIMXChapter.SystemId);
                    exit(true);
                end;
            Type::"Product Group":
                if PIMXProductGroup.Get(Code) then begin
                    ShopwareProductId := FormatId(PIMXProductGroup.SystemId);
                    exit(true);
                end;
            Type::"Item Group":
                if PIMXItemGroup.Get(Code) then begin
                    ShopwareProductId := FormatId(PIMXItemGroup.SystemId);
                    exit(true);
                end;
            Type::Item:
                if PIMXItem.Get(Code) then begin
                    ShopwareProductId := FormatId(PIMXItem.SystemId);
                    exit(true);
                end;
            Type::"Item Variant":
                if PIMXItemVariant.PIMXGetByVariantNo(Code) then begin
                    ShopwareProductId := FormatId(PIMXItemVariant.SystemId);
                    exit(true);
                end;
            Type::"Catalog Item":
                if PIMXNonstockItem.Get(Code) then begin
                    ShopwareProductId := FormatId(PIMXNonstockItem.SystemId);
                    exit(true);
                end;
        end;
        exit(false);
    end;

    procedure FinalizeShopwareUrl(var Path: Text)
    begin
        if Path.Contains('?') then
            Path += '&_response=true'
        else
            Path += '?_response=true';
    end;


}