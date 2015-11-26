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
@import <AppKit/CPTextField.j>

@import "Cappuccino+Cucumber.j"

@global CPApp
@global __PRETTY_FUNCTION__

cucumber_instance = nil;
cucumber_objects = nil;
cucumber_counter = 0;
exception_message = nil;

function _addition_cpapplication_send_event_method()
{
    var aFunction = class_getMethodImplementation([CPApplication class], @selector(sendEvent:));

    class_replaceMethod([CPApplication class], @selector(sendEvent:),

        function(object, _cmd)
        {
            if (object === CPApp)
            {
                var event = arguments[2],
                    window = [event window];

                if ([event type] == CPLeftMouseDown && window)
                {
                    var view = [window._windowView hitTest:[event locationInWindow]];

                    CPLog.debug("A left click has been catched on the views (ascending order):");

                    while(view)
                    {
                        _print_informations_of_view(view);
                        view = [view superview];
                    }
                }
            }

        return aFunction.apply(this, arguments);
        });
}

function _print_informations_of_view(aView)
{
    var keys = ["cucappIdentifier", "title", "identifier", "text", "placeholderString", "label", "tag", "objectValue"]

    for (var i = 0; i < [keys count]; i++)
    {
        var key = keys[i],
            selector = CPSelectorFromString(key);

        if (![aView respondsToSelector:selector] || ![aView performSelector:selector] || (key === "tag" && [aView performSelector:selector] == -1))
            continue;

        CPLog.debug("The " + key + " of the targeted view (class : " + [aView class] + ") is : " + [aView performSelector:selector]);
        console.error(aView);
        return;
    }
}

function simulate_keyboard_event(character, flags)
{
    if (!flags)
        flags = [];

    [cucumber_instance simulateKeyboardEvent:[character, flags]];
}

function simulate_keyboard_events(string, flags)
{
    if (!flags)
        flags = [];

    for (var i = 0; i < string.length; i++)
    {
        [cucumber_instance simulateKeyboardEvent:[string[i], flags]];
    }
}

function simulate_left_click_on_view(aKey, aValue, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue);

    if (!flags)
        flags = [];

    [cucumber_instance simulateLeftClick:[objectID, flags]];
}

function simulate_right_click_on_view(aKey, aValue, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue);

    if (!flags)
        flags = [];

    [cucumber_instance simulateRightClick:[objectID, flags]];
}

function simulate_double_click_on_view(aKey, aValue, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue);

    if (!flags)
        flags = [];

    [cucumber_instance simulateDoubleClick:[objectID, flags]];
}

function simulate_left_click_on_point(x, y, flags)
{
    if (!flags)
        flags = [];

    [cucumber_instance simulateLeftClickOnPoint:[x, y, flags]];
}

function simulate_right_click_on_point(x, y, flags)
{
    if (!flags)
        flags = [];

    [cucumber_instance simulateRightClick:[x, y, flags]];
}

function simulate_double_click_on_point(x, y, flags)
{
    if (!flags)
        flags = [];

    [cucumber_instance simulateDoubleClick:[x, y, flags]];
}

function simulate_mouse_moved_on_point(x, y, flags)
{
    if (!flags)
        flags = [];

    [cucumber_instance simulateMouseMovedOnPoint:[x, y, flags]];
}

function simulate_mouse_moved_on_view(aKey, aValue, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue);

    if (!flags)
        flags = [];

    [cucumber_instance simulateMouseMoved:[objectID, flags]];
}

function simulate_scroll_wheel_on_view(aKey, aValue, deltaX, deltaY, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue);

    if (!flags)
        flags = [];

    [cucumber_instance simulateMouseMovedOnPoint:[aKey, aValue, deltaX, deltaY, flags]];
}

function simulate_mouse_up_on_point(x, y, flags)
{
    if (!flags)
        flags = [];

    [cucumber_instance simulateMouseUpOnPoint:[x, y, flags]];
}

function simulate_mouse_down_on_point(x, y, flags)
{
    if (!flags)
        flags = [];

    [cucumber_instance simulateMouseDownOnPoint:[x, y, flags]];
}

function simulate_mouse_up_on_view(aKey, aValue, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue);

    if (!flags)
        flags = [];

    [cucumber_instance simulateMouseUp:[objectID, flags]];
}

function simulate_mouse_down_on_view(aKey, aValue, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue);

    if (!flags)
        flags = [];

    [cucumber_instance simulateMouseDown:[objectID, flags]];
}

