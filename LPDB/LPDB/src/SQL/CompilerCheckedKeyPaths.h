//
//  CompilerCheckedKeyPaths.h
//  mtt
//
//  Created by pennyli on 15/10/26.
//  Copyright © 2015年 Tencent. All rights reserved.
//


// See http://nshipster.com/key-value-observing/
// Put this code a common utilities header, and use it to have the compiler help check correctness of key paths.
// Uses macro stringification to create an Obj-C string literal, plus validation code that the compiler optimizes out.

@interface NSObject (KeyPathFakeCategoryForCompilerWarnings)
+ (instancetype)__fake_method_for_compiler_warnings__;
- (instancetype)__fake_method_for_compiler_warnings__;
@end

/*! Returns a string for the given keypath, but causes a compiler warning if the keypath is not defined on \c self.
 \note Works for both instance and class methods.
 */
#define KeyPathForSelf(__keypath) \
({if (NO) {(void)[super __fake_method_for_compiler_warnings__].__keypath;} @#__keypath;})

/*! Returns a string for the given keypath, but causes a compiler warning if the keypath is not defined on \a __object.
 */
#define KeyPathForObject(__object, __keypath) \
({if (NO) {(void)__object.__keypath;} @#__keypath;})

/*! Returns a string for the given keypath, but causes a compiler warning if the keypath is not defined on \a __class.
 */
#define KeyPathForClass(__class, __keypath) \
({if (NO) {__class *__object = nil; (void)__object.__keypath;} @#__keypath;})
