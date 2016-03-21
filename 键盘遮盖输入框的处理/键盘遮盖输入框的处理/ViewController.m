//
//  ViewController.m
//  键盘遮盖输入框的处理
//
//  Created by sw on 16/3/18.
//  Copyright © 2016年 sw. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
/** 标记是否改变了子控件的Y值 */
@property(nonatomic,assign)BOOL isChangeY;
/** 记录子控件在Y方向改变的值 */
@property(nonatomic,assign)CGFloat changeY;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 注意：一定给控制器的view设置背景颜色，否则重写控制器的touchs方法无效！
    self.view.backgroundColor = [UIColor greenColor];
    
    // 补充：以下是与键盘相关的所有通知
    /*
     UIKIT_EXTERN NSString *const UIKeyboardWillChangeFrameNotification  NS_AVAILABLE_IOS(5_0); // 键盘将要改变时发送该通知。也就是说，键盘将要弹出、将要退出的时候都会发送这个通知。
     UIKIT_EXTERN NSString *const UIKeyboardDidChangeFrameNotification   NS_AVAILABLE_IOS(5_0); // 键盘的frame改变后就会发送这个通知。也就是说，键盘弹出、退出后都会发送这个通知。
     UIKIT_EXTERN NSString *const UIKeyboardWillShowNotification; // 键盘将要弹出的时候发送该通知。
     UIKIT_EXTERN NSString *const UIKeyboardDidShowNotification; // 键盘弹出后发送该通知。
     UIKIT_EXTERN NSString *const UIKeyboardWillHideNotification; // 键盘将要退出时发送该通知。
     UIKIT_EXTERN NSString *const UIKeyboardDidHideNotification; // 键盘退出后发送该通知。
    */
    // 通知的强大之处就在于：可以通过userInfo在不同的对象之间发送各种数据
    // 因为键盘弹出或者退出前后，系统自己会发送通知，所以我们不需要自己发送通知。
    // [NSNotificationCenter defaultCenter] postNotificationName:<#(nonnull NSString *)#> object:<#(nullable id)#> userInfo:<#(nullable NSDictionary *)#>];

    // 以下是打印的键盘弹出后的userInfo:
    /*
     {
        UIKeyboardAnimationCurveUserInfoKey = 7;
        UIKeyboardAnimationDurationUserInfoKey = "0.25";
        UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {375, 258}}";
        UIKeyboardCenterBeginUserInfoKey = "NSPoint: {187.5, 796}";
        UIKeyboardCenterEndUserInfoKey = "NSPoint: {187.5, 538}";
        UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 667}, {375, 258}}";
        UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 409}, {375, 258}}";
        UIKeyboardIsLocalUserInfoKey = 1;
     }
     */
    
    // 注意：
    // 为什么是注册UIKeyboardWillShowNotification和UIKeyboardWillHideNotification
    // 因为这样可以让被遮挡的子控件和键盘一起上移
    // 如果注册UIKeyboardWDidShowNotification和UIKeyboardDidHideNotification，那么只有键盘完全弹出后或者完全退出后，子控件才会开始移动。
    
    // 注册键盘弹出前、退出前的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillHideNotification object:nil];

    // 添加子控件
    UITextField *textField1 = [[UITextField alloc] initWithFrame:CGRectMake(200, 500, 50, 30)];
    textField1.backgroundColor = [UIColor redColor];
    UITextField *textField2 = [[UITextField alloc] initWithFrame:CGRectMake(150, 400, 60, 30)];
    textField2.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:textField1]; // ok
    [self.view addSubview:textField2];
//    [self.view insertSubview:textField atIndex:0]; // ok
//    [self.view insertSubview:textField aboveSubview:self.view]; // ok
//    [self.view insertSubview:textField belowSubview:self.view]; // ok
}

#pragma mark - 键盘弹出
- (void)keyboardFrameDidChange:(NSNotification *)noti
{
    NSLog(@"%@",noti.userInfo);
    
    if ([noti.name isEqualToString:@"UIKeyboardWillShowNotification"]) {
        NSLog(@"keyboardDidShow...");
        
        // 键盘弹出后，所有子控件上移
        [self moveUpSubview:YES withNoti:noti];
        
    } else if ([noti.name isEqualToString:@"UIKeyboardWillHideNotification"]){
        NSLog(@"keyboardDidHiden...");
        
        // 键盘退出后，恢复所有子控件的位置
        [self moveUpSubview:NO withNoti:noti];
        
    }
    
}

#pragma mark - 根据键盘的弹出和退出，移动子控件的位置，参数isUp为YES代表键盘弹出；参数isUp为NO代表键盘退出
// 遍历控制器view上的子控件，如果最下面的子控件坐标Y值大于键盘弹出后的坐标Y值，那么所有子控件上移。上移的距离 = 子控件的Y - 键盘弹出后的Y
- (void)moveUpSubview:(BOOL)isUp withNoti:(NSNotification *)noti
{
    CGFloat maxY = 0;
    CGFloat subViewY = 0;
    
    if (isUp) { // 键盘弹出
        // 键盘弹出后的Y值
        NSDictionary *endUserInfo = noti.userInfo;
        NSValue *endValue = endUserInfo[@"UIKeyboardFrameEndUserInfoKey"];
        CGRect endKeyboardFrame = [endValue CGRectValue];
        CGFloat endKeyBoardY =endKeyboardFrame.origin.y;
        
        // 键盘弹出前的Y值
        NSDictionary *beginUserInfo = noti.userInfo;
        NSValue *beginValue = beginUserInfo[@"UIKeyboardFrameBeginUserInfoKey"];
        CGRect beginKeyBoardFrame = [beginValue CGRectValue];
        CGFloat beginKeyBoardY = beginKeyBoardFrame.origin.y;
        
        // 求得最下面的子控件的最大Y值，即 最大Y值 = Y + height
        for (UIView *subView in self.view.subviews) {
            subViewY = subView.frame.origin.y + subView.frame.size.height;
            
            if (maxY < subViewY) {
                maxY = subViewY;
            }
        }

        // 不需要移动子控件，直接返回
        if (maxY <= endKeyBoardY) {
            _changeY = 0;
            return;
        }

        // 求得移动的距离
        CGFloat changeY = beginKeyBoardY - endKeyBoardY;
        _changeY = changeY;
        
        for (UIView *subView in self.view.subviews) {
            
            [UIView animateWithDuration:0.25 animations:^{
                CGRect tempFrame = subView.frame;
                tempFrame.origin.y = tempFrame.origin.y - changeY;
                subView.frame = tempFrame;
            }];
            
        }
//        _isChangeY = YES;
    } else { // 键盘退出
        if (!_changeY) {
            return;
        }
        for (UIView *subView in self.view.subviews) {
            [UIView animateWithDuration:0.25 animations:^{
                CGRect tempFrame = subView.frame;
                tempFrame.origin.y = tempFrame.origin.y + _changeY;
                subView.frame = tempFrame;
            }];
        }
    }
}

// 要想touchs方法被调用，一定要给控制器的view设置背景颜色
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchsBegan");
    [self.view endEditing:YES];
}

@end