function find_control(aKey, aValue)
{
    CPLog.warn(@"Begin to look for the value " + aValue + " of the key " + aKey);

    // In a try catch to use the function _getObjectsWithKeyAndValue which can raises an exception
    try
    {
        var selector = CPSelectorFromString(aKey);

        _getObjectsWithKeyAndValue(aKey, aValue)

        for (var i = [cucumber_objects count] - 1; i >= 0; i--)
        {
            var cucumber_object = cucumber_objects[i];

            if ([cucumber_object respondsToSelector:selector] && [cucumber_object performSelector:selector] == aValue)
                console.log(cucumber_object);
        }
    }
    catch(e){}

    CPLog.warn(@"End of look the value " + aValue + " of the key " + aKey);
}

function _getObjectsWithKeyAndValue(aKey, aValue)
{
    if (!aKey || !aValue)
        [CPException raise:CPInvalidArgumentException reason:@"The given key or value is null"];

    cucumber_objects = [];
    cucumber_counter = 0;

    var windows = [CPApp windows],
        menu = [CPApp mainMenu],
        selector = CPSelectorFromString(aKey);

    for (var i = 0; i < windows.length; i++)
        dumpGuiObject(windows[i]);

    if (menu)
        dumpGuiObject(menu);

    for (var i = [cucumber_objects count]; i >= 0; i--)
    {
        var cucumber_object = cucumber_objects[i];

        if ([cucumber_object respondsToSelector:selector] && [cucumber_object performSelector:selector] == aValue)
            return i;
    }

    [CPException raise:CPInvalidArgumentException reason:@"No result for the key " + aKey + " and the value " + aValue];;
}

function addCucumberObject(obj)
{
    cucumber_counter++;
    cucumber_objects[cucumber_counter] = obj;

    return cucumber_counter;
}

function dumpGuiObject(obj)
{
    if (!obj ||
        ([obj respondsToSelector:@selector(isHidden)] && [obj isHidden]) ||
        ([obj respondsToSelector:@selector(isVisible)] && ![obj isVisible]) ||
        ([obj respondsToSelector:@selector(visibleRect)] && CGRectEqualToRect([obj visibleRect], CGRectMakeZero())))
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

        if (frame && [obj respondsToSelector:@selector(superview)])
        {
            var globalPoint = [obj superview] ? [[obj superview] convertPointToBase:frame.origin] : frame.origin;

            globalPoint.x += [[obj window] frame].origin.x;
            globalPoint.y += [[obj window] frame].origin.y;

            resultingXML += "<absoluteFrame>";
            resultingXML += "<x>" + globalPoint.x + "</x>";
            resultingXML += "<y>" + globalPoint.y + "</y>";
            resultingXML += "<width>" + frame.size.width + "</width>";
            resultingXML += "<height>" + frame.size.height + "</height>";
            resultingXML += "</absoluteFrame>";
        }
    }

    if ([obj respondsToSelector:@selector(backgroundColor)])
        resultingXML += "<backgroundColor>" + [[obj backgroundColor] hexString] + "</backgroundColor>";

    if ([obj respondsToSelector:@selector(textColor)])
        resultingXML += "<textColor>" + [[obj textColor] hexString] + "</textColor>";

    if ([obj respondsToSelector:@selector(borderColor)])
        resultingXML += "<borderColor>" + [[obj borderColor] hexString] + "</borderColor>";

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
    BOOL stopRequest;
}

+ (void)startCucumber
{
    if (cucumber_instance == nil)
    {
        [[Cucumber alloc] init];
        [cucumber_instance startRequest];
    }
}

+ (void)stopCucumber
{
    [cucumber_instance stopRequest];
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
        stopRequest = NO;

        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:CPApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }

    return self;
}

- (void)stopRequest
{
    requesting = NO;
    stopRequest = YES;
}

- (void)startRequest
{
    requesting = YES;
    stopRequest = NO;

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
    if (exception_message)
    {
        var error = exception_message;
        [self startResponse:nil withError:error];
        return;
    }

    if (stopRequest)
        return;

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
        {
            var platformWindows = [CPPlatformWindow visiblePlatformWindows],
                primaryPlatformWindow = [CPPlatformWindow primaryPlatformWindow],
                platformWindowEnumerator = [platformWindows objectEnumerator],
                platformWindow = nil;

            while ((platformWindow = [platformWindowEnumerator nextObject]) !== nil)
            {
                if (platformWindow != primaryPlatformWindow)
                    [platformWindow orderOut:self];
            }
        }
        else
        {
            [self startRequest];
        }
    }
}

- (void)connectionDidFinishLoading:(CPURLConnection)connection
{
}


#pragma mark -
#pragma mark Cucapp methods

