// Copyright (c) 2014, Mirego
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// - Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// - Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// - Neither the name of the Mirego nor the names of its contributors may
//   be used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "MRGArchitect.h"
#import "MRGArchitectJSONLoader.h"
#import "MRGArchitectImportAction.h"

static UIColor *MRGUIColorWithHexString(NSString *hexString) {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@interface MRGArchitect ()
@property NSDictionary *entries;
@property NSCache *colorCache;
@property NSCache *fontCache;
@end

@implementation MRGArchitect

+ (instancetype)architectForClassName:(NSString *)className {
    MRGArchitect *architect = [[MRGArchitect alloc] initWithClassName:className];
    return architect;
}

- (BOOL)boolForKey:(NSString *)key {
    id object = [self objectForKey:key expectedClass:[NSNumber class]];
    return [object boolValue];
}

- (NSString *)stringForKey:(NSString *)key {
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]]) {
		return object;
    } else if ([object isKindOfClass:[NSNumber class]]) {
		return [object stringValue];
    } else {
        NSString *reason = [NSString stringWithFormat:@"Unexpected value type for key '%@'", key];
        @throw [NSException exceptionWithName:MRGArchitectUnexpectedValueTypeException reason:reason userInfo:nil];
    }
}

- (NSInteger)integerForKey:(NSString *)key {
    id object = [self objectForKey:key expectedClass:[NSNumber class]];
    return [object integerValue];
}

- (CGFloat)floatForKey:(NSString *)key {
    id object = [self objectForKey:key expectedClass:[NSNumber class]];
    return [object floatValue];
}

- (UIColor *)colorForKey:(NSString *)key {
    UIColor *cachedColor = [self.colorCache objectForKey:@"key"];
    if (nil != cachedColor) return cachedColor;
    
    NSString *hexString = [self stringForKey:key];
    return MRGUIColorWithHexString(hexString);
}

- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key {
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)object;
    
        CGFloat top = 0.0f;
        CGFloat left = 0.0f;
        CGFloat bottom = 0.0f;
        CGFloat right = 0.0f;
        
        if ([[dictionary allKeys] containsObject:@"top"]) {
            id obj = [dictionary objectForKey:@"top"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                top = [obj floatValue];
            }
        }
        if ([[dictionary allKeys] containsObject:@"left"]) {
            id obj = [dictionary objectForKey:@"left"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                left = [obj floatValue];
            }
        }
        if ([[dictionary allKeys] containsObject:@"bottom"]) {
            id obj = [dictionary objectForKey:@"bottom"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                bottom = [obj floatValue];
            }
        }
        if ([[dictionary allKeys] containsObject:@"right"]) {
            id obj = [dictionary objectForKey:@"right"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                right = [obj floatValue];
            }
        }
        return UIEdgeInsetsMake(top, left, bottom, right);
    } else if ([object isKindOfClass:[NSString class]]) {
        return UIEdgeInsetsFromString(object);
    } else {
        NSString *reason = [NSString stringWithFormat:@"Unexpected value type for key '%@'", key];
        @throw [NSException exceptionWithName:MRGArchitectUnexpectedValueTypeException reason:reason userInfo:nil];
    }
}

- (CGPoint)pointForKey:(NSString *)key {
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)object;
        CGFloat x = 0.0f;
        CGFloat y = 0.0f;
        if ([[dictionary allKeys] containsObject:@"x"]) {
            id obj = [dictionary objectForKey:@"x"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                x = [obj floatValue];
            }
        }
        if ([[dictionary allKeys] containsObject:@"y"]) {
            id obj = [dictionary objectForKey:@"y"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                y = [obj floatValue];
            }
        }
        return CGPointMake(x, y);
    } else if ([object isKindOfClass:[NSString class]]) {
        return CGPointFromString(object);
    } else {
        NSString *reason = [NSString stringWithFormat:@"Unexpected value type for key '%@'", key];
        @throw [NSException exceptionWithName:MRGArchitectUnexpectedValueTypeException reason:reason userInfo:nil];
    }
}

