#import "VBModule.h"
#import <MobileCoreServices/LSApplicationProxy.h>
#import <spawn.h>
#import <pthread.h>
#import "../include/NSTask.h"
#import "../vnode/kernel.h"

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1
int posix_spawnattr_set_persona_np(const posix_spawnattr_t* __restrict, uid_t, uint32_t);
int posix_spawnattr_set_persona_uid_np(const posix_spawnattr_t* __restrict, uid_t);
int posix_spawnattr_set_persona_gid_np(const posix_spawnattr_t* __restrict, uid_t);

int run_as_root(const char* _file, const char** _argv) {
  posix_spawnattr_t attr;
  posix_spawnattr_init(&attr);
  posix_spawnattr_set_persona_np(&attr, /*persona_id=*/99, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
  posix_spawnattr_set_persona_uid_np(&attr, 0);
  posix_spawnattr_set_persona_gid_np(&attr, 0);

  int pid = 0;
  int ret = posix_spawnp(&pid, _file, NULL, NULL, (char *const *)_argv, NULL);
  //NSLog(@"[vbmodule] posix_spawnp ret: %d", ret);
  if (ret) {
    // fprintf(stderr, "failed to exec %s: %s\n", _file, strerror(errno));
    return 1;
  }
  // waitUntilDone(pid);
  int status;
  waitpid(pid, &status, 0);
  // NSLog(@"[vnode] child_pid: %d", child_pid);
  return 0;
}


@implementation VBModule

// Most third-party Control Center modules out there use non-CAML approach because it's easier to get icon images than create CAML
// Choose either CAML and non-CAML portion of the code for your final implementation of the toggle
// IMPORTANT: To prepare your icons and configure the toggle to its fullest, check out CCSupport Wiki: https://github.com/opa334/CCSupport/wiki

#pragma mark - CAML approach

// CAML descriptor of your module (.ca directory)
// Read more about CAML here: https://medium.com/ios-creatix/apple-make-your-caml-format-a-public-api-please-9e10ba126e9d
- (CCUICAPackageDescription *)glyphPackageDescription {
    return [CCUICAPackageDescription descriptionForPackageNamed:@"VBModule" inBundle:[NSBundle bundleForClass:[self class]]];
}

#pragma mark - End CAML approach

#pragma mark - Non-CAML approach


// Icon of your module
- (UIImage *)iconGlyph {
    return [UIImage imageNamed:@"disabled" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

// Optional: Icon of your module, once selected 
- (UIImage *)selectedIconGlyph {
    return [UIImage imageNamed:@"enabled" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

// Selected color of your module
- (UIColor *)selectedColor {
    return [UIColor blackColor];
}

#pragma mark - End Non-CAML approach

// Current state of your module
- (BOOL)isSelected {
    return access("/var/jb/bin/bash", F_OK) != 0;
}

-(UIAlertController *)showProgress:(BOOL)selected{

    NSString *plzwait = @"";
    if(selected) plzwait = @"隐藏";
    else  plzwait = @"显示";
    plzwait = [NSString stringWithFormat:@"%@ 文件中...", plzwait];


    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = keyWindow.rootViewController;
    UIAlertController *progressAlert = [UIAlertController alertControllerWithTitle:@"vnodebypass" message:plzwait preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *progressActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [progressActivity startAnimating];
	[progressActivity setFrame:CGRectMake(0, 0, 70, 60)];
	[progressAlert.view addSubview:progressActivity];
	[rootViewController presentViewController:progressAlert animated:YES completion:nil];
    return progressAlert;
}

-(void)showAlert:(NSString *)title msg:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];

    [alertController addAction:okAction];

    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = keyWindow.rootViewController;

    [rootViewController presentViewController:alertController
                                     animated:YES
                                   completion:nil];
}

- (void)setSelected:(BOOL)selected {

    UIAlertController *progressAlert = [self showProgress:selected];

    [progressAlert dismissViewControllerAnimated:YES completion:^{
    // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{

        

    //     dispatch_async(dispatch_get_main_queue(), ^{

            LSApplicationProxy* app = [LSApplicationProxy applicationProxyForIdentifier:@"kr.xsf1re.vnodebypass"];
            NSString *exec = app.bundleExecutable;
            NSString *execPath = [NSString stringWithFormat:@"%@/procursus/usr/bin/%@", locateJailbreakRoot(), exec];
            // NSLog(@"[vnodeDEBUG] execPath: %@, exec: %@", execPath, exec);
            // NSString *execPath = [NSString stringWithFormat:@"/var/jb/usr/bin/%@", exec];
            
            if (selected) {
                const char* args[] = {exec.UTF8String, "-s", NULL};
                run_as_root(execPath.UTF8String, args);

                const char* args2[] = {exec.UTF8String, "-h", NULL};
                run_as_root(execPath.UTF8String, args2);

                // const char* args[] = {exec.UTF8String, "-s", NULL};
                // posix_spawn(&pid, execPath.UTF8String, NULL, NULL, (char* const*)args, NULL);
                // waitpid(pid, &status, 0);
                // sleep(1);

                // const char* args2[] = {exec.UTF8String, "-h", NULL};
                // posix_spawn(&pid, execPath.UTF8String, NULL, NULL, (char* const*)args2, NULL);
                // waitpid(pid, &status, 0);
            } else {
                const char* args[] = {exec.UTF8String, "-xr", NULL};
                run_as_root(execPath.UTF8String, args);

                const char* args2[] = {exec.UTF8String, "-R", NULL};
                run_as_root(execPath.UTF8String, args2);
                // const char* args[] = {exec.UTF8String, "-r", NULL};
                // posix_spawn(&pid, execPath.UTF8String, NULL, NULL, (char* const*)args, NULL);
                // waitpid(pid, &status, 0);
                // sleep(1);

                // const char* args2[] = {exec.UTF8String, "-R", NULL};
                // posix_spawn(&pid, execPath.UTF8String, NULL, NULL, (char* const*)args2, NULL);
                // waitpid(pid, &status, 0);
            }

            [super refreshState];

            if(selected) {
                if(access("/var/jb/bin/bash", F_OK) == 0) {
                    [self showAlert:@"vnodebypass" msg:@"隐藏文件失败，请安装 libkrw/libkernrw 或稍后重试。如果仍然存​​在错误，请注销。"];
                } else {
                    [self showAlert:@"vnodebypass" msg:@"成功隐藏文件"];
                }
            } else {
                if(access("/var/jb/bin/bash", F_OK) != 0) {
                    [self showAlert:@"vnodebypass" msg:@"无法显示文件，请稍后重试。如果仍然存​​在错误，请注销。"];
                } else {
                    [self showAlert:@"vnodebypass" msg:@"成功显示文件"];
                }
            }
    //     });
    // });
    }];


    // if (selected) {
    //     // Your module turned selected/on, do something
    // } else {
    //     // Your module turned unselected/off, do something
    // }
}

@end
