#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dispatch/dispatch.h>
#import <stdint.h>
#import <string.h>
#import <unistd.h>

static IMP originalCreateWindow = NULL;
static IMP originalSetWindowFeatures = NULL;
static BOOL hookInstalled = NO;

static BOOL EFIsEndfieldProcess(void)
{
    NSString *name = [[[NSProcessInfo processInfo] processName] lowercaseString];
    if ([name containsString:@"endfield"]) return YES;

    for (NSString *arg in [[NSProcessInfo processInfo] arguments])
    {
        if ([[arg lowercaseString] containsString:@"endfield.exe"])
            return YES;
    }
    return NO;
}

static NSString *EFLogPath(void)
{
    return [NSHomeDirectory() stringByAppendingPathComponent:
        @"Library/Application Support/CrossOver/Bottles/Arknights Endfield/.endfield-r11-runtime/green-button-hook.log"];
}

static void EFLog(NSString *message)
{
    NSString *path = EFLogPath();
    NSString *line = [NSString stringWithFormat:@"%@ pid=%d %@\n",
                      [NSDate date], getpid(), message];
    NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSData data] writeToFile:path atomically:YES];

    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!handle) return;
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
}

static uint32_t EFPatchFeatureBits(const void *features)
{
    uint32_t bits = 0;
    if (features) memcpy(&bits, features, sizeof(bits));

    /* macdrv_window_features: bit 3=resizable, bit 4=maximize_button */
    if (EFIsEndfieldProcess())
        bits |= (1u << 3) | (1u << 4);

    return bits;
}

typedef id (*CreateWindowFn)(id, SEL, const void *, NSRect, void *, id);

static id EFCreateWindow(id self, SEL _cmd, const void *features,
                         NSRect frame, void *hwnd, id queue)
{
    uint32_t patched = EFPatchFeatureBits(features);

    if (EFIsEndfieldProcess())
    {
        uint32_t original = 0;
        if (features) memcpy(&original, features, sizeof(original));
        EFLog([NSString stringWithFormat:
            @"createWindowWithFeatures original=0x%02x patched=0x%02x",
            original & 0xff, patched & 0xff]);
    }

    return ((CreateWindowFn)originalCreateWindow)(
        self, _cmd, EFIsEndfieldProcess() ? &patched : features,
        frame, hwnd, queue
    );
}

typedef void (*SetWindowFeaturesFn)(id, SEL, const void *);

static void EFSetWindowFeatures(id self, SEL _cmd, const void *features)
{
    uint32_t patched = EFPatchFeatureBits(features);

    if (EFIsEndfieldProcess())
    {
        uint32_t original = 0;
        if (features) memcpy(&original, features, sizeof(original));
        EFLog([NSString stringWithFormat:
            @"setWindowFeatures original=0x%02x patched=0x%02x title=%@",
            original & 0xff, patched & 0xff,
            [self respondsToSelector:@selector(title)] ? [self title] : @""]);
    }

    ((SetWindowFeaturesFn)originalSetWindowFeatures)(
        self, _cmd, EFIsEndfieldProcess() ? &patched : features
    );
}

static void EFRepairExistingWindows(void)
{
    if (!EFIsEndfieldProcess()) return;

    Class wineWindow = NSClassFromString(@"WineWindow");

    for (NSWindow *window in [NSApp windows])
    {
        if (!wineWindow || ![window isKindOfClass:wineWindow])
            continue;

        [window setStyleMask:[window styleMask] | NSWindowStyleMaskResizable];

        NSWindowCollectionBehavior behavior = [window collectionBehavior];
        behavior |= NSWindowCollectionBehaviorParticipatesInCycle;
        behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
        behavior &= ~NSWindowCollectionBehaviorFullScreenAuxiliary;
        behavior &= ~NSWindowCollectionBehaviorFullScreenNone;
        [window setCollectionBehavior:behavior];

        [[window standardWindowButton:NSWindowFullScreenButton] setEnabled:YES];
        [[window standardWindowButton:NSWindowZoomButton] setEnabled:YES];

        [window setContentMinSize:NSMakeSize(1, 1)];
        [window setContentMaxSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
    }
}

static BOOL EFInstallHookNow(void)
{
    if (hookInstalled) return YES;

    Class cls = NSClassFromString(@"WineWindow");
    if (!cls) return NO;

    SEL createSel =
        sel_registerName("createWindowWithFeatures:windowFrame:hwnd:queue:");
    SEL setSel = sel_registerName("setWindowFeatures:");

    Method createMethod = class_getClassMethod(cls, createSel);
    Method setMethod = class_getInstanceMethod(cls, setSel);
    if (!createMethod || !setMethod) return NO;

    originalCreateWindow = method_getImplementation(createMethod);
    originalSetWindowFeatures = method_getImplementation(setMethod);

    method_setImplementation(createMethod, (IMP)EFCreateWindow);
    method_setImplementation(setMethod, (IMP)EFSetWindowFeatures);
    hookInstalled = YES;

    if (EFIsEndfieldProcess())
        EFLog(@"WineWindow feature hooks installed");

    EFRepairExistingWindows();
    return YES;
}

static void EFRetryHook(unsigned attempt)
{
    if (EFInstallHookNow() || attempt >= 200) return;

    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)),
        dispatch_get_main_queue(),
        ^{ EFRetryHook(attempt + 1); }
    );
}

static void EFKeepWindowEligible(unsigned attempt)
{
    if (!EFIsEndfieldProcess()) return;

    EFRepairExistingWindows();

    if (attempt < 240)
    {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(250 * NSEC_PER_MSEC)),
            dispatch_get_main_queue(),
            ^{ EFKeepWindowEligible(attempt + 1); }
        );
    }
}

__attribute__((constructor))
static void EFStart(void)
{
    if (!EFInstallHookNow())
        dispatch_async(dispatch_get_main_queue(), ^{ EFRetryHook(0); });

    dispatch_async(dispatch_get_main_queue(), ^{ EFKeepWindowEligible(0); });
}
