codeunit 50300 "Update Shopware" implements "PIMX Publication Update Line c4"
{
    var
        PIMXPublicationHeader: Record "PIMX Publication Header";
        PIMXPublicationQueueHelper: Codeunit "PIMX Publication Queue Helper";
        ShopwareHelper: Codeunit "Shopware Helper";
        APIType: Option None,Item,Feature,Category,"Products Feature Set","Product Configurator Setting",Tax,Currency,Order,Text,Media,MediaData,DeleteCategory,DeleteImage,DeleteItem;
        MessageToInsert: Boolean;

    procedure Init()
    begin

    end;

    procedure UpdateFeature(var PIMXPublicationLine: Record "PIMX Publication Line"; PIMXCatalogFeature: Record "PIMX Catalog Feature"; PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean
    var
        PropertyGroupOption: Record "Property Group Option";
        PIMXPublicationLineParent: Record "PIMX Publication Line";
        JsonRequest: JsonToken;
        EmptyJsonReq: JsonObject;
        NewJsonTxt: Text;
        CurJsonTxt: Text;
        DeletePath: Text;
    begin
        if isNullGuid(PIMXPublicationLine."Master Data GUID c1") then
            exit(false);

        PIMXPublicationData.GetMasterPublicationLine(PIMXPublicationLineParent);
        if (PIMXCatalogFeature."Line Type" = PIMXCatalogFeature."Line Type"::Feature) and (PIMXCatalogFeature.Number <> '') then
            if FindOrCreateProperyGroupOption(PIMXPublicationLine.Code, PIMXCatalogFeature.Number, PIMXCatalogFeature.Value, PIMXPublicationLine."Line GUID c1", PropertyGroupOption) then
                if not IsNullGuid(PropertyGroupOption."Shopware Id") then begin
                    JsonRequest := CreateUpdateFeatureJson(PropertyGroupOption."Shopware Id", PIMXPublicationLineParent."Data GUID");
                    JsonRequest.WriteTo(NewJsonTxt);
                    CurJsonTxt := PIMXPublicationLine.GetData();
                    if NewJsonTxt <> CurJsonTxt then begin
                        DeletePath := ShopwareHelper.GetPathFromPubLineData(CurJsonTxt);
                        if DeletePath <> '' then begin
                            DeletePath += ShopwareHelper.FormatId(PIMXPublicationLineParent."Data GUID");
                            CreatePublicationQueueLine(EmptyJsonReq, PIMXPublicationLine.Code, PIMXPublicationLine."Line GUID c1", DeletePath, "PIMX API Method"::Delete);
                        end;
                    end;
                    UpdateLineDataAndSend(PIMXPublicationLine, JsonRequest, APIType::Feature, false, false);
                end;
        exit(true);
    end;

    procedure UpdateFeature(var PIMXPublicationLine: Record "PIMX Publication Line"; PIMXProductFeature: Record "PIMX Product Feature"; PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean;
    var
        PropertyGroupOption: Record "Property Group Option";
        PIMXPublicationLineParent: Record "PIMX Publication Line";
        JsonRequest: JsonToken;
        EmptyJsonReq: JsonObject;
        NewJsonTxt: Text;
        CurJsonTxt: Text;
        DeletePath: Text;
    begin
        if isNullGuid(PIMXPublicationLine."Master Data GUID c1") then
            exit(false);

        PIMXPublicationData.GetMasterPublicationLine(PIMXPublicationLineParent);
        if (PIMXProductFeature."Line Type" = PIMXProductFeature."Line Type"::Feature) and (PIMXProductFeature.Number <> '') then
            if FindOrCreateProperyGroupOption(PIMXPublicationLine.Code, PIMXProductFeature.Number, CopyStr(PIMXProductFeature.Value, 1, 100), PIMXPublicationLine."Line GUID c1", PropertyGroupOption) then
                if not IsNullGuid(PropertyGroupOption."Shopware Id") then begin
                    JsonRequest := CreateUpdateFeatureJson(PropertyGroupOption."Shopware Id", PIMXPublicationLineParent."Data GUID");
                    JsonRequest.WriteTo(NewJsonTxt);
                    CurJsonTxt := PIMXPublicationLine.GetData();
                    if NewJsonTxt <> CurJsonTxt then begin
                        DeletePath := ShopwareHelper.GetPathFromPubLineData(CurJsonTxt);
                        if DeletePath <> '' then begin
                            DeletePath += ShopwareHelper.FormatId(PIMXPublicationLineParent."Data GUID");
                            CreatePublicationQueueLine(EmptyJsonReq, PIMXPublicationLine.Code, PIMXPublicationLine."Line GUID c1", DeletePath, "PIMX API Method"::Delete);
                        end;
                    end;
                    UpdateLineDataAndSend(PIMXPublicationLine, JsonRequest, APIType::Feature, false, false);
                end;
        exit(true);
    end;

    procedure UpdateVariant(var _line: Record "PIMX Publication Line"; ItemVariant: Record "Item Variant"; Data: Codeunit "PIMX Publication Data"): Boolean;
    begin
        //TODO
        exit(true);
    end;

    procedure UpdateText(var PIMXPublicationLine: Record "PIMX Publication Line"; PIMXDescriptionText: Record "PIMX Description Text"; PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean;
    var
        PIMXPublicationLineParent: Record "PIMX Publication Line";
        JsonProduct: JsonObject;
        Id: Text;
    begin
        if isNullGuid(PIMXPublicationLine."Master Data GUID c1") then
            exit(false);

        PIMXPublicationData.GetMasterPublicationLine(PIMXPublicationLineParent);  //.GetParentPublicationLine(PIMXPublicationLineParent);
        Id := ShopwareHelper.FormatId(PIMXPublicationLineParent."Data GUID"); //(PIMXPublicationLine."Line GUID c1");
        JsonProduct.Add('id', Id);
        JsonProduct.Add('description', PIMXDescriptionText.GetText());
        UpdateLineDataAndSend(PIMXPublicationLine, JsonProduct.AsToken(), APIType::Text, false, false);
        exit(true);
    end;

    procedure UpdateCrossReference(var _line: Record "PIMX Publication Line"; AllocationLine: Record "PIMX Allocation Line"; Data: Codeunit "PIMX Publication Data"): Boolean
    begin
        exit(true);
    end;

    procedure UpdateCatalogItem(var _line: Record "PIMX Publication Line"; AllocationLine: Record "PIMX Allocation Line"; Data: Codeunit "PIMX Publication Data"): Boolean
    begin
        exit(true);
    end;

    procedure UpdateItemGroup(var PIMXPublicationLine: Record "PIMX Publication Line"; PIMXAllocationLine: Record "PIMX Allocation Line"; PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean
    var
        JsonRequest: JsonToken;
    begin
        JsonRequest := CreateCategoryJson(PIMXPublicationLine, PIMXPublicationData);
        UpdateLineDataAndSend(PIMXPublicationLine, JsonRequest, APIType::Category, false, false);
        exit(true);
    end;

    procedure UpdateProductGroup(var PIMXPublicationLine: Record "PIMX Publication Line"; PIMXAllocationLine: Record "PIMX Allocation Line"; PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean
    var
        JsonRequest: JsonToken;
    begin
        JsonRequest := CreateCategoryJson(PIMXPublicationLine, PIMXPublicationData);
        UpdateLineDataAndSend(PIMXPublicationLine, JsonRequest, APIType::Category, false, false);
        exit(true);
    end;

    procedure UpdateChapter(var PIMXPublicationLine: Record "PIMX Publication Line"; PIMXAllocationLine: Record "PIMX Allocation Line"; PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean
    var
        JsonRequest: JsonToken;
    begin
        JsonRequest := CreateCategoryJson(PIMXPublicationLine, PIMXPublicationData);
        UpdateLineDataAndSend(PIMXPublicationLine, JsonRequest, APIType::Category, false, false);
        exit(true);
    end;

    procedure UpdateCatalogGroup(var PIMXPublicationLine: Record "PIMX Publication Line"; PIMXAllocationLine: Record "PIMX Allocation Line"; PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean
    var
        JsonRequest: JsonToken;
    begin
        JsonRequest := CreateCategoryJson(PIMXPublicationLine, PIMXPublicationData);
        UpdateLineDataAndSend(PIMXPublicationLine, JsonRequest, APIType::Category, false, false);
        exit(true);
    end;

    procedure UpdateContent(var _line: Record "PIMX Publication Line"; Content: Record "PIMX Product Content"; Data: Codeunit "PIMX Publication Data"): Boolean;
    begin
        exit(false);
    end;

    procedure UpdateDocument(var PIMXPublicationLine: Record "PIMX Publication Line"; PIMXCatalogDocument: Record "PIMX Catalog Document"; PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean
    var
        PIMXDocument: Record "PIMX Document";
        PIMXPublicationLineParent: Record "PIMX Publication Line";
        //PIMXOption2Enum: Codeunit "PIMX Option 2 Enum";
        JsonRequest: JsonObject;
        JsonObj: JsonObject;
        JsonItObj: JsonObject;
        JsonArr: JsonArray;
        JsonItArr: JsonArray;
        JsonArrMember: JsonObject;
        JsonMedia: JsonObject;
        MediaId: Text;
        ShopwId: Text;
    begin
        if PIMXCatalogDocument.Type = PIMXCatalogDocument.Type::Bild then
            if PIMXDocument.Get(PIMXCatalogDocument.Number) then begin
                MediaId := ShopwareHelper.FormatId(PIMXDocument.SystemId);
                JsonRequest.Add('id', MediaId);
                UpdateLineDataAndSend(PIMXPublicationLine, JsonRequest.AsToken(), APIType::Media, false, true);

                JsonRequest.Add('extension', PIMXDocument."Document Class");
                JsonRequest.Add('filename', PIMXDocument."Document ID");
                JsonRequest.Add('url', PIMXDocument."Public Link");
                UpdateLineDataAndSend(PIMXPublicationLine, JsonRequest.AsToken(), APIType::MediaData, false, true);

                //if ShopwareHelper.GetShopwareProductId(PIMXOption2Enum.CatalogDocument_Source2MasterDataType(PIMXCatalogDocument.Source), PIMXCatalogDocument.Code, ShopwId) then begin
                PIMXPublicationData.GetMasterPublicationLine(PIMXPublicationLineParent);
                ShopwId := ShopwareHelper.FormatId(PIMXPublicationLineParent."Data GUID");

                JsonRequest.Remove('extension');
                JsonRequest.Remove('filename');
                JsonRequest.Remove('url');
                JsonRequest.Remove('id');
                JsonMedia.Add('id', MediaId);
                JsonArrMember.Add('media', JsonMedia);
                JsonArrMember.Add('id', ShopwareHelper.FormatId(PIMXPublicationLine."Line GUID c1"));
                JsonArr.Add(JsonArrMember);
                JsonObj.Add('media', JsonArr);
                //JsonRequest.Add('id', ShopwId);
                JsonItObj.Add('data', JsonObj);
                JsonItObj.Add('post', StrSubstNo('/api/product/%1', ShopwId));
                JsonItArr.Add(JsonItObj);
                //JsonRequest.Add('', JsonItArr);
                UpdateLineDataAndSend(PIMXPublicationLine, JsonItArr.AsToken(), APIType::Item, true, false);
                //end;
            end;
        exit(true);
    end;

    procedure UpdateDocumentLine(var _line: Record "PIMX Publication Line"; AllocationLine: Record "PIMX Allocation Line"; Data: Codeunit "PIMX Publication Data"): Boolean
    begin
        exit(true);
    end;

    procedure UpdateKeyword(var _line: Record "PIMX Publication Line"; CatalogKeyword: Record "PIMX Catalog Keyword"; Data: Codeunit "PIMX Publication Data"): Boolean
    begin
        exit(true);
    end;

    procedure UpdateItem(var PIMXPublicationLine: Record "PIMX Publication Line"; PIMXAllocationLine: Record "PIMX Allocation Line"; PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean
    var
        Item: Record Item;
        PIMXPublicationLineParent: Record "PIMX Publication Line";
        JsonRequest: JsonObject;
        JsonProduct: JsonObject;
        JsonCatArr: JsonArray;
        JsonCategory: JsonObject;
        JsonCategTop: JsonObject;
        JsonPriceAr: JsonArray;
        JsonPrice: JsonObject;
        JsonVisArr: JsonArray;
        JsonVis: JsonObject;
        JsonItArr: JsonArray;
        JsonItArM1: JsonObject;
        JsonItArM2: JsonObject;
        Id: Text;
        OldData: Text;
        Inv: Integer;
    begin
        /*if isNullGuid(PIMXPublicationLine."Parent GUID c1") then
            exit(false);*/

        if not Item.Get(PIMXPublicationLine.Nummer) then
            exit(false);
        if PIMXPublicationLine.Code <> PIMXPublicationHeader.Code then
            PIMXPublicationHeader.Get(PIMXPublicationLine.Code);

        PIMXPublicationHeader.TestField("External Code");
        Item.CalcFields(Inventory);
        Id := ShopwareHelper.FormatId(Item.SystemId); //Format(Item.SystemId).Replace('{', '').Replace('}', '').Replace('-', '').ToLower();
        Inv := Round(Item.Inventory, 1, '=');

        JsonVis.Add('salesChannelId', ShopwareHelper.FormatId(PIMXPublicationHeader."External Code"));
        JsonVis.Add('visibility', 30);   //TODO: fix later
        JsonVisArr.Add(JsonVis);

        JsonPrice.Add('currencyId', ShopwareHelper.FormatId(PIMXPublicationHeader.CurrencyId));
        JsonPrice.Add('linked', true);
        JsonPrice.Add('gross', Item."Unit Price");  //TODO: fix later
        JsonPrice.Add('net', Item."Unit Price");    //TODO: check if enough else fix later
        JsonPriceAr.Add(JsonPrice);

        JsonProduct.Add('id', Id);
        JsonProduct.Add('productNumber', Item."No.");
        JsonProduct.Add('name', Item.Description + Item."Description 2");
        JsonProduct.Add('taxId', ShopwareHelper.FormatId(PIMXPublicationHeader.TaxId));
        JsonProduct.Add('stock', Inv);
        JsonProduct.Add('price', JsonPriceAr);
        JsonProduct.Add('visibilities', JsonVisArr);

        if PIMXPublicationLine.GetData() <> '' then
            JsonItArM1.Add('post', StrSubstNo('/api/product/%1', Id))
        else
            JsonItArM1.Add('post', '');
        JsonItArM1.Add('data', JsonProduct);
        JsonItArr.Add(jsonItArM1);

        PIMXPublicationData.GetMasterPublicationLine(PIMXPublicationLineParent);
        //if PIMXPublicationLineParent."Line Type" in [PIMXPublicationLineParent."Line Type"::"Item Group", PIMXPublicationLineParent."Line Type"::"Product Group",
        //                                            PIMXPublicationLineParent."Line Type"::Chapter, PIMXPublicationLineParent."Line Type"::"Catalog Group"] then begin
        if PIMXPublicationLineParent.Zeilenart in [PIMXPublicationLineParent.Zeilenart::Artikelgruppe, PIMXPublicationLineParent.Zeilenart::Warengruppe,
                                                    PIMXPublicationLineParent.Zeilenart::Kapitel, PIMXPublicationLineParent.Zeilenart::Kataloggruppe] then begin
            JsonCategory.Add('type', 'product');
            JsonCategory.Add('id', Id);
            JsonCatArr.Add(JsonCategory);
            JsonCategTop.Add('products', JsonCatArr);

            JsonItArM2.Add('post', StrSubstNo('/api/category/%1', ShopwareHelper.FormatId(PIMXPublicationLineParent."Line GUID c1")));
            JsonItArM2.Add('data', JsonCategTop);
            JsonItArr.Add(jsonItArM2);
        end;
        UpdateLineDataAndSend(PIMXPublicationLine, JsonItArr.AsToken(), APIType::Item, false, false);
        exit(true);
    end;

    local procedure UpdateLineDataAndSend(var PIMXPublicationLine: Record "PIMX Publication Line"; JsonRequest: JsonToken; _type: Option APIType; ForcePatch: Boolean; InsertImmediatelly: Boolean): Boolean;
    var
        PIMXPublicationQueue: Record "PIMX Publication Queue";
        PIMXAuthentication: Record "PIMX Authentication";
        LineData: Text;
        JsonText: Text;
        JsonData: Text;
        APIMethod: Enum "PIMX API Method";
        ShopwareURL: Text;
        AnyJsonToken: JsonToken;
        JsonPath: JsonToken;
        JsonCatg: JsonToken;
        AnyJsonArray: JsonArray;
        AnyJsonObject: JsonObject;
        Id: Text;
        Ext: Text;
        FileName: Text;
    begin
        MessageToInsert := false;
        LineData := PIMXPublicationLine.GetData();
        if PIMXPublicationLine.Code <> PIMXPublicationHeader.Code then
            PIMXPublicationHeader.Get(PIMXPublicationLine.Code);

        if not ShopwareHelper.GetAuth(PIMXPublicationHeader."Base URL", PIMXAuthentication) then
            exit(false);
        PIMXPublicationQueueHelper.SetAuth(PIMXAuthentication);
        PIMXPublicationQueueHelper.SetType("PIMX API Type"::Default);

        ShopwareURL := PIMXPublicationHeader."Base URL"; //TODO: fix later
        if ShopwareURL.EndsWith('/') then
            ShopwareURL := ShopwareURL.TrimEnd('/');

        if JsonRequest.IsObject() then
            AnyJsonObject := JsonRequest.AsObject();
        if JsonRequest.IsArray() then
            AnyJsonArray := JsonRequest.AsArray();

        if AnyJsonObject.Get('id', AnyJsonToken) then begin
            AnyJsonToken.WriteTo(Id);
            Id := Id.Replace('"', '');
        end;

        APIMethod := APIMethod::Post;
        case _type of
            /*APIType::DeleteCategory:
                begin
                    APIMethod := APIMethod::Delete;
                    ShopwareURL += ''; 
                end;*/
            APIType::DeleteImage:
                begin
                    APIMethod := APIMethod::Delete;
                    ShopwareURL += StrSubstNo('/api/product/%1/media/%2', Id, ShopwareHelper.FormatId(PIMXPublicationLine."Line GUID c1"));

                    AnyJsonObject.Remove('id');
                end;
            APIType::DeleteItem:
                begin
                    APIMethod := APIMethod::Delete;
                    ShopwareURL += StrSubstNo('/api/product/%1', Id);
                end;
            APIType::Category:
                ShopwareURL += '/api/category';
            APIType::Feature:
                //begin
                /*if AnyJsonObject.Get('', AnyJsonToken) then
                    AnyJsonArray := AnyJsonToken.AsArray();*/
                foreach AnyJsonToken in AnyJsonArray do begin
                    if AnyJsonToken.AsObject().Get('post', JsonPath) then
                        JsonPath.WriteTo(Id);
                    if Id <> '' then
                        ShopwareURL += Id.Replace('"', '');
                    if AnyJsonToken.AsObject().Get('data', JsonPath) then
                        JsonPath.WriteTo(JsonData);
                end;
            //end;
            APIType::Item:
                begin
                    //if JsonRequest.Get('', AnyJsonToken) then begin
                    //    AnyJsonArray := AnyJsonToken.AsArray();
                    //standard part
                    if AnyJsonArray.Get(0, AnyJsonToken) then begin
                        if AnyJsonToken.AsObject().Get('post', JsonPath) then
                            JsonPath.WriteTo(Id);
                        Id := Id.Replace('"', '');
                        if (Id <> '') or (ForcePatch) then begin
                            APIMethod := APIMethod::Patch;
                            ShopwareURL += Id;//StrSubstNo('/api/product/%1', Id);
                        end else begin
                            APIMethod := APIMethod::Post;
                            ShopwareURL += '/api/product';
                        end;
                        if AnyJsonToken.AsObject().Get('data', JsonPath) then begin
                            if APIMethod = APIMethod::Patch then
                                JsonPath.AsObject().Remove('visibilities');
                            JsonPath.WriteTo(JsonData);
                        end;

                        if AnyJsonArray.Count > 1 then begin //create pub queue if more than one JSON block else will be created later
                            PIMXPublicationQueueHelper.SetMessageToInsert(PIMXPublicationQueue, APIMethod, ShopwareURL + '?_response=true', JsonData, PIMXPublicationLine."Line GUID c1", 'application/json');
                            PIMXPublicationQueueHelper.InsertPendingMessage();
                        end;
                    end;
                    //assign to categories
                    if AnyJsonArray.Get(1, AnyJsonToken) then begin
                        if AnyJsonToken.AsObject().Get('post', JsonCatg) then
                            JsonCatg.WriteTo(Id);
                        if Id <> '' then begin
                            Id := Id.Replace('"', '');
                            APIMethod := APIMethod::Patch;
                            ShopwareURL := ShopwareURL.Replace('/api/product', '');
                            ShopwareURL += Id;
                        end;
                        if AnyJsonToken.AsObject().Get('data', JsonCatg) then
                            JsonCatg.WriteTo(JsonData);
                    end;
                end;
            /*if (LineData <> '') or (ForcePatch) then begin //only for new lines
                APIMethod := APIMethod::Patch;
                ShopwareURL += StrSubstNo('/api/product/%1', Id);
                if ForcePatch then
                    JsonRequest.Remove('id');
            end else begin
                APIMethod := APIMethod::Post;
                ShopwareURL += '/api/product';
            end;*/
            APIType::Text:
                begin
                    APIMethod := APIMethod::Patch;
                    ShopwareURL += StrSubstNo('/api/product/%1', Id);
                    AnyJsonObject.Remove('id');
                end;
            APIType::Media:
                begin
                    APIMethod := APIMethod::Post;
                    ShopwareURL += '/api/media';
                end;
            APIType::MediaData:
                begin
                    APIMethod := APIMethod::Post;
                    AnyJsonObject.Get('extension', AnyJsonToken);
                    AnyJsonToken.WriteTo(Ext);
                    Ext := Ext.Replace('"', '');
                    AnyJsonObject.Get('filename', AnyJsonToken);
                    AnyJsonToken.WriteTo(FileName);
                    FileName := FileName.Replace('"', '');
                    AnyJsonObject.Remove('id');
                    AnyJsonObject.Remove('extension');
                    AnyJsonObject.Remove('filename');
                    ShopwareURL += StrSubstNo('/api/_action/media/%1/upload?extension=%2&fileName=%3', Id, Ext, FileName);
                end;
        end;

        ShopwareHelper.FinalizeShopwareUrl(ShopwareURL); //adding _response=true

        if (APIMethod = APIMethod::Empty) OR (ShopwareURL = '') then
            exit(false);

        JsonRequest.WriteTo(JsonText); //write full JSON to Line data
        if JsonData = '' then
            JsonData := JsonText;
        if JsonText <> LineData then begin
            if JsonText <> '{}' then
                PIMXPublicationLine.SetData(JsonText);

            PIMXPublicationQueueHelper.SetMessageToInsert(PIMXPublicationQueue, APIMethod, ShopwareURL, JsonData, PIMXPublicationLine."Line GUID c1", 'application/json');
            if (InsertImmediatelly) or (_type in [APIType::DeleteCategory, APIType::DeleteImage, APIType::DeleteItem]) then
                PIMXPublicationQueueHelper.InsertPendingMessage()
            else
                MessageToInsert := true;
            exit(true);
        end;
        exit(false);
    end;

    procedure ReferenceIsValid(dataVariant: Variant; _PIMXPublicationData: Codeunit "PIMX Publication Data"): Boolean;
    begin
        exit(true);
    end;

    procedure BeforeModifyExistingLine(var _PIMXPublicationLine: Record "PIMX Publication Line"; _PIMXPublicationData: Codeunit "PIMX Publication Data"; var _isValid: Boolean);
    begin
        if MessageToInsert AND _isValid then
            PIMXPublicationQueueHelper.InsertPendingMessage();

        MessageToInsert := false;
    end;

    procedure BeforeInsertNewLine(var _PIMXPublicationLine: Record "PIMX Publication Line"; _PIMXPublicationData: Codeunit "PIMX Publication Data"; var _isValid: Boolean);
    begin
        if MessageToInsert AND _isValid then
            PIMXPublicationQueueHelper.InsertPendingMessage();

        MessageToInsert := false;
    end;

    procedure ReferenceIsValid(_lineVariant: Variant; _PIMXPublicationData: Codeunit "PIMX Publication Data"; var _isValid: Boolean);
    begin
        _isValid := _isValid;
    end;

    [EventSubscriber(ObjectType::Table, Database::"PIMX Publication Line", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure OnDeletePublicationLine(var Rec: Record "PIMX Publication Line"; RunTrigger: Boolean);
    var
        PIMXPublicationLineParent: Record "PIMX Publication Line";
        EmptyJsonRequest: JsonObject;
        _type: Option APIType;
        Id: Text;
        DataGuid: Guid;
    begin

        case Rec."Line Type" of
            //Rec.Zeilenart::Bild,
            Rec."Line Type"::Picture:
                begin
                    _type := APIType::DeleteImage;
                    if ShopwareHelper.GetGuidFromParent(Rec."Master Data GUID c1", DataGuid) then
                        EmptyJsonRequest.Add('id', ShopwareHelper.FormatId(DataGuid))
                    else
                        exit;
                end;
            Rec."Line Type"::Item:
                if IsNullGuid(Rec."Sister Line GUID c1") then
                    _type := APIType::DeleteItem
                else
                    exit;
            Rec."Line Type"::"Item Group",
            Rec."Line Type"::"Product Group",
            Rec."Line Type"::Chapter,
            Rec."Line Type"::"Catalog Group":
                _type := APIType::DeleteCategory;
            else
                _type := APIType::None;
        end;
        if _type <> APIType::None then
            UpdateLineDataAndSend(Rec, EmptyJsonRequest.AsToken(), _type, false, false);
    end;

    local procedure CreateCategoryJson(PIMXPublicationLine: Record "PIMX Publication Line"; PIMXPublicationData: Codeunit "PIMX Publication Data") JsonRequest: JsonToken
    var
        PIMXPublicationLineParent: Record "PIMX Publication Line";
        JsonObj: JsonObject;
    begin
        JsonObj.Add('id', ShopwareHelper.FormatId(PIMXPublicationLine."Line GUID c1"));
        if not IsNullGuid(PIMXPublicationLine."Master Data GUID c1") then begin
            PIMXPublicationData.GetMasterPublicationLine(PIMXPublicationLineParent);
            JsonObj.Add('parentId', ShopwareHelper.FormatId(PIMXPublicationLineParent."Line GUID c1"));
        end;
        JsonObj.Add('displayNestedProducts', true);
        JsonObj.Add('type', 'page');
        JsonObj.Add('productAssignmentType', 'product');
        JsonObj.Add('name', PIMXPublicationLine.Bezeichnung);
        JsonRequest := JsonObj.AsToken();
    end;

    local procedure CreateUpdateFeatureJson(PropertyOptionId: Guid; ProductId: Guid): JsonToken
    var
        JsonReqArr: JsonArray;
        JsonRequest: JsonObject;
        JsonData: JsonObject;
    //JsonFinal: JsonObject;
    begin
        JsonData.Add('id', ShopwareHelper.FormatId(ProductId));
        JsonRequest.Add('data', JsonData);
        JsonRequest.Add('post', StrSubstNo('/api/property-group-option/%1/product-properties/', ShopwareHelper.FormatId(PropertyOptionId)));
        JsonReqArr.Add(JsonRequest);
        exit(JsonReqArr.AsToken());
        //JsonFinal.Add('', JsonReqArr);
        //exit(JsonFinal);
    end;

    procedure FindOrCreateProperyGroupOption(PIMXPublicationCode: Code[20]; PIMXFeatureID: Code[20]; PIMXValue: Text[100]; LineGuid: Guid; var PropertyGroupOption: Record "Property Group Option"): Boolean
    var
        PIMXFeature: Record "PIMX Feature";
    begin
        if not PIMXFeature.Get(PIMXFeatureID) then
            exit(false);
        if PropertyGroupOption.Get(PIMXPublicationCode, PIMXFeature.SystemId, PIMXValue) then
            exit(true);

        if PropertyGroupOption.Get(PIMXPublicationCode, PIMXFeature.SystemId, '') then
            if PIMXValue <> '' then begin
                PropertyGroupOption.Value := PIMXValue;
                PropertyGroupOption."Shopware Id" := System.CreateGuid();
                PropertyGroupOption.PubLineGuid_Set(LineGuid);
                PropertyGroupOption.Modify();
                exit(true);
            end;

        PropertyGroupOption.Init();
        PropertyGroupOption.Validate("Publication Code", PIMXPublicationCode);
        PropertyGroupOption.Validate("Feature Id", PIMXFeature.SystemId);
        if PIMXValue <> '' then begin
            //PropertyGroupOption.Validate(Value, PIMXValue);
            PropertyGroupOption.Value := PIMXValue;
            PropertyGroupOption."Shopware Id" := System.CreateGuid();
        end;
        PropertyGroupOption.PubLineGuid_Set(LineGuid);
        PropertyGroupOption.Insert(true);
        exit(true);
    end;

    procedure CreatePropertyGroup(FeatureId: Guid; Value: Text[100]; PIMXPublicationHeaderCode: Code[20]; LineGuid: Guid)
    var
        PIMXFeature: Record "PIMX Feature";
        JsonRequest: JsonObject;
        Filterable: Boolean;
    begin
        if IsNullGuid(FeatureId) then
            exit
        else
            PIMXFeature.GetBySystemId(FeatureId);

        Filterable := PIMXFeature."Default Feature Type" = PIMXFeature."Default Feature Type"::Filter;
        JsonRequest.Add('id', ShopwareHelper.FormatId(FeatureId));
        JsonRequest.Add('name', PIMXFeature.Description);
        JsonRequest.Add('displayType', 'alphanumeric'); //TODO: fix with Field Type?
        JsonRequest.Add('sortingType', 'alphanumeric'); //TODO: fix later
        JsonRequest.Add('filterable', Filterable);

        CreatePublicationQueueLine(JsonRequest, PIMXPublicationHeaderCode, LineGuid, '/api/property-group');
        /*if Value <> '' then
            CreatePropertyGroupValue(FeatureId, Value, PIMXPublicationHeaderCode, LineGuid, PIMXFeature."Group System Number");*/
    end;

    procedure CreatePropertyGroupValue(FeatureId: Guid; Value: Text[100]; ShopwareId: Guid; PIMXPublicationHeaderCode: Code[20]; LineGuid: Guid)
    var
        JsonRequest: JsonObject;
    begin
        JsonRequest.Add('id', ShopwareHelper.FormatId(ShopwareId));
        JsonRequest.Add('name', Value);
        CreatePublicationQueueLine(JsonRequest, PIMXPublicationHeaderCode, LineGuid, StrSubstNo('/api/property-group/%1/options', ShopwareHelper.FormatId(FeatureId)));
    end;

    procedure CreatePublicationQueueLine(JsonRequest: JsonObject; PIMXPublicationHeaderCode: Code[20]; LineGuid: Guid; Path: Text)
    var
        PIMXPublicationQueue: Record "PIMX Publication Queue";
        PIMXAuthentication: Record "PIMX Authentication";
        ShopwareURL: Text;
        JsonRequestTxt: Text;
    begin
        if not PIMXPublicationHeader.Get(PIMXPublicationHeaderCode) then
            exit;
        ShopwareURL := PIMXPublicationHeader."Base URL";
        if ShopwareURL.EndsWith('/') then
            ShopwareURL := ShopwareURL.TrimEnd('/');
        if Path <> '' then
            ShopwareURL += Path;
        ShopwareHelper.FinalizeShopwareUrl(ShopwareURL);
        JsonRequest.WriteTo(JsonRequestTxt);

        if not ShopwareHelper.GetAuth(PIMXPublicationHeader."Base URL", PIMXAuthentication) then
            exit;
        PIMXPublicationQueueHelper.SetAuth(PIMXAuthentication);
        PIMXPublicationQueueHelper.SetType("PIMX API Type"::Default);
        PIMXPublicationQueueHelper.SetMessageToInsert(PIMXPublicationQueue, "PIMX API Method"::Post, ShopwareURL, JsonRequestTxt, LineGuid, 'application/json');
        PIMXPublicationQueueHelper.InsertPendingMessage();
    end;

    procedure CreatePublicationQueueLine(JsonRequest: JsonObject; PIMXPublicationHeaderCode: Code[20]; LineGuid: Guid; Path: Text; Method: Enum "PIMX API Method")
    var
        PIMXPublicationQueue: Record "PIMX Publication Queue";
        PIMXAuthentication: Record "PIMX Authentication";
        ShopwareURL: Text;
        JsonRequestTxt: Text;
    begin
        if not PIMXPublicationHeader.Get(PIMXPublicationHeaderCode) then
            exit;
        ShopwareURL := PIMXPublicationHeader."Base URL";
        if ShopwareURL.EndsWith('/') then
            ShopwareURL := ShopwareURL.TrimEnd('/');
        if Path <> '' then
            ShopwareURL += Path;
        ShopwareHelper.FinalizeShopwareUrl(ShopwareURL);
        JsonRequest.WriteTo(JsonRequestTxt);

        if not ShopwareHelper.GetAuth(PIMXPublicationHeader."Base URL", PIMXAuthentication) then
            exit;
        PIMXPublicationQueueHelper.SetAuth(PIMXAuthentication);
        PIMXPublicationQueueHelper.SetType("PIMX API Type"::Default);
        PIMXPublicationQueueHelper.SetMessageToInsert(PIMXPublicationQueue, Method, ShopwareURL, JsonRequestTxt, LineGuid, 'application/json');
        PIMXPublicationQueueHelper.InsertPendingMessage();
    end;
}