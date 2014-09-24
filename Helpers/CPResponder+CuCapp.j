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