//
//  ViewController.h
//  WKDemo2
//
//  Created by Eric.P on 28/1/16.
//  Copyright © 2016 Eric.P. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController<WKNavigationDelegate,WKUIDelegate>

@property(nonatomic, retain) WKWebView *webview;

@end