- (CPString)restoreDefaults:(CPDictionary)params
{
    if ([[CPApp delegate] respondsToSelector: @selector(restoreDefaults:)])
        [[CPApp delegate] restoreDefaults: params];

    return '{"result" : "OK"}';
}

- (CPString)outputView:(CPArray)params
{
    cucumber_counter = 0;
    cucumber_objects = [];

    return [CPApp xmlDescription];
}

- (CPString)closeBrowser:(CPArray)params
{
    time_to_die = YES;

    return '{"result" : "OK"}';
}

- (CPString)launched:(CPArray)params
{
    if (launched || CPApp._finishedLaunching)
        return "YES";

    return "NO";
}


- (void)applicationDidFinishLaunching:(CPNotification)note
{
    launched = YES;
}


#pragma mark -
#pragma mark Utilties

- (id)objectValueFor:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return '{"result" : "__CUKE_ERROR__"}';

    if ([obj isKindOfClass:[CPPopUpButton class]])
        return '{"result" : "' + [obj titleOfSelectedItem] + '"}';

    if ([obj isKindOfClass:@selector(objectValue)])
        return '{"result" : "' + [obj objectValue] + '"}';

    return '{"result" : ""}';
}

- (CPString)textFor:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return '{"result" : "__CUKE_ERROR__"}';

    if ([obj isKindOfClass:[CPPopUpButton class]])
        return '{"result" : "' + [obj titleOfSelectedItem] + '"}';

    if ([obj respondsToSelector:@selector(stringValue)])
        return '{"result" : "' + [obj stringValue] + '"}';

    return '{"result" : "__CUKE_ERROR__"}';
}

- (id)valueForKeyPathFor:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return '{"result" : "__CUKE_ERROR__"}';

    try
    {
       return '{"result" : "' + [obj valueForKeyPath:params[1]] + '"}';
    }
    catch (e)
    {
        return '{"result" : "__CUKE_ERROR__"}';
    }
}

- (CPString)makeKeyAndOrderFrontWindow:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj || ![obj isKindOfClass:[CPWindow class]])
        return '{"result" : "__CUKE_ERROR__"}';

    [obj makeKeyAndOrderFront:self];

    return '{"result" : "OK"}';
}

- (CPString)closeWindow:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj || ![obj isKindOfClass:[CPWindow class]])
        return '{"result" : "__CUKE_ERROR__"}';

    [obj performClose:self];

    return '{"result" : "OK"}';
}


#pragma mark -
#pragma mark Events methods

- (id)_mainDOMDocument
{
    return [[CPApp mainWindow] platformWindow]._DOMWindow.document;
}

- (id)_mainDOMWindow
{
    return [[CPApp mainWindow] platformWindow]._DOMWindow;
}

