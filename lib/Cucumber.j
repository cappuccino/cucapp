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

        CPLog.debug("The " + key + " of the targeted view is : " + [aView performSelector:selector]);
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

function simulate_dragged_click_view_to_view(aKey, aValue, aKey2, aValue2, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue),
        objectID2 = _getObjectsWithKeyAndValue(aKey2, aValue2);

    if (!flags)
        flags = [];

    [cucumber_instance simulateDraggedClickViewToView:[objectID, objectID2, flags]];
}

function simulate_dragged_click_view_to_point(aKey, aValue, x, y, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue);

    if (!flags)
        flags = [];

    [cucumber_instance simulateDraggedClickViewToView:[objectID, x, y, flags]];
}

function simulate_dragged_click_point_to_point(x, y, x1, y2, flags)
{
    if (!flags)
        flags = [];

    [cucumber_instance simulateDraggedClickViewToView:[x, y, x2, y2, flags]];
}

function simulate_mouse_moved_on_point(x, y, flags)
{
    if (!flags)
        flags = [];

    [cucumber_instance simulateMouseMovedOnPoint:[x, y, flags]];
}

function simulate_scroll_wheel_on_view(aKey, aValue, deltaX, deltaY, flags)
{
    var objectID = _getObjectsWithKeyAndValue(aKey, aValue);

    if (!flags)
        flags = [];

    [cucumber_instance simulateMouseMovedOnPoint:[aKey, aValue, deltaX, deltaY, flags]];
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
            window.close();
        else
            [self startRequest];
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

- (CPString)closeWindow:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return '{"result" : "NOT FOUND"}';

    [obj performClose: self];
    return '{"result" : "OK"}';
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


#pragma mark -
#pragma mark Events methods

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
        charactersIgnoringModifiers = character.toLowerCase(),
        modifierFlags = 0,
        currentWindow = [CPApp keyWindow],
        flags = params[0];

    for (var i = 0; i < [flags count]; i++)
    {
        var flag = flags[i];
        modifierFlags |= parseInt(flag);
    }

    CPLog.debug("Cucapp is about to simulate a keyboard event with the character " + charactersIgnoringModifiers + " with the keyboard flags " + modifierFlags);

    var keyDownEvent = [CPEvent keyEventWithType:CPKeyDown location:CGPointMakeZero() modifierFlags:modifierFlags
        timestamp:[CPEvent currentTimestamp] windowNumber:[currentWindow windowNumber] context:nil characters:character charactersIgnoringModifiers:charactersIgnoringModifiers isARepeat:NO keyCode:[self _keyCodeForCharacter:character]];
    [CPApp sendEvent:keyDownEvent];

    var keyUpEvent = [CPEvent keyEventWithType:CPKeyUp location:CGPointMakeZero() modifierFlags:modifierFlags
        timestamp:[CPEvent currentTimestamp] windowNumber:[currentWindow windowNumber] context:nil characters:character charactersIgnoringModifiers:charactersIgnoringModifiers isARepeat:NO keyCode:[self _keyCodeForCharacter:character]];
    [CPApp sendEvent:keyUpEvent];

    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

- (CPString)simulateDraggedClickViewToView:(CPArray)params
{
    var obj1 = cucumber_objects[params.shift()],
        obj2 = cucumber_objects[params.shift()],
        locationWindowPoint,
        locationWindowPoint2;

    if (!obj1 || !obj2)
        return '{"result" : "OBJECT NOT FOUND"}';

    if ([obj1 superview])
        locationWindowPoint = [[obj1 superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj1 frame]), CGRectGetMidY([obj1 frame]))];
    else
        locationWindowPoint = CGPointMake(CGRectGetMidX([obj1 frame]), CGRectGetMidY([obj1 frame]));

    if ([obj2 superview])
        locationWindowPoint2 = [[obj2 superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj2 frame]), CGRectGetMidY([obj2 frame]))];
    else
        locationWindowPoint2 = CGPointMake(CGRectGetMidX([obj2 frame]), CGRectGetMidY([obj2 frame]));

    CPLog.debug("Cucapp is about to simulate dragging events from the view " + obj1 + " to the view " + obj2);

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:locationWindowPoint2 window:[obj1 window] eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (CPString)simulateDraggedClickViewToPoint:(CPArray)params
{
    var obj1 = cucumber_objects[params.shift()],
        locationWindowPoint,
        locationWindowPoint2 = CGPointMake(params.shift(), params.shift());

    if (!obj1 || !locationWindowPoint2)
        return '{"result" : "OBJECT NOT FOUND"}';

    if ([obj1 superview])
        locationWindowPoint = [[obj1 superview] convertPointToBase:CGPointMake(CGRectGetMidX([obj1 frame]), CGRectGetMidY([obj1 frame]))];
    else
        locationWindowPoint = CGPointMake(CGRectGetMidX([obj1 frame]), CGRectGetMidY([obj1 frame]));

    CPLog.debug("Cucapp is about to simulate dragging events from the view " + obj1 + " to the point " + locationWindowPoint2);

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:locationWindowPoint2 window:[obj1 window] eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (CPString)simulateDraggedClickPointToPoint:(CPArray)params
{
    var locationWindowPoint = CGPointMake(params.shift(), params.shift()),
        locationWindowPoint2 = CGPointMake(params.shift(), params.shift());

    if (!locationWindowPoint || !locationWindowPoint2)
        return '{"result" : "OBJECT NOT FOUND"}';

    CPLog.debug("Cucapp is about to simulate dragging events from the point " + locationWindowPoint + " to the point " + locationWindowPoint2);

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:locationWindowPoint2 window:[CPApp mainWindow] eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (void)simulateLeftClickOnPoint:(CPArray)params
{
    var point = CGPointMake(params.shift(), params.shift()),
        window = [CPApp keyWindow];

    CPLog.debug("Cucapp is about to simulate a left click on the point : " + point);

    [self _perfomMouseEventOnPoint:point toPoint:nil window:window eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];
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

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:nil window:[obj window] eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (void)simulateRightClickOnPoint:(CPArray)params
{
    var point = CGPointMake(params.shift(), params.shift()),
        window = [CPApp keyWindow];

    CPLog.debug("Cucapp is about to simulate a right click on the point : " + point);

    [self _perfomMouseEventOnPoint:point toPoint:nil window:window eventType:CPRightMouseDown numberOfClick:1 modifierFlags:params[0]];
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

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:nil window:[obj window] eventType:CPRightMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (void)simulateDoubleClickOnPoint:(CPArray)params
{
    var point = CGPointMake(params.shift(), params.shift()),
        window = [CPApp keyWindow];

    CPLog.debug("Cucapp is about to simulate a double click on the point : " + point);

    [self _perfomMouseEventOnPoint:point toPoint:nil window:window eventType:CPLeftMouseDown numberOfClick:2 modifierFlags:params[0]];
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

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:nil window:[obj window] eventType:CPLeftMouseDown numberOfClick:2 modifierFlags:params[0]];

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

    CPLog.debug("Cucapp is about to simulate a scroll wheel on the point (" + point.x + "," + point.y + ") with the deltas : " + deltaX + "," + deltaY + " and modifiers flags " + modifierFlags);

    var mouseWheel = [CPEvent mouseEventWithType:CPScrollWheel location:locationWindowPoint modifierFlags:modifierFlags
        timestamp:[CPEvent currentTimestamp] windowNumber:[window windowNumber] context:nil eventNumber:-1 clickCount:1 pressure:0];

    mouseWheel._deltaX = deltaX;
    mouseWheel._deltaY = deltaY;
    mouseWheel._scrollingDeltaX = deltaX;
    mouseWheel._scrollingDeltaY = deltaY;

    [CPApp sendEvent:mouseWheel];

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

    var mouseWheel = [CPEvent mouseEventWithType:CPScrollWheel location:locationWindowPoint modifierFlags:modifierFlags
        timestamp:[CPEvent currentTimestamp] windowNumber:[[obj window] windowNumber] context:nil eventNumber:-1 clickCount:1 pressure:0];

    mouseWheel._deltaX = deltaX;
    mouseWheel._deltaY = deltaY;
    mouseWheel._scrollingDeltaX = deltaX;
    mouseWheel._scrollingDeltaY = deltaY;

    [CPApp sendEvent:mouseWheel];

    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];

    return '{"result" : "OK"}';
}

- (void)simulateMouseMovedOnPoint:(CPArray)params
{
    var locationWindowPoint = CGPointMake(params.shift(), params.shift()),
        modifierFlags = 0,
        flags = params[0],
        window = [CPApp keyWindow];

    for (var i = 0; i < [flags count]; i++)
    {
        var flag = flags[i];
        modifierFlags |= parseInt(flag);
    }

    CPLog.debug("Cucapp is about to simulate a mouse moved to the point " + locationWindowPoint);

    [self _performMouseMoveOnPoint:locationWindowPoint window:window modifierFlags:modifierFlags];
}

- (void)_performMouseMoveOnPoint:(CGPoint)locationWindowPoint window:(CPWindow)currentWindow modifierFlags:(unsigned)flags
{
    var mouseMoved = [CPEvent mouseEventWithType:CPMouseMoved location:locationWindowPoint modifierFlags:flags
        timestamp:[CPEvent currentTimestamp] windowNumber:[currentWindow windowNumber] context:nil eventNumber:-1 clickCount:1 pressure:0];

    [CPApp sendEvent:mouseMoved];
}

- (void)_perfomMouseEventOnPoint:(CGPoint)locationWindowPoint toPoint:(CPView)locationWindowPoint2 window:(CPWindow)currentWindow eventType:(unsigned)anEventType numberOfClick:(int)numberOfClick modifierFlags:(CPArray)flags
{
    var typeMouseDown = CPLeftMouseDown,
        typeMouseUp = CPLeftMouseUp,
        modifierFlags = 0;

    locationWindowPoint.x = Math.round(locationWindowPoint.x);
    locationWindowPoint.y = Math.round(locationWindowPoint.y);

    var currentLocation = CGPointMakeCopy(locationWindowPoint);

    if (anEventType == CPRightMouseDown)
    {
        typeMouseDown = CPRightMouseDown;
        typeMouseUp = CPRightMouseUp;
    }

    for (var i = 0; i < [flags count]; i++)
    {
        var flag = flags[i];
        modifierFlags |= parseInt(flag);
    }

    if (locationWindowPoint2)
    {
        modifierFlags |= CPLeftMouseDraggedMask;
        locationWindowPoint2.x = Math.round(locationWindowPoint2.x);
        locationWindowPoint2.y = Math.round(locationWindowPoint2.y);
    }

    for (var i = 1; i < numberOfClick + 1; i++)
    {
        var mouseDown = [CPEvent mouseEventWithType:typeMouseDown location:currentLocation modifierFlags:modifierFlags
                           timestamp:[CPEvent currentTimestamp] windowNumber:[currentWindow windowNumber] context:nil eventNumber:0 clickCount:i pressure:0.5];
        [CPApp sendEvent:mouseDown];

        if (locationWindowPoint2)
        {
            var maxDiff = MAX(ABS(locationWindowPoint.x - locationWindowPoint2.x), ABS(locationWindowPoint.y - locationWindowPoint2.y)),
                xDiff = locationWindowPoint.x - locationWindowPoint2.x,
                yDiff = locationWindowPoint.y - locationWindowPoint2.y;

            for (var j = 0; j < maxDiff; j++)
            {
                var gapX = xDiff > 0 ? -1 : 1,
                    gapY = yDiff > 0 ? -1 : 1;

                if (currentLocation.y == locationWindowPoint2.y)
                    gapY = 0;

                if (currentLocation.x == locationWindowPoint2.x)
                    gapX = 0;

                currentLocation = CGPointMake(currentLocation.x + gapX, currentLocation.y + gapY);

                var mouseDragged = [CPEvent mouseEventWithType:CPLeftMouseDragged location:currentLocation modifierFlags:modifierFlags
                                   timestamp:[CPEvent currentTimestamp] windowNumber:[currentWindow windowNumber] context:nil eventNumber:-1 clickCount:i pressure:0];

                [CPApp sendEvent:mouseDragged];
            }
        }

        var mouseUp = [CPEvent mouseEventWithType:typeMouseUp location:currentLocation modifierFlags:modifierFlags
                           timestamp:[CPEvent currentTimestamp] windowNumber:[currentWindow windowNumber] context:nil eventNumber:0 clickCount:i pressure:0.5];
        [CPApp sendEvent:mouseUp];
    }

    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
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

@end

[Cucumber startCucumber];