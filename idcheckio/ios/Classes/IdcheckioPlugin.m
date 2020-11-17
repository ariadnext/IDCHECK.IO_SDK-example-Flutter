#import "IdcheckioPlugin.h"
#if __has_include(<idcheckio/idcheckio-Swift.h>)
#import <idcheckio/idcheckio-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "idcheckio-Swift.h"
#endif

@implementation IdcheckioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIdcheckioPlugin registerWithRegistrar:registrar];
}
@end
