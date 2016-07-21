//
//  HQBookCityView.m
//  myReader
//
//  Created by hanqiu on 15/3/23.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQBookCityView.h"
#import "HQSearchView.h"
#import <AVOSCloud/AVOSCloud.h>
#import "Reachability.h"
#import "HQHud.h"
@interface HQBookCityView ()

@end

@implementation HQBookCityView
{
    NSArray *arr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"首页",@"男生",@"女生",@"热搜"]];
    _segmentedControl.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    
    _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    
    [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.titleview addSubview:_segmentedControl];
    
    UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(gotosearch)];
    self.navigationItem.rightBarButtonItem = searchBtn;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController setNavigationBarHidden:NO];
    _segmentedControl.selectedSegmentIndex =0;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"index"];
    [self getbooks];
}

-(void)getbooks
{
    if ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable && [Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) {
        HQHud *hud = [[HQHud alloc] initWithShowString:@"网络连接异常"];
        [hud show];
    }else
    {
        [self getbooklist];
    }
}


-(void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    [[NSUserDefaults standardUserDefaults] setInteger:segmentedControl.selectedSegmentIndex forKey:@"index"];
    [self getbooks];
}
-(void)getbooklist
{
    arr = [[NSArray alloc] init];
    AVQuery *query = [AVQuery queryWithClassName:@"TxtSource"];

    query.cachePolicy = kPFCachePolicyCacheElseNetwork;

    query.maxCacheAge = 24*3600;
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"index"]) {
        case 0:
            [query whereKey:@"txtName" notEqualTo:@""];
            break;
        case 1:
            [query whereKey:@"txtCategory" equalTo:@"1"];
            break;
        case 2:
            [query whereKey:@"txtCategory" equalTo:@"2"];
            break;
        case 3:
            [query whereKey:@"hotTop" equalTo:@"1"];
            break;
        default:
            break;
    }
    
    [_indicator setHidden:NO];
    [_indicator startAnimating];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        if (!error) {
            arr = objects;
            [_indicator setHidden:YES];
            [_indicator stopAnimating];
            [_tableview reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"booklistcell" forIndexPath:indexPath];
    NSDictionary *cellData = arr[indexPath.row];
    [(UIImageView*)[cell viewWithTag:100] setImage:[UIImage imageNamed:@"orange.png"]];
    [[cellData objectForKey:@"txtImage"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [(UIImageView*)[cell viewWithTag:100] setImage:[UIImage imageWithData:data]];
    }];
    [(UILabel*)[cell viewWithTag:101] setText:[cellData objectForKey:@"txtName"]];
    [(UILabel*)[cell viewWithTag:102] setText:[cellData objectForKey:@"txtType"]];
    [(UILabel*)[cell viewWithTag:103] setText:[cellData objectForKey:@"txtDetaile"]];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arr count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = [arr[indexPath.row] objectForKey:@"localData"];
    [[NSUserDefaults standardUserDefaults] setValue:[cellData objectForKey:@"txtName"] forKey:@"txtName"];
    [self performSegueWithIdentifier:@"todetaile" sender:nil];
}

-(void)gotosearch
{
    UIStoryboard *mainStoryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HQSearchView *searchview=[mainStoryBoard instantiateViewControllerWithIdentifier:@"searchcontroller"];
    [self.navigationController pushViewController:searchview animated:YES];
}


@end
