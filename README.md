# MergeVideoAndMusic
音视频合成
# 前言
---
遍历构造器又称工厂方法,可以把一个或多个控件封装到一个类中,每次创建控件只需要调用方法就可以了

本次我所说的就是封装一个根据所输入的数组进行自动创建提示框的类

# 效果图:
![这里写图片描述](http://img.blog.csdn.net/20151202152809474)
![这里写图片描述](http://img.blog.csdn.net/20151202152822475)

---
#上代码

##首先创建一个CustomAlertView的类,该类继承自NSobject

![这里写图片描述](http://img.blog.csdn.net/20151202153833787)

##然后在CustomAlertView.h中写上方法声明,因为是继承自NSobject所以要手动导入UIKit框架

```
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 代理方法
@protocol CustomAlertViewDelegate <NSObject>

// 可选执行方法
@optional
// 点击按钮下标时传递参数
- (void)didSelectAlertButton:(NSString *)title;
@end

@interface CustomAlertView : NSObject
/** 单例 */
+ (CustomAlertView *)singleClass;

/** 快速创建提示框*/
- (UIView *)quickAlertViewWithArray:(NSArray *)array;

// 代理属性
@property (assign, nonatomic)id<CustomAlertViewDelegate>delegate;

@end
```
##然后在CustomAlertView.h.m中开始实现方法
```
#import "CustomAlertView.h"

/** 二进制码转RGB */
#define UIColorFromRGBValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation CustomAlertView
/** 单例 */
+ (CustomAlertView *)singleClass{
    static CustomAlertView *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CustomAlertView alloc] init];
    });
    return manager;
}
/** 提示view */
- (UIView *)quickAlertViewWithArray:(NSArray *)array{
    CGFloat buttonH = 61;
    CGFloat buttonW = 250;

    // 通过数组长度创建view的高
    UIView *alert = [[UIView alloc] initWithFrame:CGRectMake(0, 0,buttonW, array.count * buttonH)];
    for (int i = 0; i < array.count;i++) {
        // 因为有一条分割线 所以最下面是一层view
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, i*buttonH, buttonW, buttonH)];
        view.backgroundColor = [UIColor whiteColor];
        
        // 创建button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(0, 0, buttonW, buttonH);
        [button setTitle:array[i] forState:(UIControlStateNormal)];
        // 所有button都关联一个点击方法,通过按钮上的title做区分
        [button addTarget:self action:@selector(alertAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [view addSubview:button];
        
        // 这里可以根据传值改变状态
        if ([array[i] isEqualToString:@"取消"]) {
            button.tintColor = [UIColor whiteColor];
            // 绿色背景
            view.backgroundColor = UIColorFromRGBValue(0x82DFB0);
        }else{
            button.tintColor = UIColorFromRGBValue(0x333333);
            // 分割线
            // 如果不是最后一行
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, buttonW, 1)];
            lineView.backgroundColor = UIColorFromRGBValue(0xefefef);
            [view addSubview:lineView];
        }
        [alert addSubview:view];
    }
    return alert;
}
/** button点击事件,通知代理执行代理方法 */
- (void)alertAction:(UIButton *)button{
    [_delegate didSelectAlertButton:button.titleLabel.text];
}
@end
```

##ViewController中调用
```
#import "ViewController.h"
#import "CustomAlertView.h"

@interface ViewController ()<CustomAlertViewDelegate>
/** 提示框 */
@property (strong, nonatomic) UIView *alertView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor lightGrayColor];
    // 将提示页面加入到view上
    [self.view addSubview:self.alertView];
}

// 这个是stroyBoard里创建的button
- (IBAction)alertAction:(UIButton *)sender {
    // UIView动画
    [UIView animateWithDuration:0.1 animations:^{
        self.alertView.alpha = 1;
        self.alertView.hidden = NO;
    }];
}

/** 提示框懒加载 */
- (UIView *)alertView{
    if (!_alertView) {
        // 这里还可以把alerView创建到一个蒙版上,直接进行操作蒙版的透明度隐藏来展示动画,也可以避免点击框外的其他控件,就不在这里细写了
        // 赋值
        _alertView = [[CustomAlertView singleClass]
                      // 传入数组
                      quickAlertViewWithArray:@[@"确定",@"测试A",@"测试B",@"取消"]
                      ];
        
        // 设定中心,如果需要适配请layoutIfNeed
        _alertView.center = self.view.center;
        // 切圆角
        _alertView.layer.masksToBounds = YES;
        _alertView.layer.cornerRadius = 10;
        // 初始状态为隐藏,透明度为0
        _alertView.hidden = YES;
        _alertView.alpha = 0.0;
        // 设置代理
        [CustomAlertView singleClass].delegate = self;
    }
    return _alertView;
}

// 代理方法传值
- (void)didSelectAlertButton:(NSString *)title{
    [UIView animateWithDuration:0.1 animations:^{
        self.alertView.alpha = 0;
    } completion:^(BOOL finished) {
        // 如果直接在动画里隐藏不会出现动画效果,所以要在动画结束之后进行隐藏
        self.alertView.hidden = YES;
    }];
    NSLog(@"%@",title);
}

@end
```

##来张效果图
![这里写图片描述](http://img.blog.csdn.net/20151202171648644)

##以上就是本功能的全部代码

##GitHub:https://github.com/Lafree317/customAlertView



---
本人还是一只小菜鸡,不过是一只热心肠的菜鸡,如果有需要帮助或者代码中有更好的建议的话可以发邮件到lafree317@163.com中,我们一起进步XD