- (void)dispatchEvent:(DOMEvent)anEvent
{
    [self _mainDOMDocument].dispatchEvent(anEvent);
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

- (int)_keyCodeForCharacter:(CPString)charac
{
    switch (charac)
    {
        case CPDeleteCharFunctionKey:
        case CPDeleteLineFunctionKey:
        case CPDeleteFunctionKey:
        case CPDeleteCharacter:
            return CPDeleteKeyCode;

        case CPTabCharacter:
            return CPTabKeyCode;

        case CPNewlineCharacter:
        case CPCarriageReturnCharacter:
        case CPEnterCharacter:
            return CPReturnKeyCode;

        case CPEscapeFunctionKey:
            return CPEscapeKeyCode;

        case CPSpaceFunctionKey:
            return CPSpaceKeyCode;

        case CPPageUpFunctionKey:
            return CPPageUpKeyCode;

        case CPPageDownFunctionKey:
            return CPPageDownKeyCode;

        case CPLeftArrowFunctionKey:
            return CPLeftArrowKeyCode;

        case CPUpArrowFunctionKey:
            return CPUpArrowKeyCode;

        case CPRightArrowFunctionKey:
            return CPRightArrowKeyCode;

        case CPDownArrowFunctionKey:
            return CPDownArrowKeyCode;

        default:
            return charac.charCodeAt(0);
    }
}

- (void)simulateKeyboardEvent:(CPArray)params
{
    var character = params.shift(),
        modifierFlags = 0,
        flags = params[0];

    for (var i = 0; i < [flags count]; i++)
    {
        var flag = flags[i];
        modifierFlags |= parseInt(flag);
    }

    CPLog.debug("Cucapp is about to simulate a keyboard event with the character " + character + " with the keyboard flags " + modifierFlags);

    // Seems weird right ?
    // Cappuccino handle the flagsChanged in keyDown and then prevent the keypress
    // With no flag everything is handle in keypress
    if (modifierFlags)
    {
        var event = window.crossBrowser_initKeyboardEvent("keydown", {keyCode : [self _keyCodeForCharacter:character], char : character, metaKey : modifierFlags & CPCommandKeyMask, shiftKey : modifierFlags & CPShiftKeyMask, altKey : modifierFlags & CPAlternateKeyMask, ctrlKey: modifierFlags & CPControlKeyMask});
        [self dispatchEvent:event];
    }

    event = window.crossBrowser_initKeyboardEvent("keypress", {keyCode : [self _keyCodeForCharacter:character], char : character, metaKey : modifierFlags & CPCommandKeyMask, shiftKey : modifierFlags & CPShiftKeyMask, altKey : modifierFlags & CPAlternateKeyMask, ctrlKey: modifierFlags & CPControlKeyMask});
    [self dispatchEvent:event];

    event = window.crossBrowser_initKeyboardEvent("keyup", {keyCode : [self _keyCodeForCharacter:character], char : character, metaKey : modifierFlags & CPCommandKeyMask, shiftKey : modifierFlags & CPShiftKeyMask, altKey : modifierFlags & CPAlternateKeyMask, ctrlKey: modifierFlags & CPControlKeyMask});
    [self dispatchEvent:event];
}

- (void)simulateLeftClickOnPoint:(CPArray)params
{
    var point = CGPointMake(params.shift(), params.shift()),
        window = [CPApp keyWindow];

    CPLog.debug("Cucapp is about to simulate a left click on the point : " + point);

    [self _perfomMouseEventOnPoint:point window:window eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];
}

- (CPString)simulateLeftClick:(CPArray)params
{
    var obj = cucumber_objects[params.shift()],
        locationWindowPoint;

    if (!obj)
        return '{"result" : "OBJECT NOT FOUND"}';

    if ([obj superview])
        locationWindowPoint = [[obj superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]))];
    else
        locationWindowPoint = CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]));

    CPLog.debug("Cucapp is about to simulate a left click on the view : " + obj);

    [self _perfomMouseEventOnPoint:locationWindowPoint window:[obj window] eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (void)simulateRightClickOnPoint:(CPArray)params
{
    var point = CGPointMake(params.shift(), params.shift()),
        window = [CPApp keyWindow];

    CPLog.debug("Cucapp is about to simulate a right click on the point : " + point);

    [self _perfomMouseEventOnPoint:point window:window eventType:CPRightMouseDown numberOfClick:1 modifierFlags:params[0]];
}

- (CPString)simulateRightClick:(CPArray)params
{
    var obj = cucumber_objects[params.shift()],
        locationWindowPoint;

    if (!obj)
        return '{"result" : "OBJECT NOT FOUND"}';

    if ([obj superview])
        locationWindowPoint = [[obj superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]))];
    else
        locationWindowPoint = CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]));

    CPLog.debug("Cucapp is about to simulate a right click on the view : " + obj);

    [self _perfomMouseEventOnPoint:locationWindowPoint window:[obj window] eventType:CPRightMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (void)simulateDoubleClickOnPoint:(CPArray)params
{
    var point = CGPointMake(params.shift(), params.shift()),
        window = [CPApp keyWindow];

    CPLog.debug("Cucapp is about to simulate a double click on the point : " + point);

    [self _perfomMouseEventOnPoint:point window:window eventType:CPLeftMouseDown numberOfClick:2 modifierFlags:params[0]];
}

- (CPString)simulateDoubleClick:(CPArray)params
{
    var obj = cucumber_objects[params.shift()],
        locationWindowPoint;

    if (!obj)
        return '{"result" : "OBJECT NOT FOUND"}';

    if ([obj superview])
        locationWindowPoint = [[obj superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]))];
    else
        locationWindowPoint = CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]));

    CPLog.debug("Cucapp is about to simulate a double click on the view : " + obj);

    [self _perfomMouseEventOnPoint:locationWindowPoint window:[obj window] eventType:CPLeftMouseDown numberOfClick:2 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (CPString)simulateScrollWheelOnPoint:(CPArray)params
{
    var locationWindowPoint = CGPointMake(params.shift(), params.shift()),
        deltaX = params.shift(),
        deltaY = params.shift(),
        flags = params.shift(),
        modifierFlags = 0,
        window = [CPApp keyWindow];

    for (var i = 0; i < [flags count]; i++)
    {
        var flag = flags[i];
        modifierFlags |= parseInt(flag);
    }

    CPLog.debug("Cucapp is about to simulate a scroll wheel on the point (" + locationWindowPoint.x + "," + locationWindowPoint.y + ") with the deltas : " + deltaX + "," + deltaY + " and modifiers flags " + modifierFlags);

    var event = new MouseEvent("DOMMouseScroll", {relatedTarget:[self _mainDOMDocument], clientX : locationWindowPoint.x, clientY : locationWindowPoint.y, ctrlKey : modifierFlags & CPControlKeyMask, altKey : modifierFlags & CPAlternateKeyMask, metaKey : modifierFlags & CPCommandKeyMask, shiftKey : modifierFlags & CPShiftKeyMask});
    event["deltaX"] = deltaX;
    event["deltaY"] = deltaY;

    [self _mainDOMWindow].dispatchEvent(event);
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];

    return '{"result" : "OK"}';
}

