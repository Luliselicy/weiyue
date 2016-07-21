//
//  HQSearchView.m
//  myReader
//
//  Created by hanqiu on 15/4/8.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQSearchView.h"
#import <AVOSCloud/AVOSCloud.h>
#import "HQHud.h"

@interface HQSearchView ()

@end

@implementation HQSearchView
{
    NSArray *arr;
    NSMutableArray* showListLX;
    int addIndex;
    int addRow;
    CGFloat selectValueAddWidth;
    NSMutableArray*colorArray;
    NSMutableDictionary*selectConditionDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    addIndex=0;
    addRow=1;
    [self getbooklist];
    showListLX = [[NSMutableArray alloc] init];
    [self loadColor];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 其它方法
-(void)loadColor
{
    
    UIColor*color1=[[UIColor alloc]initWithRed:250/255.0 green:146/255.0 blue:81/255.0 alpha:1];
    UIColor*color2=[[UIColor alloc]initWithRed:242/255.0 green:101/255.0 blue:71/255.0 alpha:1];
    UIColor*color3=[[UIColor alloc]initWithRed:245/255.0 green:187/255.0 blue:90/255.0 alpha:1];
    UIColor*color4=[[UIColor alloc]initWithRed:241/255.0 green:148/255.0 blue:193/255.0 alpha:1];
    UIColor*color5=[[UIColor alloc]initWithRed:79/255.0 green:211/255.0 blue:190/255.0 alpha:1];
    
    colorArray=[[NSMutableArray alloc]initWithObjects:color1,color2,color3,color4,color5,color1,color2,color3,color4,color5, nil];
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to-from + 1)));
}

