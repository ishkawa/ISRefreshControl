#import "ISMethodSwizzling.h"
#import <objc/runtime.h>

void ISSwizzleInstanceMethod(Class class, SEL originalSelector, SEL alternativeSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method alternativeMethod = class_getInstanceMethod(class, alternativeSelector);
    
    if(class_addMethod(class, originalSelector, method_getImplementation(alternativeMethod), method_getTypeEncoding(alternativeMethod))) {
        class_replaceMethod(class, alternativeSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, alternativeMethod);
    }
}

void ISSwizzleClassMethod(Class class, SEL originalSelector, SEL alternativeSelector)
{
    class = object_getClass(class);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method alternativeMethod = class_getInstanceMethod(class, alternativeSelector);
    
    if(class_addMethod(class, originalSelector, method_getImplementation(alternativeMethod), method_getTypeEncoding(alternativeMethod))) {
        class_replaceMethod(class, alternativeSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, alternativeMethod);
    }
}