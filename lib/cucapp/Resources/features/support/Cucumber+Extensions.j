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

- (CPString)delegatePropertyIsEqual:(CPArray)params
{
    var property = params[0];

    if (property == nil)
        return '{"error" : "The property ' + property +' was not found"}';

    var expected_value = params[1],
        current_value = [[[CPApplication sharedApplication] delegate] valueForKey:property];

    if (current_value != expected_value)
        return '{"error" : "The value should be ' + expected_value +' but was '+ [current_value description] + '"}';

    return '{"error" : "__NO_ERROR__"}';
}

@end
