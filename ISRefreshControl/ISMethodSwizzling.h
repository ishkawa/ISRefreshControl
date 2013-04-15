#import <Foundation/Foundation.h>

extern void ISSwizzleInstanceMethod(Class class, SEL originalSelector, SEL alternativeSelector);
extern void ISSwizzleClassMethod(Class class, SEL originalSelector, SEL alternativeSelector);
