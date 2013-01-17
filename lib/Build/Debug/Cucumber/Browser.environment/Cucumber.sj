@STATIC;1.0;p;10;Cucumber.jt;19525;@STATIC;1.0;I;23;Foundation/Foundation.jI;22;AppKit/CPApplication.jt;19450;objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/CPApplication.j", NO);
cucumber_instance = nil;
cucumber_objects = nil;
cucumber_counter = 0;
addCucumberObject = function(obj)
{
    cucumber_counter++;
    cucumber_objects[cucumber_counter] = obj;
    return cucumber_counter;
}
dumpGuiObject = function(obj)
{
    if (!obj)
        return '';
    var resultingXML = "<"+objj_msgSend(obj, "className")+">";
    resultingXML += "<id>"+addCucumberObject(obj)+"</id>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("text")))
        resultingXML += "<text><![CDATA["+objj_msgSend(obj, "text")+"]]></text>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("title")))
        resultingXML += "<title><![CDATA["+objj_msgSend(obj, "title")+"]]></title>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("placeholderString")))
        resultingXML += "<placeholderString><![CDATA["+objj_msgSend(obj, "placeholderString")+"]]></placeholderString>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("tag")))
        resultingXML += "<tag><![CDATA["+objj_msgSend(obj, "tag")+"]]></tag>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("title")))
        resultingXML += "<title><![CDATA["+objj_msgSend(obj, "title")+"]]></title>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("cucappIdentifier")))
        resultingXML += "<cucappIdentifier><![CDATA["+objj_msgSend(obj, "cucappIdentifier")+"]]></cucappIdentifier>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("isKeyWindow")) && objj_msgSend(obj, "isKeyWindow"))
        resultingXML += "<keyWindow>YES</keyWindow>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("objectValue")))
        resultingXML += "<objectValue><![CDATA["+objj_msgSend(CPString, "stringWithFormat:", "%@", objj_msgSend(obj, "objectValue"))+"]]></objectValue>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("identifier")))
        resultingXML += "<identifier><![CDATA["+objj_msgSend(obj, "identifier")+"]]></identifier>";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("isKeyWindow")))
    {
        if (objj_msgSend(obj, "isKeyWindow"))
            resultingXML += "<keyWindow>YES</keyWindow>";
        else
            resultingXML += "<keyWindow>NO</keyWindow>";
    }
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("frame")))
    {
        var frame = objj_msgSend(obj, "frame");
        if (frame)
        {
            resultingXML += "<frame>";
            resultingXML += "<x>"+frame.origin.x+"</x>";
            resultingXML += "<y>"+frame.origin.y+"</y>";
            resultingXML += "<width>"+frame.size.width+"</width>";
            resultingXML += "<height>"+frame.size.height+"</height>";
            resultingXML += "</frame>";
        }
    }
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("subviews")))
    {
        var views = objj_msgSend(obj, "subviews");
        if (views && views.length > 0)
        {
            resultingXML += "<subviews>";
            for (var i = 0; i < views.length; i++)
                resultingXML += dumpGuiObject(views[i]);
            resultingXML += "</subviews>";
        }
        else
        {
            resultingXML += "<subviews/>";
        }
    }
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("itemArray")))
    {
        var items = objj_msgSend(obj, "itemArray");
        if (items && items.length > 0)
        {
            resultingXML += "<items>";
            for (var i = 0; i < items.length; i++)
                resultingXML += dumpGuiObject(items[i]);
            resultingXML += "</items>";
        }
        else
        {
            resultingXML += "<items/>";
        }
    }
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("submenu")))
    {
        var submenu = objj_msgSend(obj, "submenu");
        if (submenu)
            resultingXML += dumpGuiObject(submenu);
    }
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("buttons")))
    {
        var buttons = objj_msgSend(obj, "buttons");
        if (buttons && buttons.length > 0)
        {
            resultingXML += "<buttons>";
            for (var i = 0; i < buttons.length; i++)
                resultingXML += dumpGuiObject(buttons[i]);
            resultingXML += "</buttons>";
        }
        else
        {
            resultingXML += "<buttons/>";
        }
    }
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("contentView")))
    {
        resultingXML += "<contentView>";
        resultingXML += dumpGuiObject(objj_msgSend(obj, "contentView"));
        resultingXML += "</contentView>";
    }
    resultingXML += "</"+objj_msgSend(obj, "className")+">";
    return resultingXML;
}
{var the_class = objj_allocateClassPair(CPObject, "Cucumber"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("requesting"), new objj_ivar("time_to_die"), new objj_ivar("launched")]);



       
       




       
       
















objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("init"), function $Cucumber__init(self, _cmd)
{
    if (self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("Cucumber").super_class }, "init"))
    {
        cucumber_instance = self;
        self.requesting = YES;
        self.time_to_die = NO;
        self.launched = NO;
        objj_msgSend(objj_msgSend(CPNotificationCenter, "defaultCenter"), "addObserver:selector:name:object:", self, sel_getUid("applicationDidFinishLaunching:"), CPApplicationDidFinishLaunchingNotification, nil);
    }
    return self;
}
,["id"]), new objj_method(sel_getUid("startRequest"), function $Cucumber__startRequest(self, _cmd)
{
    self.requesting = YES;
    var request = objj_msgSend(objj_msgSend(CPURLRequest, "alloc"), "initWithURL:", "/cucumber");
    objj_msgSend(request, "setHTTPMethod:", "GET");
    objj_msgSend(CPURLConnection, "connectionWithRequest:delegate:", request, self);
}
,["void"]), new objj_method(sel_getUid("startResponse:withError:"), function $Cucumber__startResponse_withError_(self, _cmd, result, error)
{
    self.requesting = NO;
    var request = objj_msgSend(objj_msgSend(CPURLRequest, "alloc"), "initWithURL:", "/cucumber");
    objj_msgSend(request, "setHTTPMethod:", "POST");
    objj_msgSend(request, "setHTTPBody:", objj_msgSend(CPString, "JSONFromObject:", { result: result, error: error}));
    objj_msgSend(CPURLConnection, "connectionWithRequest:delegate:", request, self);
}
,["void","id","CPString"]), new objj_method(sel_getUid("connection:didFailWithError:"), function $Cucumber__connection_didFailWithError_(self, _cmd, connection, error)
{
    CPLog.error("Connection failed");
}
,["void","CPURLConnection","id"]), new objj_method(sel_getUid("connection:didReceiveResponse:"), function $Cucumber__connection_didReceiveResponse_(self, _cmd, connection, response)
{
}
,["void","CPURLConnection","CPHTTPURLResponse"]), new objj_method(sel_getUid("connection:didReceiveData:"), function $Cucumber__connection_didReceiveData_(self, _cmd, connection, data)
{
    if (self.requesting)
    {
        var result = nil,
            error = nil;
        try
        {
            if (data != null && data != "")
            {
                var request = objj_msgSend(data, "objectFromJSON");
                if (request)
                {
                    var msg = CPSelectorFromString(request.name + ":");
                    if (objj_msgSend(self, "respondsToSelector:", msg))
                        result = objj_msgSend(self, "performSelector:withObject:", msg, request.params);
                    else if (objj_msgSend(objj_msgSend(CPApp, "delegate"), "respondsToSelector:", msg))
                        result = objj_msgSend(objj_msgSend(CPApp, "delegate"), "performSelector:withObject:", msg, request.params);
                    else
                    {
                        error = "Unhandled message: "+request.name;
                        console.warn(error);
                    }
                }
            }
        }
        catch(e)
        {
            error = e.message;
        }
        objj_msgSend(self, "startResponse:withError:", result, error);
    }
    else
    {
        if (self.time_to_die)
            window.close();
        else
            objj_msgSend(self, "startRequest");
    }
}
,["void","CPURLConnection","CPString"]), new objj_method(sel_getUid("connectionDidFinishLoading:"), function $Cucumber__connectionDidFinishLoading_(self, _cmd, connection)
{
}
,["void","CPURLConnection"]), new objj_method(sel_getUid("restoreDefaults:"), function $Cucumber__restoreDefaults_(self, _cmd, params)
{
    if (objj_msgSend(objj_msgSend(CPApp, "delegate"), "respondsToSelector:", sel_getUid("restoreDefaults:")))
        objj_msgSend(objj_msgSend(CPApp, "delegate"), "restoreDefaults:", params);
    return "OK";
}
,["CPString","CPDictionary"]), new objj_method(sel_getUid("outputView:"), function $Cucumber__outputView_(self, _cmd, params)
{
    cucumber_counter = 0;
    cucumber_objects = [];
    return objj_msgSend(CPApp, "xmlDescription");
}
,["CPString","CPArray"]), new objj_method(sel_getUid("simulateTouch:"), function $Cucumber__simulateTouch_(self, _cmd, params)
{
    var obj = cucumber_objects[params[0]];
    if (!obj)
        return "NOT FOUND";
    objj_msgSend(obj, "performClick:", self);
    return "OK";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("closeWindow:"), function $Cucumber__closeWindow_(self, _cmd, params)
{
    var obj = cucumber_objects[params[0]];
    if (!obj)
        return "NOT FOUND";
    objj_msgSend(obj, "performClose:", self);
    return "OK";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("performMenuItem:"), function $Cucumber__performMenuItem_(self, _cmd, params)
{
    var obj = cucumber_objects[params[0]];
    if (!obj)
        return "NOT FOUND";
    objj_msgSend(objj_msgSend(obj, "target"), "performSelector:withObject:", objj_msgSend(obj, "action"), obj);
    return "OK";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("closeBrowser:"), function $Cucumber__closeBrowser_(self, _cmd, params)
{
    self.time_to_die = YES;
    return "OK";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("launched:"), function $Cucumber__launched_(self, _cmd, params)
{
    if (self.launched || CPApp._finishedLaunching)
        return "YES";
    return "NO";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("selectFrom:"), function $Cucumber__selectFrom_(self, _cmd, params)
{
    var obj = cucumber_objects[params[1]];
    if (!obj)
        return "OBJECT NOT FOUND";
    var columns = objj_msgSend(obj, "tableColumns");
    if (objj_msgSend(objj_msgSend(obj, "dataSource"), "respondsToSelector:", sel_getUid("tableView:objectValueForTableColumn:row:")))
    {
        for (var i = 0; i < objj_msgSend(columns, "count"); i++)
        {
            var column = columns[i];
            for (var j = 0; j < objj_msgSend(obj, "numberOfRows"); j++)
            {
                var data = objj_msgSend(objj_msgSend(obj, "dataSource"), "tableView:objectValueForTableColumn:row:", obj, column, j);
                objj_msgSend(obj, "selectRowIndexes:byExtendingSelection:", objj_msgSend(CPIndexSet, "indexSetWithIndex:", j), NO);
                if (objj_msgSend(CPString, "stringWithFormat:", "%@", data) === params[0])
                    return "OK";
            }
        }
    }
    if (objj_msgSend(objj_msgSend(obj, "dataSource"), "respondsToSelector:", sel_getUid("outlineView:numberOfChildrenOfItem:")))
        if (objj_msgSend(self, "searchForObjectValue:inItemsInOutlineView:forItem:", params[0], obj, nil))
            return "OK";
    return "DATA NOT FOUND";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("searchForObjectValue:inItemsInOutlineView:forItem:"), function $Cucumber__searchForObjectValue_inItemsInOutlineView_forItem_(self, _cmd, value, obj, item)
{
    for (var i = 0; i < objj_msgSend(objj_msgSend(obj, "dataSource"), "outlineView:numberOfChildrenOfItem:", obj, item); i++)
    {
        var child = objj_msgSend(objj_msgSend(obj, "dataSource"), "outlineView:child:ofItem:", obj, i, item),
            testValue = objj_msgSend(objj_msgSend(obj, "dataSource"), "outlineView:objectValueForTableColumn:byItem:", obj, nil, child);
        if (testValue === value)
            return YES;
        if (objj_msgSend(self, "searchForObjectValue:inItemsInOutlineView:forItem:", value, obj, child))
        {
            var index = objj_msgSend(obj, "rowForItem:", value);
            objj_msgSend(obj, "selectRowIndexes:byExtendingSelection:", objj_msgSend(CPIndexSet, "indexSetWithIndex:", index), NO);
            return YES;
        }
    }
    return NO;
}
,["BOOL","id","CPOutlineView","id"]), new objj_method(sel_getUid("selectMenu:"), function $Cucumber__selectMenu_(self, _cmd, params)
{
    var obj = objj_msgSend(CPApp, "mainMenu");
    if (!obj)
        return "MENU NOT FOUND";
    var item = objj_msgSend(obj, "itemWithTitle:", params[0]);
    if (item)
        return "OK";
    return "MENU ITEM NOT FOUND";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("findIn:"), function $Cucumber__findIn_(self, _cmd, params)
{
    return objj_msgSend(self, "selectFrom:", params);
}
,["CPString","CPArray"]), new objj_method(sel_getUid("textFor:"), function $Cucumber__textFor_(self, _cmd, params)
{
    var obj = cucumber_objects[params[0]];
    if (!obj)
        return "__CUKE_ERROR__";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("stringValue")))
        return objj_msgSend(obj, "stringValue");
    return "__CUKE_ERROR__";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("objectValueFor:"), function $Cucumber__objectValueFor_(self, _cmd, params)
{
    var obj = cucumber_objects[params[0]];
    if (!obj)
        return "__CUKE_ERROR__";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("objectValue")))
        return objj_msgSend(CPString, "stringWithFormat:", "%@", objj_msgSend(obj, "objectValue"));
    return nil;
}
,["id","CPArray"]), new objj_method(sel_getUid("doubleClick:"), function $Cucumber__doubleClick_(self, _cmd, params)
{
    var obj = cucumber_objects[params[0]];
    if (!obj)
        return "OBJECT NOT FOUND";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("doubleAction")) && objj_msgSend(obj, "doubleAction") !== null)
    {
        objj_msgSend(objj_msgSend(obj, "target"), "performSelector:withObject:", objj_msgSend(obj, "doubleAction"), self);
        return "OK";
    }
    return "NO DOUBLE ACTION";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("setText:"), function $Cucumber__setText_(self, _cmd, params)
{
    var obj = cucumber_objects[params[1]];
    if (!obj)
        return "OBJECT NOT FOUND";
    if (objj_msgSend(obj, "respondsToSelector:", sel_getUid("setStringValue:")))
    {
        objj_msgSend(obj, "setStringValue:", params[0]);
        objj_msgSend(self, "propagateValue:forBinding:forObject:", objj_msgSend(obj, "stringValue"), "value", obj);
        return "OK";
    }
    return "CANNOT SET TEXT ON OBJECT";
}
,["CPString","CPArray"]), new objj_method(sel_getUid("propagateValue:forBinding:forObject:"), function $Cucumber__propagateValue_forBinding_forObject_(self, _cmd, value, binding, aObject)
{
    var bindingInfo = objj_msgSend(aObject, "infoForBinding:", binding);
    if (!bindingInfo)
        return;
    var bindingOptions = objj_msgSend(bindingInfo, "objectForKey:", CPOptionsKey);
    if (bindingOptions)
    {
        var transformer = objj_msgSend(bindingOptions, "valueForKey:", CPValueTransformerBindingOption);
        if (!transformer || transformer == objj_msgSend(CPNull, "null"))
        {
            var transformerName = objj_msgSend(bindingOptions, "valueForKey:", CPValueTransformerNameBindingOption);
            if (transformerName && transformerName != objj_msgSend(CPNull, "null"))
                transformer = objj_msgSend(CPValueTransformer, "valueTransformerForName:", transformerName);
        }
        if (transformer && transformer != objj_msgSend(CPNull, "null")) {
            if (objj_msgSend(objj_msgSend(transformer, "class"), "allowsReverseTransformation"))
                value = objj_msgSend(transformer, "reverseTransformedValue:", value);
            else
                CPLog("WARNING: binding \"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
        }
    }
    var boundObject = objj_msgSend(bindingInfo, "objectForKey:", CPObservedObjectKey);
    if (!boundObject || boundObject == objj_msgSend(CPNull, "null"))
    {
        CPLog("ERROR: CPObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }
    var boundKeyPath = objj_msgSend(bindingInfo, "objectForKey:", CPObservedKeyPathKey);
    if (!boundKeyPath || boundKeyPath == objj_msgSend(CPNull, "null"))
    {
        CPLog("ERROR: CPObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }
    objj_msgSend(boundObject, "setValue:forKeyPath:", value, boundKeyPath);
}
,["void","id","CPString","id"]), new objj_method(sel_getUid("applicationDidFinishLaunching:"), function $Cucumber__applicationDidFinishLaunching_(self, _cmd, note)
{
    self.launched = YES;
}
,["void","CPNotification"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("startCucumber"), function $Cucumber__startCucumber(self, _cmd)
{
    if (cucumber_instance == nil)
    {
        objj_msgSend(objj_msgSend(Cucumber, "alloc"), "init");
        objj_msgSend(cucumber_instance, "startRequest");
    }
}
,["void"])]);
}
objj_msgSend(Cucumber, "startCucumber");
       
       
{
var the_class = objj_getClass("CPObject")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"CPObject\"");
var meta_class = the_class.isa;
class_addMethods(the_class, [new objj_method(sel_getUid("className"), function $CPObject__className(self, _cmd)
{
    return CPStringFromClass(objj_msgSend(self, "class"));
}
,["CPString"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("className"), function $CPObject__className(self, _cmd)
{
    return CPStringFromClass(self);
}
,["CPString"])]);
}
       
       
{
var the_class = objj_getClass("CPApplication")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"CPApplication\"");
var meta_class = the_class.isa;class_addMethods(the_class, [new objj_method(sel_getUid("xmlDescription"), function $CPApplication__xmlDescription(self, _cmd)
{
    var resultingXML = "<"+objj_msgSend(self, "className")+">";
    resultingXML += "<id>"+addCucumberObject(self)+"</id>";
    var windows = objj_msgSend(self, "windows");
    if (windows.length > 0)
    {
        resultingXML += "<windows>";
        for (var i = 0; i < windows.length; i++)
            resultingXML += dumpGuiObject(windows[i]);
        resultingXML += "</windows>";
    }
    else
    {
        resultingXML += "<windows />";
    }
    var menu = objj_msgSend(self, "mainMenu");
    if (menu)
    {
        resultingXML += "<menus>";
        resultingXML += dumpGuiObject(menu);
        resultingXML += "</menus>";
    }
    else
    {
        resultingXML += "<menus/>";
    }
    resultingXML += "</"+objj_msgSend(self, "className")+">";
    return resultingXML;
}
,["CPString"])]);
}e;