- (CPString)simulateScrollWheel:(CPArray)params
{
    var obj = cucumber_objects[params.shift()],
        locationWindowPoint;

    if (!obj)
        return '{"result" : "OBJECT NOT FOUND"}';

    if ([obj superview])
        locationWindowPoint = [[obj superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]))];
    else
        locationWindowPoint = CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]));

    var deltaX = params.shift(),
        deltaY = params.shift(),
        flags = params.shift(),
        modifierFlags = 0;

    for (var i = 0; i < [flags count]; i++)
    {
        var flag = flags[i];
        modifierFlags |= parseInt(flag);
    }

    CPLog.debug("Cucapp is about to simulate a scroll wheel on the view : " + obj + " with the deltas : " + deltaX + "," + deltaY + " and modifiers flags " + modifierFlags);

    var event = new MouseEvent("DOMMouseScroll", {relatedTarget:[self _mainDOMDocument], clientX : locationWindowPoint.x, clientY : locationWindowPoint.y, ctrlKey : modifierFlags & CPControlKeyMask, altKey : modifierFlags & CPAlternateKeyMask, metaKey : modifierFlags & CPCommandKeyMask, shiftKey : modifierFlags & CPShiftKeyMask});
    event["deltaX"] = deltaX;
    event["deltaY"] = deltaY;

    [self _mainDOMWindow].dispatchEvent(event);
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];

    return '{"result" : "OK"}';
}

- (void)simulateMouseDownOnPoint:(CPArray)params
{
    var locationWindowPoint = CGPointMake(params.shift(), params.shift()),
        flags = params[0],
        window = [CPApp keyWindow];

    CPLog.debug("Cucapp is about to simulate a mouse down to the point " + locationWindowPoint);

    [self _dispatchMouseEventWithType:CPLeftMouseDown location:locationWindowPoint modifierFlags:flags clickCount:0 window:window];

    return '{"result" : "OK"}';
}

- (void)simulateMouseDown:(CPArray)params
{
    var obj = cucumber_objects[params.shift()],
        locationWindowPoint,
        flags = params[0],
        window = [CPApp keyWindow];

    if (!obj)
        return '{"result" : "OBJECT NOT FOUND"}';

    if ([obj superview])
        locationWindowPoint = [[obj superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]))];
    else
        locationWindowPoint = CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]));

    CPLog.debug("Cucapp is about to simulate a mouse down on the view : " + obj);

    [self _dispatchMouseEventWithType:CPLeftMouseDown location:locationWindowPoint modifierFlags:flags clickCount:0 window:window];

    return '{"result" : "OK"}';
}

- (void)simulateMouseUpOnPoint:(CPArray)params
{
    var locationWindowPoint = CGPointMake(params.shift(), params.shift()),
        flags = params[0],
        window = [CPApp keyWindow];

    CPLog.debug("Cucapp is about to simulate a mouse up to the point " + locationWindowPoint);

    [self _dispatchMouseEventWithType:CPLeftMouseUp location:locationWindowPoint modifierFlags:flags clickCount:0 window:window];

    return '{"result" : "OK"}';
}

- (void)simulateMouseUp:(CPArray)params
{
    var obj = cucumber_objects[params.shift()],
        locationWindowPoint,
        flags = params[0],
        window = [CPApp keyWindow];

    if (!obj)
        return '{"result" : "OBJECT NOT FOUND"}';

    if ([obj superview])
        locationWindowPoint = [[obj superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]))];
    else
        locationWindowPoint = CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]));

    CPLog.debug("Cucapp is about to simulate a mouse down on the view : " + obj);

    [self _dispatchMouseEventWithType:CPLeftMouseUp location:locationWindowPoint modifierFlags:flags clickCount:0 window:window];

    return '{"result" : "OK"}';
}

- (void)simulateMouseMovedOnPoint:(CPArray)params
{
    var locationWindowPoint = CGPointMake(params.shift(), params.shift()),
        flags = params[0],
        window = [CPApp keyWindow];

    CPLog.debug("Cucapp is about to simulate a mouse moved to the point " + locationWindowPoint);

    [self _dispatchMouseEventWithType:CPMouseMoved location:locationWindowPoint modifierFlags:flags clickCount:0 window:window];

    return '{"result" : "OK"}';
}