-(void)gettxtstr
{
    NSMutableArray *numArr = [[NSMutableArray alloc] init];
    int i=0;
    do{
        int num = [self getRandomNumber:0 to:([arr count]-1)];
        BOOL exit =NO;
        if (numArr&&[numArr count]>0) {
            for (NSString *str in numArr) {
                if ([str isEqualToString:[NSString stringWithFormat:@"%d",num]]) {
                    exit =YES;
                }
            }
            if (!exit) {
                [numArr addObject:[NSString stringWithFormat:@"%d",num]];
                i++;
                [self setLableView:[[arr objectAtIndex:num] objectForKey:@"txtName"]];
            }
        }else
        {
            [numArr addObject:[NSString stringWithFormat:@"%d",num]];
            i++;
            [self setLableView:[[arr objectAtIndex:num] objectForKey:@"txtName"]];
        }
    }while (i<12);
    
    UIButton *freshBtn = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100)/2,[[NSUserDefaults standardUserDefaults] floatForKey:@"y"]+80, 100, 44)];
    
    [freshBtn setBackgroundColor:[UIColor clearColor]];
    [freshBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [freshBtn setTitle:@"换一批" forState:UIControlStateNormal];
    [freshBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    freshBtn.tag=addIndex-1;
    [freshBtn addTarget:self action:@selector(refreshview) forControlEvents:UIControlEventTouchUpInside];
    [self.showView addSubview:freshBtn];
}
-(void)refreshview
{
    addIndex =0;
    selectValueAddWidth =0;
    addRow =1;
    for (UIView *lview in [self.showView subviews]) {
        [lview removeFromSuperview];
    }
    [self gettxtstr];
}

-(void)setLableView:(NSString *)selectValue
{
    CGFloat marginLeft=10.0;
    CGFloat marginTop=10.0;
    addIndex++;
    CGSize size=CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-108);
    CGFloat scrollViewWidth=size.width-marginLeft*2;
    CGFloat selectValueWidth=selectValue.length*20.0+8.0;
    CGFloat selectValueHeight=30.0;
    CGFloat selectValueMarginLeft=0;
    selectValueAddWidth+=selectValueWidth+(addIndex-1)*marginLeft;
    if(selectValueAddWidth>scrollViewWidth)
    {
        selectValueMarginLeft=10.0;
        selectValueAddWidth=selectValueWidth;
        addRow++;
    }
    else
    {
        selectValueMarginLeft=selectValueAddWidth-selectValueWidth+marginLeft;
    }
    if(addRow>1)
    {
        marginTop=addRow*10.0+(addRow-1)*selectValueHeight;
    }
    else
    {
        marginTop=10.0;
    }
    selectValueAddWidth-=(addIndex-1)*marginLeft;
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(selectValueMarginLeft, marginTop+20, selectValueWidth, selectValueHeight)];
    [[NSUserDefaults standardUserDefaults] setFloat:marginTop forKey:@"y"];
    [addBtn setBackgroundColor:[UIColor whiteColor]];
    [addBtn setTitleColor:[colorArray objectAtIndex:(addIndex-1)%10] forState:UIControlStateNormal];
    [addBtn setTitle:selectValue forState:UIControlStateNormal];
    [addBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    addBtn.tag=addIndex-1;
    [selectConditionDict setObject:selectValue forKey:[NSString stringWithFormat:@"%d",addIndex-1]];
    [addBtn addTarget:self action:@selector(selectbtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.showView addSubview:addBtn];
    [_tableview setHidden:YES];
    [_showView setHidden:NO];
    
}

-(void)selectbtn:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSString *str = btn.titleLabel.text;
    for (int i=0; i<[arr count]; i++) {
        if ([[arr[i] objectForKey:@"txtName"] isEqualToString:str]) {
            NSMutableArray *arrone = [[NSMutableArray alloc] init];
            [arrone addObject:arr[i]];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [dic setObject:arr forKey:@"arrlist"];
            [dic setObject:arrone forKey:@"showlist"];
            [self performSegueWithIdentifier:@"searchresult" sender:dic];
            break;
        }
    }
}
#pragma mark -tableview
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIndentifer =@"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifer];
    }
    cell.textLabel.text = [showListLX[indexPath.row] objectForKey:@"txtName"];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [showListLX count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    NSMutableArray *arrone = [[NSMutableArray alloc] init];
    [arrone addObject:showListLX[indexPath.row]];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:arr forKey:@"arrlist"];
    [dic setObject:arrone forKey:@"showlist"];
    [self performSegueWithIdentifier:@"searchresult" sender:dic];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     id destination = segue.destinationViewController;
     [destination setValue:sender forKey:@"pushOrderInfo"];
     // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }


-(void)getbooklist
{
    arr = [[NSArray alloc] init];
    AVQuery *query = [AVQuery queryWithClassName:@"TxtSource"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 24*3600;
    [query whereKey:@"txtName" notEqualTo:@""];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        if (!error) {
            arr = objects;
            [self gettxtstr];
        }else
        {
            
        }
    }];
}

#pragma mark - searchbar
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText && searchText.length>0) {
        [_showView setHidden:YES];
        [_tableview setHidden:NO];
        if (arr && [arr count]>0) {
            showListLX = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in arr) {
                if ([[dic objectForKey:@"txtName"] rangeOfString:searchText options:NSCaseInsensitiveSearch].length>0) {
                    [showListLX addObject:dic];
                    continue;
                }else if ([[dic objectForKey:@"txtWriter"] rangeOfString:searchText options:NSCaseInsensitiveSearch].length>0)
                {
                    [showListLX addObject:dic];
                    continue;
                }
            }
            [_tableview reloadData];
        }
    }else
    {
        [_showView setHidden:NO];
        [_tableview setHidden:YES];
    }
}




- (IBAction)searchclick:(UIButton *)sender {
    if ([showListLX count] == 0) {
        [_searchBar resignFirstResponder];
        HQHud *hud = [[HQHud alloc] initWithShowString:@"服务器暂时未添加相关数据"];
        [hud show];
    }else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dic setObject:arr forKey:@"arrlist"];
        [dic setObject:showListLX forKey:@"showlist"];
        [self performSegueWithIdentifier:@"searchresult" sender:dic];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}
@end
