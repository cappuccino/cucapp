/*
* Copyright (c) 2014 Nuage Networks
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/


// Import this Categories from your application
// You can now user -(void)setCucappIdentifier: and -(CPString)cucappIdentifier
// to set and get your cucapp IDs.
// Then from a test, you can use it as a selector like //CPView[cucappIdentifier="my-button"]

@import <AppKit/CPResponder.j>
@import <AppKit/CPMenuItem.j>

@implementation CPResponder (cucappAdditions)

- (void)setCucappIdentifier:(CPString)anIdentifier
{
    self.__cucappIdentifier = anIdentifier;
}

- (CPString)cucappIdentifier
{
    return self.__cucappIdentifier;
}

@end

@implementation CPMenuItem (cucappAdditionsMenu)

- (void)setCucappIdentifier:(CPString)anIdentifier
{
    [[self _menuItemView] setCucappIdentifier:anIdentifier];
}

- (CPString)cucappIdentifier
{
    [[self _menuItemView] cucappIdentifier];
}

@end

var CLI_LOADED = NO;

function load_cucapp_CLI(path)
{
    if (!path)
        path = "../../Cucapp/lib/Cucumber.j"

    try {
        objj_importFile(path, true, function() {
            [Cucumber stopCucumber];
            CLI_LOADED = YES;
            CPLog.debug("Cucapp CLI has been well loaded");
        });
    }
    catch(e)
    {
        [CPException raise:CPInvalidArgumentException reason:@"Invalid path for the lib Cucumber"];
    }
}

function simulate_keyboard_event(character, flags)
{
    if (!CLI_LOADED)
        [CPException raise:CPInvalidArgumentException reason:@"Cucapp CLI need to be loaded first with the function load_cucapp_CLI(path)"];

    if (!flags)
        flags = [];

    [cucumber_instance simulateKeyboardEvent:[character, flags]];
}

function simulate_keyboard_events(string, flags)
{
    if (!CLI_LOADED)
        [CPException raise:CPInvalidArgumentException reason:@"Cucapp CLI need to be loaded first with the function load_cucapp_CLI(path)"];

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
    if (!CLI_LOADED)
        [CPException raise:CPInvalidArgumentException reason:@"Cucapp CLI need to be loaded first with the function load_cucapp_CLI(path)"];

    if (!flags)
        flags = [];

    [cucumber_instance simulateLeftClickOnPoint:[x, y, flags]];
}

function simulate_right_click_on_point(x, y, flags)
{
    if (!CLI_LOADED)
        [CPException raise:CPInvalidArgumentException reason:@"Cucapp CLI need to be loaded first with the function load_cucapp_CLI(path)"];

    if (!flags)
        flags = [];

    [cucumber_instance simulateRightClick:[x, y, flags]];
}

function simulate_double_click_on_point(x, y, flags)
{
    if (!CLI_LOADED)
        [CPException raise:CPInvalidArgumentException reason:@"Cucapp CLI need to be loaded first with the function load_cucapp_CLI(path)"];

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
    if (!CLI_LOADED)
        [CPException raise:CPInvalidArgumentException reason:@"Cucapp CLI need to be loaded first with the function load_cucapp_CLI(path)"];

    if (!flags)
        flags = [];

    [cucumber_instance simulateDraggedClickViewToView:[x, y, x2, y2, flags]];
}

function simulate_mouse_moved_on_point(x, y, flags)
{
    if (!CLI_LOADED)
        [CPException raise:CPInvalidArgumentException reason:@"Cucapp CLI need to be loaded first with the function load_cucapp_CLI(path)"];

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

function _getObjectsWithKeyAndValue(aKey, aValue)
{
    if (!CLI_LOADED)
        [CPException raise:CPInvalidArgumentException reason:@"Cucapp CLI need to be loaded first with the function load_cucapp_CLI(path)"];

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

function find_cucappID(cucappIdentifier)
{
    CPLog.error(@"Begin to look for : " + cucappIdentifier)
    var windows = [CPApp windows],
        menu = [CPApp mainMenu];

    for (var i = 0; i < windows.length; i++)
        _searchCucappID(windows[i], cucappIdentifier);

    if (menu)
        _searchCucappID(menu);

    CPLog.error(@"End of look of : " + cucappIdentifier)
}

function _searchCucappID(obj, cucappIdentifier)
{
    if (!obj ||
        ([obj respondsToSelector:@selector(isHidden)] && [obj isHidden]) ||
        ([obj respondsToSelector:@selector(isVisible)] && ![obj isVisible]) ||
        ([obj respondsToSelector:@selector(visibleRect)] && CGRectEqualToRect([obj visibleRect], CGRectMakeZero())))
        return '';

    if ([obj respondsToSelector:@selector(cucappIdentifier)] && [obj cucappIdentifier] == cucappIdentifier)
    {
        CPLog.error([obj description])
        console.error(obj);
    }

    if ([obj respondsToSelector: @selector(subviews)])
    {
        var views = [obj subviews];

        for (var i = 0; i < views.length; i++)
            _searchCucappID(views[i], cucappIdentifier);
    }

    if ([obj respondsToSelector: @selector(itemArray)])
    {
        var items = [obj itemArray];

        if (items && items.length > 0)
        {
            for (var i = 0; i < items.length; i++)
                _searchCucappID(items[i], cucappIdentifier);
        }
    }

    if ([obj respondsToSelector: @selector(submenu)])
    {
        var submenu = [obj submenu];

        if (submenu)
           _searchCucappID(submenu, cucappIdentifier);
    }

    if ([obj respondsToSelector: @selector(buttons)])
    {
        var buttons = [obj buttons];

        if (buttons && buttons.length > 0)
        {
            for (var i = 0; i < buttons.length; i++)
                _searchCucappID(buttons[i], cucappIdentifier);
        }
    }

    if ([obj respondsToSelector: @selector(contentView)])
        _searchCucappID([obj contentView], cucappIdentifier);
}