- (void)simulateMouseMoved:(CPArray)params
{
    var obj = cucumber_objects[params.shift()],
        locationWindowPoint,
        flags = params[0],
        window = [CPApp keyWindow];

    if (!obj)
        return '{"result" : "OBJECT NOT FOUND"}';

    if ([obj superview])
        locationWindowPoint = [[obj superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]))];
    else
        locationWindowPoint = CGPointMake(CGRectGetMidX([obj frame]), CGRectGetMidY([obj frame]));

    CPLog.debug("Cucapp is about to simulate a mouse moved on the view : " + obj);

    [self _dispatchMouseEventWithType:CPMouseMoved location:locationWindowPoint modifierFlags:flags clickCount:0 window:window];

    return '{"result" : "OK"}';
}

- (void)_perfomMouseEventOnPoint:(CGPoint)locationWindowPoint window:(CPWindow)currentWindow eventType:(unsigned)anEventType numberOfClick:(int)numberOfClick modifierFlags:(CPArray)flags
{
    var typeMouseDown = CPLeftMouseDown,
        typeMouseUp = CPLeftMouseUp;

    locationWindowPoint.x = Math.round(locationWindowPoint.x);
    locationWindowPoint.y = Math.round(locationWindowPoint.y);

    var currentLocation = CGPointMakeCopy(locationWindowPoint);

    if (anEventType == CPRightMouseDown)
    {
        typeMouseDown = CPRightMouseDown;
        typeMouseUp = CPRightMouseUp;
    }

    for (var i = 1; i < numberOfClick + 1; i++)
    {
        [self _dispatchMouseEventWithType:typeMouseDown location:currentLocation modifierFlags:flags clickCount:i window:currentWindow];
        [self _dispatchMouseEventWithType:typeMouseUp location:currentLocation modifierFlags:flags clickCount:i window:currentWindow];
    }
}

- (void)_dispatchMouseEventWithType:(int)aType location:(CGPoint)currentLocation modifierFlags:(CPArray)flags clickCount:(int)clickCount window:(CPWindow)aWindow
{
    var type = "",
        button = 0,
        modifierFlags = 0,
        location = [aWindow convertBaseToPlatformWindow:currentLocation];

    for (var i = 0; i < [flags count]; i++)
    {
        var flag = flags[i];
        modifierFlags |= parseInt(flag);
    }

    switch (aType)
    {
        case CPLeftMouseDown:
            type = "mousedown";
            button = 0;
            break;

        case CPLeftMouseUp:
            type = "mouseup";
            button = 0;
            break;

        case CPRightMouseDown:
            type = "mousedown";
            button = 2;
            break;

        case CPRightMouseUp:
            type = "mouseup";
            button = 2;
            break;

        case CPMouseMoved:
            type = "mousemove";
            button = -1;
            break;

    }

    var event = new MouseEvent(type, {relatedTarget:[self _mainDOMDocument], button: button, clientX : location.x, clientY : location.y, ctrlKey : modifierFlags & CPControlKeyMask, altKey : modifierFlags & CPAlternateKeyMask, metaKey : modifierFlags & CPCommandKeyMask, shiftKey : modifierFlags & CPShiftKeyMask});
    [self dispatchEvent:event];
}

@end


@implementation CPTextField (CucumberTextField)

- (void)insertText:(CPString)aString
{
    if (!([self isEnabled] && [self isEditable]))
        return;

    var selectedRange = [self selectedRange],
        newValue = [self _inputElement].value  + aString;

    if (selectedRange.length)
        newValue = [[self _inputElement].value stringByReplacingCharactersInRange:selectedRange withString:aString];

    if (newValue !== _stringValue)
    {
        [self setStringValue:newValue];
        [self _didEdit];
    }

    [[[self window] platformWindow] _propagateCurrentDOMEvent:NO];

    [self setNeedsLayout];
    [self setNeedsDisplay:YES];
}

- (void)_didEdit
{
    [self _inputElement].value = [self stringValue];

    if (!_isEditing)
    {
        _isEditing = YES;
        [self textDidBeginEditing:[CPNotification notificationWithName:CPControlTextDidBeginEditingNotification object:self userInfo:nil]];
    }

    [self textDidChange:[CPNotification notificationWithName:CPControlTextDidChangeNotification object:self userInfo:nil]];
}

@end


