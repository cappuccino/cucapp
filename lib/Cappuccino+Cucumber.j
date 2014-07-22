/*
* Copyright 2010, Daniel Parnell, Automagic Software Pty Ltd All rights reserved.
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
@import <AppKit/CPResponder.j>


@global addCucumberObject
@global dumpGuiObject

var CPResponderNextResponderKey = @"CPResponderNextResponderKey",
    CPResponderMenuKey = @"CPResponderMenuKey";


/*! CPObject Modification
*/
@implementation CPObject (ClassName)

- (CPString)className
{
    return CPStringFromClass([self class]);
}

+ (CPString)className
{
    return CPStringFromClass(self);
}

@end


@implementation CPResponder (CuCapp)

- (void)setCucappIdentifier:(CPString)anIdentifier
{
    self.__cucappIdentifier = anIdentifier;
}

- (CPString)cucappIdentifier
{
    return self.__cucappIdentifier;
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super init];

    if (self)
    {
        [self setNextResponder:[aCoder decodeObjectForKey:CPResponderNextResponderKey]];
        [self setMenu:[aCoder decodeObjectForKey:CPResponderMenuKey]];
        [self setCucappIdentifier:[aCoder decodeObjectForKey:@"__cucappIdentifier"]];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    // This will come out nil on the other side with decodeObjectForKey:
    if (_nextResponder !== nil)
        [aCoder encodeConditionalObject:_nextResponder forKey:CPResponderNextResponderKey];

    [aCoder encodeObject:_menu forKey:CPResponderMenuKey];

    if (self.__cucappIdentifier)
        [aCoder encodeObject:self.__cucappIdentifier forKey:@"__cucappIdentifier"];
}

@end



@implementation CPApplication (Cucumber)

- (CPString)xmlDescription
{
    var resultingXML = "<"+[self className]+">";

    resultingXML += "<id>"+addCucumberObject(self)+"</id>";

    var windows = [self windows];

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

    var menu = [self mainMenu];

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

    resultingXML += "</"+[self className]+">";

    return resultingXML;
}

@end