- (CGSize)sizeForKey:(NSString *)key {
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)object;
        CGFloat width = 0.0f;
        CGFloat height = 0.0f;
        if ([[dictionary allKeys] containsObject:@"width"]) {
            id obj = [dictionary objectForKey:@"width"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                width = [obj floatValue];
            }
        }
        if ([[dictionary allKeys] containsObject:@"height"]) {
            id obj = [dictionary objectForKey:@"height"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                height = [obj floatValue];
            }
        }
        return CGSizeMake(width, height);
    } else if ([object isKindOfClass:[NSString class]]) {
        return CGSizeFromString(object);
    } else {
        NSString *reason = [NSString stringWithFormat:@"Unexpected value type for key '%@'", key];
        @throw [NSException exceptionWithName:MRGArchitectUnexpectedValueTypeException reason:reason userInfo:nil];
    }
}

- (UIFont *)fontForKey:(NSString *)key {
    UIFont *cachedFont = [self.fontCache objectForKey:key];
    if (nil != cachedFont) return cachedFont;
    
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)object;
        NSString *name = nil;
        CGFloat size = 0.0f;
        if ([[dictionary allKeys] containsObject:@"name"]) {
            id obj = [dictionary objectForKey:@"name"];
            if ([obj isKindOfClass:[NSString class]]) {
                name = obj;
            }
        }
        if ([[dictionary allKeys] containsObject:@"size"]) {
            id obj = [dictionary objectForKey:@"size"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                size = [obj floatValue];
            }
        }
        UIFont *font = [UIFont fontWithName:name size:size];
        [self.fontCache setObject:font forKey:key];
        return font;
    } else {
        NSString *reason = [NSString stringWithFormat:@"Unexpected value type for key '%@'", key];
        @throw [NSException exceptionWithName:MRGArchitectUnexpectedValueTypeException reason:reason userInfo:nil];
    }
}

- (CGRect)rectForKey:(NSString *)key {
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)object;
        CGPoint origin = CGPointZero;
        CGSize size = CGSizeZero;
        if ([[dictionary allKeys] containsObject:@"origin"]) {
            id originObj = [dictionary objectForKey:@"origin"];
            if ([originObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)originObj;
                CGFloat x = 0.0f;
                CGFloat y = 0.0f;
                if ([[dict allKeys] containsObject:@"x"]) {
                    id obj = [dict objectForKey:@"x"];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        x = [obj floatValue];
                    }
                }
                if ([[dict allKeys] containsObject:@"y"]) {
                    id obj = [dict objectForKey:@"y"];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        y = [obj floatValue];
                    }
                }
                origin = CGPointMake(x, y);
            }
            id sizeObj = [dictionary objectForKey:@"size"];
            if ([sizeObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)sizeObj;
                CGFloat width = 0.0f;
                CGFloat height = 0.0f;
                if ([[dict allKeys] containsObject:@"width"]) {
                    id obj = [dict objectForKey:@"width"];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        width = [obj floatValue];
                    }
                }
                if ([[dict allKeys] containsObject:@"height"]) {
                    id obj = [dict objectForKey:@"height"];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        height = [obj floatValue];
                    }
                }
                size = CGSizeMake(width, height);
            }
        }
        return CGRectMake(origin.x, origin.y, size.width, size.height);
    } else {
        NSString *reason = [NSString stringWithFormat:@"Unexpected value type for key '%@'", key];
        @throw [NSException exceptionWithName:MRGArchitectUnexpectedValueTypeException reason:reason userInfo:nil];
    }
}


#pragma mark - Private Implementation

- (instancetype)initWithClassName:(NSString *)className {
    if (self = [super init]) {
        id<MRGArchitectLoader> loader = [[MRGArchitectJSONLoader alloc] init];
        [loader registerAction:[MRGArchitectImportAction class]];

        _entries = [loader loadEntriesWithClassName:className];
        _colorCache = [NSCache new];
        _fontCache = [NSCache new];
    }
    
    return self;
}

- (id)objectForKey:(NSString *)key {
    return [self objectForKey:key expectedClass:nil];
}

- (id)objectForKey:(NSString *)key expectedClass:(Class)class {
    id object = [self.entries objectForKey:key];
    if (nil == object) {
        NSString *reason = [NSString stringWithFormat:@"Key '%@' not found.", key];
        @throw [NSException exceptionWithName:MRGArchitectKeyNotFoundException reason:reason userInfo:nil];
    }
    
    if (class && ![object isKindOfClass:class]) {
        NSString *reason = [NSString stringWithFormat:@"Unexpected value type for key '%@'", key];
        @throw [NSException exceptionWithName:MRGArchitectUnexpectedValueTypeException reason:reason userInfo:nil];
    }
    
    return object;
}


@end
