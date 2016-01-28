//
//  ViewController.m
//  WKDemo2
//
//  Created by Eric.P on 28/1/16.
//  Copyright © 2016 Eric.P. All rights reserved.
//

#import "ViewController.h"

#define URL_LOGON_PATH @"local/401/webresc/1.5.5/web/web/authentication/logon/logon.html"
#define URL_ACCESS_ALLOW @"local/401/webresc/1.5.5/"

@interface ViewController ()

@property(nonatomic) BOOL logon;

@end

@implementation ViewController

@synthesize webview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.y += 20.;
    self.logon = NO;
    self.webview = [[WKWebView alloc] initWithFrame: rect];
    [self.webview setNavigationDelegate:self];
    self.webview.UIDelegate = self;
    self.webview.scrollView.bounces = NO;
    [self.view addSubview:self.webview];
    [self loadDataToWebView];
    self.logon = NO;
    [self performSelector:@selector(setToFalseLogon) withObject:nil afterDelay:2];
}

- (void)setToFalseLogon
{
    self.logon = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Load Data To WebView

- (NSData *)loadDataFromFile:(NSString *)filePath
{
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    return htmlData;
}

- (void)setDataToWebView:(NSString *)baseUrl htmlData:(NSData *)htmlData
{
    NSRange range = [baseUrl rangeOfString:@"/"];
    if(range.location==0){
        baseUrl = [baseUrl substringFromIndex:1];
    }
    [self.webview loadData:htmlData
                  MIMEType:@"text/html"
     characterEncodingName:@"UTF-8"
                   baseURL: [NSURL URLWithString:[@"hsbchttp://" stringByAppendingString:baseUrl]]];
}

- (void)loadDataToWebView
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *logonPath = [[mainBundle bundlePath] stringByAppendingPathComponent:URL_LOGON_PATH];
    NSString *fileUrl = [@"file://" stringByAppendingString:logonPath];
    NSString *allowAccess = [@"file://" stringByAppendingString:[[mainBundle bundlePath] stringByAppendingPathComponent:URL_ACCESS_ALLOW]];
    [self.webview loadFileURL:[NSURL URLWithString:fileUrl] allowingReadAccessToURL:[NSURL URLWithString:allowAccess]];
    NSLog(@"logonPath->%@",logonPath);

}

- (void)loadFileToWebView:(NSString *) filePath
{
    static NSString *defaultPart = @"file:/";

    NSString *truepath = [filePath stringByReplacingOccurrencesOfString:defaultPart withString:@""];
    NSData *htmlData = [self loadDataFromFile:truepath];
    if(htmlData==nil){
        return;
    }
    [self.webview loadFileURL:[NSURL URLWithString:filePath] allowingReadAccessToURL:[NSURL URLWithString:filePath]];
//    [self setDataToWebView:truepath htmlData:htmlData];
    self.logon = YES;
}

- (NSDictionary *)getDictionaryFromUrl:(NSString *)urlstring
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSArray *list = [urlstring componentsSeparatedByString:@"&"];
    if(list && list.count>0){
        NSString *row;
        for(row in list){
            NSArray *rowParts = [row componentsSeparatedByString:@"="];
            if(rowParts){
                [dictionary setObject:rowParts[1] forKey:rowParts[0]];
            }
        }
    }
    return [[NSDictionary alloc] initWithDictionary:dictionary];
}

- (void)handleBridge:(NSURL *)urlObj
{
    NSLog(@"handleBridge->start");
    NSString *urlString = [[urlObj absoluteString] stringByReplacingOccurrencesOfString:@"hsbc://" withString:@""];
    urlString =  urlString.stringByRemovingPercentEncoding;
    NSDictionary *parmDic = [self getDictionaryFromUrl:urlString];
    NSLog(@"dictionary->%@",parmDic);
    [self handleBridgeCallWithParams:parmDic];
}

- (void)handleBridgeCallWithParams:(NSDictionary *)params
{
    NSString *functionName = [params valueForKey:@"function"];
    if([functionName isEqualToString:@"GetString"]){
        [self getString:params ];
    }else{
        NSLog(@"No function");
    }
}

- (void)runScript:(NSString*)script
{
    [self.webview evaluateJavaScript:script
                   completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                                        NSLog(@"end run script");
                                    }];
}

- (void)getString:(NSDictionary *)params
{
    NSLog(@"GetString->Processing");
    NSString *m_key = [params valueForKey:@"key"];
    NSString *m_callback = [params valueForKey:@"callback"];
    m_callback = [NSString stringWithFormat:@"%@('%@');",m_callback,m_key];

    [self performSelectorOnMainThread:@selector(runScript:) withObject:m_callback waitUntilDone:NO];
    NSLog(@"GetString->end");
}

#pragma mark - WKNavigationDelegate Impl
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"ViewController.DecidePolicyForNavigationAction");
    NSLog(@"self.logon->%@",self.logon?@"YES":@"NO");
    NSURL *urlObj = [navigationAction.request URL];
    NSString *filepath = [urlObj absoluteString];
    NSLog(@"Url Loading->%@",filepath);
//    if(self.logon){
//        [self loadFileToWebView:filepath];
//        self.logon = NO;
//        [self performSelector:@selector(setToFalseLogon) withObject:nil afterDelay:2];
//    }
    //[self loadFileToWebView:filepath];
    if( [urlObj.scheme isEqualToString:@"hsbc"]){
        NSLog(@"scheme is ->%@",urlObj.scheme);
        [self handleBridge:urlObj];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"ViewController.webview:didStartProvisionalNavigation:");

}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"ViewController.didFailProvisionalNavigation");
    if(error){
        NSLog(@"Error->%@" , error);
    }
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSLog(@"ViewController.createWebViewWithConfiguration:");
    return webview;
}
// handle javascript alert panel with message
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"ViewController.runJavaScriptAlertPanelWithMessage");
    NSLog(@"Message->%@",message);
    UIAlertController *uiAlert = [UIAlertController alertControllerWithTitle:@"Native Alert"
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *uiAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         //when alert completed, call completionHandler
                                                         //otherwise will get exection,
                                                         //and cannot call this at the end of method;
                                                         completionHandler();
                                                     }];
    [uiAlert addAction:uiAction];
    [self presentViewController:uiAlert animated:YES completion:^(void){

    }];

    //cannot call here, it will return the control to javascript, then the second alert will be terminated.
    //completionHandler();
}
@end
