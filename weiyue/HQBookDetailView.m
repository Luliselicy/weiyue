//
//  HQBookDetailView.m
//  myReader
//
//  Created by hanqiu on 15/3/23.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQBookDetailView.h"
#import "HQ_ScrollViewController.h"
#import <AVOSCloud/AVOSCloud.h>
@interface HQBookDetailView ()

@end

@implementation HQBookDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initview];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initview
{
    _books = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"novels"]];
    NSError *error = nil;
    _fileList = [[NSArray alloc] init];
    _fileList = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
    for (NSString *str in _fileList) {
        
        if ([str isEqualToString:[NSString stringWithFormat:@"%@.txt",[[NSUserDefaults standardUserDefaults] valueForKey:@"txtName"]]]) {
            [_btnshow setTitle:@"已下载" forState:UIControlStateNormal];
            [_btnshow setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            break;
        }
        
    }
    
    
    AVQuery *query = [AVQuery queryWithClassName:@"TxtSource"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 24*3600;
    [query whereKey:@"txtName" equalTo:[[NSUserDefaults standardUserDefaults] valueForKey:@"txtName"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        if (!error) {
            AVObject *object = [objects firstObject];
            [_txtImage setImage:[UIImage imageWithData:[[object objectForKey:@"txtImage"] getData]]];
            [_txtName setText:[object objectForKey:@"txtName"]];
            [_txtType setText:[object objectForKey:@"txtType"]];
            [_txtWriter setText:[object objectForKey:@"txtWriter"]];
            [_txtdetail setText:[object objectForKey:@"txtDetaile"]];
        }else
        {
            
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}



-(void)write:(NSData*)data andName:(NSString*)name
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory ,NSUserDomainMask,YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *testDirectory = [documentDirectory stringByAppendingPathComponent:@"novels"];
    
    
    [fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    
    
    NSString *test11 = [testDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",name]];
    
    
    BOOL success = [fileManager createFileAtPath:test11 contents:data attributes:nil];
    if (success) {
    }else
    {
    }
    
    NSArray *files = [fileManager subpathsAtPath:documentDirectory];
}

-(void)writeImage:(NSData*)data andName:(NSString*)name
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory ,NSUserDomainMask,YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *testDirectory = [documentDirectory stringByAppendingPathComponent:@"images"];
    
    
    [fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    
    
    NSString *test11 = [testDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",name]];
    
    
    BOOL success = [UIImagePNGRepresentation([UIImage imageWithData:data]) writeToFile:test11 atomically:YES];
    if (success) {
    }else
    {
    }
    
    NSArray *files = [fileManager subpathsAtPath:documentDirectory];
    
}

- (IBAction)download:(UIButton *)sender {
    if ([_btnshow.titleLabel.text isEqualToString:@"点击下载"]) {
        [_btnshow setTitle:@"下载中" forState:UIControlStateNormal];
        AVQuery *query = [AVQuery queryWithClassName:@"TxtSource"];
        [query whereKey:@"txtName" equalTo:[[NSUserDefaults standardUserDefaults] valueForKey:@"txtName"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
            if (!error) {
                AVObject *object = [objects firstObject];
                [[object objectForKey:@"txtFile"] getDataInBackgroundWithBlock:^(NSData *data,NSError *error){
                    [self write:data andName:[[NSUserDefaults standardUserDefaults] valueForKey:@"txtName"]];
                }progressBlock:^(NSInteger percentDone){
                    if (percentDone !=100) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _showview.frame = CGRectMake(_showview.bounds.origin.x, _showview.bounds.origin.y, (_clickview.frame.size.width*((percentDone*-1)/100))/[[object objectForKey:@"txtlength"] intValue],_showview.frame.size.height);
                        });
                    }else
                    {
                        _showview.frame = CGRectMake(_showview.bounds.origin.x, _showview.bounds.origin.y,_clickview.frame.size.width,_showview.frame.size.height);
                        [_btnshow setTitle:@"已下载" forState:UIControlStateNormal];
                        [_btnshow setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    }
                }];
                [[object objectForKey:@"txtImage"] getDataInBackgroundWithBlock:^(NSData *data,NSError* error){
                    [self writeImage:data andName:[[NSUserDefaults standardUserDefaults] valueForKey:@"txtName"]];
                }];
            }
        }];
    }
    else if([_btnshow.titleLabel.text isEqualToString:@"已下载"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@.gif",[[NSUserDefaults standardUserDefaults] valueForKey:@"txtName"]] forKey:@"txt"];
        HQ_ScrollViewController *loginvctrl = [[HQ_ScrollViewController alloc] init];
        [self presentViewController:loginvctrl animated:NO completion:nil];
    }
}
@end
