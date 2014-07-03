/*
* Copyright 2010, Automagic Software Pty Ltd All rights reserved.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>
*/

@import <Foundation/Foundation.j>
@import <AppKit/CPApplication.j>
@import <AppKit/CPToolbarItem.j>

@import "HelperCategories.j"

@global CPApp
@global __PRETTY_FUNCTION__

cucumber_instance = nil;
cucumber_objects = nil;
cucumber_counter = 0;

function addCucumberObject(obj)
{
    cucumber_counter++;
    cucumber_objects[cucumber_counter] = obj;

    return cucumber_counter;
}

function dumpGuiObject(obj)
{
    if (!obj)
        return '';

    var resultingXML = "<" + [obj className] + ">";
    resultingXML += "<id>" + addCucumberObject(obj) + "</id>";

    if ([obj respondsToSelector:@selector(text)])
        resultingXML += "<text><![CDATA[" + [obj text] + "]]></text>";

    if ([obj respondsToSelector:@selector(title)])
        resultingXML += "<title><![CDATA[" + [obj title] + "]]></title>";

    if ([obj respondsToSelector:@selector(placeholderString)])
        resultingXML += "<placeholderString><![CDATA[" + [obj placeholderString] + "]]></placeholderString>";

    if ([obj respondsToSelector:@selector(tag)])
        resultingXML += "<tag><![CDATA[" + [obj tag] + "]]></tag>";

    if ([obj respondsToSelector:@selector(label)])
        resultingXML += "<label><![CDATA[" + [obj label] + "]]></label>";

    if ([obj respondsToSelector:@selector(cucappIdentifier)])
        resultingXML += "<cucappIdentifier><![CDATA[" + [obj cucappIdentifier] + "]]></cucappIdentifier>";

    if ([obj respondsToSelector:@selector(isKeyWindow)] && [obj isKeyWindow])
        resultingXML += "<keyWindow>YES</keyWindow>";

    if ([obj respondsToSelector:@selector(objectValue)])
        resultingXML += "<objectValue><![CDATA[" + [CPString stringWithFormat: "%@", [obj objectValue]] + "]]></objectValue>";

    if ([obj respondsToSelector:@selector(identifier)])
        resultingXML += "<identifier><![CDATA[" + [obj identifier] + "]]></identifier>";

    if ([obj respondsToSelector:@selector(isKeyWindow)])
    {
        if ([obj isKeyWindow])
            resultingXML += "<keyWindow>YES</keyWindow>";
        else
            resultingXML += "<keyWindow>NO</keyWindow>";
    }

    if ([obj respondsToSelector: @selector(frame)])
    {
        var frame = [obj frame];

        if (frame)
        {
            resultingXML += "<frame>";
            resultingXML += "<x>" + frame.origin.x + "</x>";
            resultingXML += "<y>" + frame.origin.y + "</y>";
            resultingXML += "<width>" + frame.size.width + "</width>";
            resultingXML += "<height>" + frame.size.height + "</height>";
            resultingXML += "</frame>";
        }
    }

    if ([obj respondsToSelector: @selector(subviews)])
    {
        var views = [obj subviews];

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

    if ([obj respondsToSelector: @selector(itemArray)])
    {
        var items = [obj itemArray];

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

    if ([obj respondsToSelector: @selector(submenu)])
    {
        var submenu = [obj submenu];

        if (submenu)
            resultingXML += dumpGuiObject(submenu);
    }

    if ([obj respondsToSelector: @selector(buttons)])
    {
        var buttons = [obj buttons];

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

    if ([obj respondsToSelector: @selector(contentView)])
    {
        resultingXML += "<contentView>";
        resultingXML += dumpGuiObject([obj contentView]);
        resultingXML += "</contentView>";
    }

    resultingXML += "</" + [obj className] + ">";

    return resultingXML;
}



@implementation Cucumber : CPObject
{
    BOOL requesting;
    BOOL time_to_die;
    BOOL launched;
}

+ (void)startCucumber
{

    if (cucumber_instance == nil)
    {
        [[Cucumber alloc] init];
        [cucumber_instance startRequest];
    }
}

- (id)init
{
    if (self = [super init])
    {
        // initialization code here
        cucumber_instance = self;
        requesting = YES;
        time_to_die = NO;
        launched = NO;

        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:CPApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }

    return self;
}

- (void)startRequest
{
    requesting = YES;

    var request = [[CPURLRequest alloc] initWithURL:@"/cucumber"];

    [request setHTTPMethod:@"GET"];

    [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)startResponse:(id)result withError:(CPString)error
{
    requesting = NO;

    var request = [[CPURLRequest alloc] initWithURL:@"/cucumber"];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[CPString JSONFromObject:{result: result, error: error}]];

    [CPURLConnection connectionWithRequest:request delegate:self];
}


#pragma mark -
#pragma mark connection delegate methods

- (void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
    CPLog.error("Connection failed");
}


- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
    // do nothing
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if (requesting)
    {
        var result = nil,
            error = nil;

        try
        {
            if (data != null && data != "")
            {
                var request = [data objectFromJSON];

                if (request)
                {
                    var msg = CPSelectorFromString(request.name + ":");

                    if ([self respondsToSelector:msg])
                        result = [self performSelector:msg withObject:request.params];
                    else if ([[CPApp delegate] respondsToSelector:msg])
                        result = [[CPApp delegate] performSelector:msg withObject:request.params];
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

        [self startResponse:result withError:error];

    }
    else
    {
        if (time_to_die)
            window.close();
        else
            [self startRequest];
    }
}

- (void)connectionDidFinishLoading:(CPURLConnection)connection
{
}


#pragma mark -
#pragma mark Cucumber actions

- (CPString)restoreDefaults:(CPDictionary)params
{
    if ([[CPApp delegate] respondsToSelector: @selector(restoreDefaults:)])
        [[CPApp delegate] restoreDefaults: params];

    return "OK";
}

- (CPString)outputView:(CPArray)params
{
    cucumber_counter = 0;
    cucumber_objects = [];

    return [CPApp xmlDescription];
}

- (CPString)simulateTouch:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return "NOT FOUND";

    if ([obj isKindOfClass:[CPToolbarItem class]])
        [[obj target] performSelector:[obj action] withObject:obj];
    else
        [obj performClick: self];

    return "OK";
}

- (CPString)closeWindow:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return "NOT FOUND";

    [obj performClose: self];
    return "OK";
}

- (CPString)performMenuItem:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return "NOT FOUND";

    [[obj target] performSelector: [obj action] withObject: obj];
    return "OK";
}

- (CPString)closeBrowser:(CPArray)params
{
    time_to_die = YES;
    return "OK";
}

- (CPString)launched:(CPArray)params
{
    if (launched || CPApp._finishedLaunching)
        return "YES";

    return "NO";
}

- (id)objectValueFor:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return "__CUKE_ERROR__";

    if ([obj respondsToSelector:@selector(objectValue)])
        return @"" + [obj objectValue];

    return nil;
}

- (id)valueForKeyPathFor:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
		return "__CUKE_ERROR__";

    try
    {
       return [obj valueForKeyPath:params[1]];
    }
    catch (e)
    {
        return "__CUKE_ERROR__";
    }
}