var original_objj_msgSend = objj_msgSend,
    original_objj_msgSendFast = objj_msgSendFast,
    original_objj_msgSendFast0 = objj_msgSendFast0,
    original_objj_msgSendFast1 = objj_msgSendFast1,
    original_objj_msgSendFast2 = objj_msgSendFast2,
    original_objj_msgSendFast3 = objj_msgSendFast3;

var catcher_objj_msgSend = function()
{
    try
    {
        objj_msgSend = original_objj_msgSend;
        return objj_msgSend.apply(this, arguments);
    }
    catch (anException)
    {
        exception_message = anException.message;
        return;
    }
    finally
    {
        objj_msgSend = catcher_objj_msgSend;
    }
};

var catcher_objj_msgSendFast = function()
{
    try
    {
        objj_msgSendFast = original_objj_msgSendFast;
        return objj_msgSendFast.apply(this, arguments);
    }
    catch (anException)
    {
        exception_message = anException.message;
        return;
    }
    finally
    {
        objj_msgSendFast = catcher_objj_msgSendFast;
    }
};

var catcher_objj_msgSendFast0 = function()
{
    try
    {
        objj_msgSendFast0 = original_objj_msgSendFast0;
        return objj_msgSendFast0.apply(this, arguments);
    }
    catch (anException)
    {
        exception_message = anException.message;
        return;
    }
    finally
    {
        objj_msgSendFast0 = catcher_objj_msgSendFast0;
    }
};


var catcher_objj_msgSendFast1 = function()
{
    try
    {
        objj_msgSendFast1 = original_objj_msgSendFast1;
        return objj_msgSendFast1.apply(this, arguments);
    }
    catch (anException)
    {
        exception_message = anException.message;
        return;
    }
    finally
    {
        objj_msgSendFast1 = catcher_objj_msgSendFast1;
    }
};

var catcher_objj_msgSendFast2 = function()
{
    try
    {
        objj_msgSendFast2 = original_objj_msgSendFast2;
        return objj_msgSendFast2.apply(this, arguments);
    }
    catch (anException)
    {
        exception_message = anException.message;
        return;
    }
    finally
    {
        objj_msgSendFast2 = catcher_objj_msgSendFast2;
    }
};


var catcher_objj_msgSendFast3 = function()
{
    try
    {
        objj_msgSendFast3 = original_objj_msgSendFast3;
        return objj_msgSendFast3.apply(this, arguments);
    }
    catch (anException)
    {
        exception_message = anException.message;
        return;
    }
    finally
    {
        objj_msgSendFast3 = catcher_objj_msgSendFast3;
    }
};


var install_msgSend_catcher = function()
{
    objj_msgSend = catcher_objj_msgSend;
    objj_msgSendFast = catcher_objj_msgSendFast;
    objj_msgSendFast0 = catcher_objj_msgSendFast0;
    objj_msgSendFast1 = catcher_objj_msgSendFast1;
    objj_msgSendFast2 = catcher_objj_msgSendFast2;
    objj_msgSendFast3 = catcher_objj_msgSendFast3;
};

install_msgSend_catcher();
[Cucumber startCucumber];


