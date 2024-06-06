//
//  SPSingleton.h
//  
//
//  Created by SPSuper on 2016/12/2.
// 单例模式设计 by Super

#define SingletonH(name)  + (instancetype)share##name;

// ARC
#if __has_feature(objc_arc)
#define SingletonM(name) static id _instance;\
+ (instancetype)allocWithZone:(struct _NSZone *)zone {\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [super allocWithZone:zone];\
});\
return _instance;}\
+ (instancetype)share##name { return [[self alloc] init]; }\
- (id)copyWithZone:(NSZone *)zone { return _instance; }\
- (id)mutableCopyWithZone:(NSZone *)zone { return _instance; }

// MRC
#else
#define SingletonM(name) static id _instance;\
+ (instancetype)allocWithZone:(struct _NSZone *)zone {\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [super allocWithZone:zone];\
});\
return _instance;}\
+ (instancetype)share##name { return [[self alloc] init]; }\
- (id)copyWithZone:(NSZone *)zone { return _instance; }\
- (id)mutableCopyWithZone:(NSZone *)zone { return _instance; }\
- (instancetype)retain { return _instance; }\
- (oneway void)release { }\
- (NSUInteger)retainCount { return MAXFLOAT; }
#endif




