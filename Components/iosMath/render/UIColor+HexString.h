//
//  UIColor+HexString.h
//  iosMath
//
//  Created by Markus Sähn on 21/03/2017.
//
//

#import <UIKit/UIKit.h>

#if TARGET_OS_IPHONE

@interface UIColor (HexString)

+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
#endif
