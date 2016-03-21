//
//  WSTableViewController.m
//  键盘遮盖输入框的处理
//
//  Created by sw on 16/3/18.
//  Copyright © 2016年 sw. All rights reserved.
//

#import "WSTableViewController.h"

@interface WSTableViewController ()
/** 标记是否改变了子控件的Y值 */
@property(nonatomic,assign)BOOL isChangeY;
/** 记录子控件在Y方向改变的值 */
@property(nonatomic,assign)CGFloat changeY;
@end

@implementation WSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册键盘弹出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardDidShowNotification object:nil];
    
    // 注册键盘退出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardDidHideNotification object:nil];
    

    
}

#pragma mark - 键盘弹出
- (void)keyboardFrameDidChange:(NSNotification *)noti
{
    NSLog(@"%@",noti.userInfo);
    
    if ([noti.name isEqualToString:@"UIKeyboardDidShowNotification"]) {
        NSLog(@"keyboardDidShow...");
        
        // 键盘弹出后，所有子控件上移
        [self moveUpSubview:YES withNoti:noti];
        
    } else if ([noti.name isEqualToString:@"UIKeyboardDidHideNotification"]){
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
            CGRect tempFrame = subView.frame;
            tempFrame.origin.y = tempFrame.origin.y - changeY;
            subView.frame = tempFrame;
        }
        //        _isChangeY = YES;
    } else { // 键盘退出
        if (!_changeY) {
            return;
        }
        for (UIView *subView in self.view.subviews) {
            CGRect tempFrame = subView.frame;
            tempFrame.origin.y = tempFrame.origin.y + _changeY;
            subView.frame = tempFrame;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    }
    
    cell.textLabel.text = @"1";
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 79;
    } else {
        return 40;
    }
}

@end