- (CPString)selectFrom:(CPArray)params
{
    var obj = cucumber_objects[params[1]];

    if (!obj)
        return "OBJECT NOT FOUND";

    var columns = [obj tableColumns];

    if ([[obj dataSource] respondsToSelector:@selector(tableView:objectValueForTableColumn:row:)])
    {
        for (var i = 0; i < [columns count]; i++)
        {
            var column = columns[i];

            for (var j = 0; j < [obj numberOfRows]; j++)
            {
                var data = [[obj dataSource] tableView:obj objectValueForTableColumn:column row:j];

                if (@"" + data === params[0])
                {
                    [obj selectRowIndexes:[CPIndexSet indexSetWithIndex:j] byExtendingSelection:NO];

                    if (data == [[obj dataSource] tableView:obj objectValueForTableColumn:column row:[obj selectedRow]])
                        return "OK";
                    else
                        return "DATA NOT FOUND";
                }
            }
        }
    }

    if ([[obj dataSource] respondsToSelector:@selector(outlineView:numberOfChildrenOfItem:)])
    {
        if ([self searchForObjectValue:params[0] inItemsInOutlineView:obj forItem:nil])
            return "OK";
    }

    return "DATA NOT FOUND";
}

- (BOOL)searchForObjectValue:(id)value inItemsInOutlineView:(CPOutlineView)obj forItem:(id)item
{
    var columns = [obj tableColumns];

    for (var k = 0; k < [columns count]; k++)
    {
        for (var i = 0; i < [[obj dataSource] outlineView:obj numberOfChildrenOfItem:item]; i++)
        {
            var child = [[obj dataSource] outlineView:obj child:i ofItem:item],
                testValue = [[obj dataSource] outlineView:obj objectValueForTableColumn:columns[k] byItem:child];

            if (@"" + testValue === value)
                return YES;

            if ([self searchForObjectValue:value inItemsInOutlineView:obj forItem:child])
            {
                for (var j = 0; j < [[obj dataSource] outlineView:obj numberOfChildrenOfItem:child]; j++)
                {
                    var subChild = [[obj dataSource] outlineView:obj child:j ofItem:child];

                    if (@"" + subChild === value)
                    {
                        var index = [obj rowForItem:subChild];
                        [obj selectRowIndexes:[CPIndexSet indexSetWithIndex:index] byExtendingSelection:NO];

                        if (subChild == [[obj dataSource] outlineView:obj child:index ofItem:child])
                            return YES;
                    }
                }
            }
        }
    }

    return NO;
}