// Found on this gist : https://gist.github.com/termi/4654819 (no licence)
// Used to simulate key event
// Modified for readeability...
void function()
{
    var global = this,
        _initKeyboardEvent_type = (function(e)
    {
		try
        {
			e.initKeyboardEvent("keyup", false, false, global, "+", 3, true, false, true, false, false);
            return ((e["keyIdentifier"] || e["key"]) == "+" && (e["keyLocation"] || e["location"]) == 3) && (e.ctrlKey ? e.altKey ? 1 : 3 : e.shiftKey ? 2  : 4 ) || 9;
		}
		catch (__e__)
        {
            _initKeyboardEvent_type = 0;
        }

	})(document.createEvent("KeyboardEvent")),
        _keyboardEvent_properties_dictionary = {
		    "char": "",
		    "key": "",
		    "location": 0,
		    "ctrlKey": false,
		    "shiftKey": false,
		    "altKey": false,
		    "metaKey": false,
		    "repeat": false,
		    "locale": "",
		    "detail": 0,
		    "bubbles": false,
		    "cancelable": false,
		    "keyCode": 0,
		    "charCode": 0,
		    "which": 0
	    },

	    own = Function.prototype.call.bind(Object.prototype.hasOwnProperty),
        _Object_defineProperty = Object.defineProperty || function(obj, prop, val)
        {
		    if ("value" in val)
			    obj[prop] = val["value"];
	    };

    function crossBrowser_initKeyboardEvent(type, dict)
    {
    	var e,
            _prop_name,
            localDict = {};

    	if (_initKeyboardEvent_type)
    		e = document.createEvent( "KeyboardEvent" );
    	else
    		e = document.createEvent( "Event" );

    	for (_prop_name in _keyboardEvent_properties_dictionary)
        {
            if (own(_keyboardEvent_properties_dictionary, _prop_name))
                localDict[_prop_name] = (own(dict, _prop_name) && dict || _keyboardEvent_properties_dictionary)[_prop_name];
        }

    	var _ctrlKey = localDict["ctrlKey"],
    		_shiftKey = localDict["shiftKey"],
    		_altKey = localDict["altKey"],
    		_metaKey = localDict["metaKey"],
    		_altGraphKey = localDict["altGraphKey"],
            _modifiersListArg = _initKeyboardEvent_type > 3 ? (
    			(_ctrlKey ? "Control" : "")
    				+ (_shiftKey ? " Shift" : "")
    				+ (_altKey ? " Alt" : "")
    				+ (_metaKey ? " Meta" : "")
    				+ (_altGraphKey ? " AltGraph" : "")
    			).trim() : null,
    		_key = localDict["key"] + "",
    		_char = localDict["char"] + "",
    		_location = localDict["location"],
    		_keyCode = localDict["keyCode"] || (localDict["keyCode"] = _key && _key.charCodeAt( 0 ) || 0),
    		_charCode = localDict["charCode"] || (localDict["charCode"] = _char && _char.charCodeAt( 0 ) || 0),
    		_bubbles = localDict["bubbles"],
    		_cancelable = localDict["cancelable"],
    		_repeat = localDict["repeat"],
    		_locale = localDict["locale"],
            _view = global;

    	localDict["which"] || (localDict["which"] = localDict["keyCode"]);

    	if ("initKeyEvent" in e)
        {
            // FF
            //https://developer.mozilla.org/en/DOM/event.initKeyEvent
    		e.initKeyEvent( type, _bubbles, _cancelable, _view, _ctrlKey, _altKey, _shiftKey, _metaKey, _keyCode, _charCode );
    	}
    	else if (_initKeyboardEvent_type && "initKeyboardEvent" in e)
        {
            //https://developer.mozilla.org/en/DOM/KeyboardEvent#initKeyboardEvent()
    		if (_initKeyboardEvent_type == 1)
            {
                // webkit
    			//http://stackoverflow.com/a/8490774/1437207
    			//https://bugs.webkit.org/show_bug.cgi?id=13368
    			e.initKeyboardEvent(type, _bubbles, _cancelable, _view, _key, _location, _ctrlKey, _shiftKey, _altKey, _metaKey, _altGraphKey );
    		}
    		else if (_initKeyboardEvent_type == 2)
            {
                // old webkit
    			//http://code.google.com/p/chromium/issues/detail?id=52408
    			e.initKeyboardEvent(type, _bubbles, _cancelable, _view, _ctrlKey, _altKey, _shiftKey, _metaKey, _keyCode, _charCode );
    		}
    		else if(_initKeyboardEvent_type == 3)
            {
                // webkit
    			e.initKeyboardEvent(type, _bubbles, _cancelable, _view, _key, _location, _ctrlKey, _altKey, _shiftKey, _metaKey, _altGraphKey );
    		}
    		else if(_initKeyboardEvent_type == 4)
            {
                // IE9
    			//http://msdn.microsoft.com/en-us/library/ie/ff975297(v=vs.85).aspx
    			e.initKeyboardEvent(type, _bubbles, _cancelable, _view, _key, _location, _modifiersListArg, _repeat, _locale );
    		}
    		else
            {
                // FireFox|w3c
    			//http://www.w3.org/TR/DOM-Level-3-Events/#events-KeyboardEvent-initKeyboardEvent
    			//https://developer.mozilla.org/en/DOM/KeyboardEvent#initKeyboardEvent()
    			e.initKeyboardEvent(type, _bubbles, _cancelable, _view, _char, _key, _location, _modifiersListArg, _repeat, _locale );
    		}
    	}
    	else
        {
    		e.initEvent(type, _bubbles, _cancelable)
    	}

    	for (_prop_name in _keyboardEvent_properties_dictionary)
        {
            if (own( _keyboardEvent_properties_dictionary, _prop_name ))
            {
        		if (e[_prop_name] != localDict[_prop_name])
                {
        			try
                    {
        				delete e[_prop_name];
        				_Object_defineProperty(e, _prop_name, { writable: true, "value": localDict[_prop_name] });
        			}
        			catch(e)
                    {
        				//Some properties is read-only
        			}
        		}
        	}
        }

    	return e;
    }

global.crossBrowser_initKeyboardEvent = crossBrowser_initKeyboardEvent;

}.call(this);
