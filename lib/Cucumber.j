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
@import <AppKit/AppKit.j>
@import "Cappuccino+Cucumber.j"

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

    if ([obj respondsToSelector:@selector(objectValue)])
        return '{"result" : "' + [obj objectValue] + '"}';

    return '{"result" : ""}';
}

- (CPString)textFor:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return '{"result" : "__CUKE_ERROR__"}';

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

    var keyDownEvent = [CPEvent keyEventWithType:CPKeyDown location:CGPointMakeZero() modifierFlags:modifierFlags
        timestamp:[CPEvent currentTimestamp] windowNumber:[currentWindow windowNumber] context:nil characters:character charactersIgnoringModifiers:charactersIgnoringModifiers isARepeat:NO keyCode:100];
    [CPApp sendEvent:keyDownEvent];

    var keyUpEvent = [CPEvent keyEventWithType:CPKeyUp location:CGPointMakeZero() modifierFlags:modifierFlags
        timestamp:[CPEvent currentTimestamp] windowNumber:[currentWindow windowNumber] context:nil characters:character charactersIgnoringModifiers:charactersIgnoringModifiers isARepeat:NO keyCode:100];

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

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:locationWindowPoint2 window:[obj1 window] eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (CPString)simulateDraggedClickViewToPoint:(CPArray)params
{
    var locationWindowPoint = CGPointMake(params.shift(), params.shift()),
        locationWindowPoint2 = CGPointMake(params.shift(), params.shift());

    if (!locationWindowPoint || !locationWindowPoint2)
        return '{"result" : "OBJECT NOT FOUND"}';

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:locationWindowPoint2 window:[CPApp mainWindow] eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (void)simulateLeftClickOnPoint:(CPArray)params
{
    var point = CGPointMake(params.shift(), params.shift()),
        window = [CPApp keyWindow];

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

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:nil window:[obj window] eventType:CPLeftMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (void)simulateRightClickOnPoint:(CPArray)params
{
    var point = CGPointMake(params.shift(), params.shift()),
        window = [CPApp keyWindow];

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

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:nil window:[obj window] eventType:CPRightMouseDown numberOfClick:1 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (void)simulateDoubleClickOnPoint:(CPArray)params
{
    var point = CGPointMake(params.shift(), params.shift()),
        window = [CPApp keyWindow];

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

    [self _perfomMouseEventOnPoint:locationWindowPoint toPoint:nil window:[obj window] eventType:CPLeftMouseDown numberOfClick:2 modifierFlags:params[0]];

    return '{"result" : "OK"}';
}

- (void)simulateScrollWheel:(CPArray)params
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

    var mouseWheel = [CPEvent mouseEventWithType:CPScrollWheel location:locationWindowPoint modifierFlags:modifierFlags
        timestamp:[CPEvent currentTimestamp] windowNumber:[[obj window] windowNumber] context:nil eventNumber:-1 clickCount:1 pressure:0];

    mouseWheel._deltaX = deltaX;
    mouseWheel._deltaY = deltaY;

    [CPApp sendEvent:mouseWheel];

    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

- (void)_perfomMouseEventOnPoint:(CGPoint)locationWindowPoint toPoint:(CPView)locationWindowPoint2 window:(CPWindow)currentWindow eventType:(unsigned)anEventType numberOfClick:(int)numberOfClick modifierFlags:(CPArray)flags
{
    var typeMouseDown = CPLeftMouseDown,
        typeMouseUp = CPLeftMouseUp,
        modifierFlags = 0;

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
        modifierFlags |= CPLeftMouseDraggedMask;

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