- (CPString)selectMenu:(CPArray)params
{
    var obj = [CPApp mainMenu];

    if (!obj)
        return "MENU NOT FOUND";

    var item = [obj itemWithTitle:params[0]];

    if (item)
        return "OK";

    return "MENU ITEM NOT FOUND";
}

- (CPString)findIn:(CPArray)params
{
    return [self selectFrom:params];
}

- (CPString)textFor:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return "__CUKE_ERROR__";

    if ([obj respondsToSelector:@selector(stringValue)])
        return [obj stringValue];

    return "__CUKE_ERROR__";
}

- (CPString)doubleClick:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return "OBJECT NOT FOUND";

    if ([obj respondsToSelector:@selector(doubleAction)] && [obj doubleAction] !== null)
    {
        [[obj target] performSelector:[obj doubleAction] withObject:self];

        return "OK";
    }

    return "NO DOUBLE ACTION";
}

- (CPString)setText:(CPArray)params
{
    var obj = cucumber_objects[params[1]];

    if (!obj)
        return "OBJECT NOT FOUND";

    if ([obj respondsToSelector:@selector(setStringValue:)])
    {
        [obj setStringValue:params[0]];
        [self propagateValue:[obj stringValue] forBinding:"value" forObject:obj];
        return "OK";
    }

    return "CANNOT SET TEXT ON OBJECT";
}

- (void)propagateValue:(id)value forBinding:(CPString)binding forObject:(id)aObject
{
    //WARNING: bindingInfo contains CPNull, so it must be accounted for
    var bindingInfo = [aObject infoForBinding:binding];

    if (!bindingInfo)
        return; //there is no binding

    //apply the value transformer, if one has been set
    var bindingOptions = [bindingInfo objectForKey:CPOptionsKey];

    if (bindingOptions)
    {
        var transformer = [bindingOptions valueForKey:CPValueTransformerBindingOption];

        if (!transformer || transformer == [CPNull null])
        {
            var transformerName = [bindingOptions valueForKey:CPValueTransformerNameBindingOption];

            if (transformerName && transformerName != [CPNull null])
                transformer = [CPValueTransformer valueTransformerForName:transformerName];
        }

        if (transformer && transformer != [CPNull null])
        {
            if ([[transformer class] allowsReverseTransformation])
                value = [transformer reverseTransformedValue:value];
            else
                CPLog(@"WARNING: binding \"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
        }
    }

    var boundObject = [bindingInfo objectForKey:CPObservedObjectKey];

    if (!boundObject || boundObject == [CPNull null])
    {
        CPLog(@"ERROR: CPObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }

    var boundKeyPath = [bindingInfo objectForKey:CPObservedKeyPathKey];

    if (!boundKeyPath || boundKeyPath == [CPNull null])
    {
        CPLog(@"ERROR: CPObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }

    [boundObject setValue:value forKeyPath:boundKeyPath];
}

- (void)applicationDidFinishLaunching:(CPNotification)note
{
    launched = YES;
}

@end

[Cucumber startCucumber];
