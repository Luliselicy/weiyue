//
//  HQSearchResultView.m
//  myReader
//
//  Created by hanqiu on 15/4/9.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQSearchResultView.h"
#import <AVOSCloud/AVOSCloud.h>

@interface HQSearchResultView ()

@end

@implementation HQSearchResultView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pushOrderInfo1 = [[NSMutableDictionary alloc] init];
    pushOrderInfo1 = _pushOrderInfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchbook" forIndexPath:indexPath];
    NSDictionary *cellData = [pushOrderInfo1 objectForKey:@"showlist"][indexPath.row];

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
    return [[pushOrderInfo1 objectForKey:@"showlist"] count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = [pushOrderInfo1 objectForKey:@"showlist"][indexPath.row];
    [[NSUserDefaults standardUserDefaults] setValue:[cellData objectForKey:@"txtName"] forKey:@"txtName"];
    [self performSegueWithIdentifier:@"searchToresult" sender:nil];
}

@end
