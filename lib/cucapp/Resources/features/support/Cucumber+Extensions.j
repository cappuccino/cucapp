@import <Foundation/Foundation.j>

@implementation Cucumber (CuCapp)

- (CPString)valueIsEqual:(CPArray)params
{
    var obj = cucumber_objects[params[0]],
        value = params[1];

    if (!obj)
        return '{"result" : "__CUKE_ERROR__"}';

    if ([obj respondsToSelector:@selector(stringValue)] && value === [obj stringValue])
        return '{"result" : "OK"}';

    return '{"result" : "__CUKE_ERROR__"}';
}

- (CPString)popUpButtonMenuCanScrollUp:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return '{"result" : "__CUKE_ERROR__"}';

    if ([[obj menu]._menuWindow canScrollUp])
        return '{"result" : "OK"}';
    else
        return '{"result" : "NOT OK"}';
}

- (CPString)popUpButtonMenuCanScrollDown:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return '{"result" : "__CUKE_ERROR__"}';

    if (![[obj menu]._menuWindow canScrollDown])
        return '{"result" : "OK"}';
    else
        return '{"result" : "NOT OK"}';
}

@end