//
//  ViewController.m
//  weiyue
//
//  Created by hanqiu on 15/5/1.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "ViewController.h"
#import "HQData.h"
#import "HQBookCell.h"
#import "HQBookHeaderView.h"
#import "HQ_ScrollViewController.h"
#import "HQDB.h"

#define kScreen_Height   ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width    ([UIScreen mainScreen].bounds.size.width)

@interface ViewController ()

@end

static long i;
@implementation ViewController
{
    UILongPressGestureRecognizer *longPress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [_collectionview addGestureRecognizer:longPress];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"edit"];
    [self getbookslist];
    [self addfootview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma makr - 其它方法
-(void)getbookslist
{
    _books = [[NSMutableArray alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"images"]];
    NSError *error = nil;
    _fileList = [[NSArray alloc] init];
    _fileList = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
    for (NSString *str in _fileList) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString *path = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@",str]];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [dic setObject:image forKey:@"image"];
        [dic setObject:str forKey:@"str"];
        [_books addObject:dic];
    }
}
-(void)addfootview
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[UIImage imageNamed:@"add.png"] forKey:@"image"];
    [dic setObject:@"" forKey:@"str"];
    [_books addObject:dic];
    [_collectionview reloadData];
}

-(void)delete
{
    if ([Reader.deletelist count]!=0) {
        
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除所选书籍及缓存文件" otherButtonTitles:nil, nil];
        actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionsheet showInView:self.view];
        
    }
}
-(void)done
{
    [_collectionview addGestureRecognizer:longPress];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"edit"];
    [Reader.deletelist removeAllObjects];
    [self addfootview];
    self.navigationItem.leftBarButtonItem.title =@"";
    self.navigationItem.leftBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem.title =@"";
    self.navigationItem.rightBarButtonItem.enabled=NO;
}
-(IBAction)longPressGestureRecognized:(id)sender
{
    UILongPressGestureRecognizer *longpress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longpress.state;
    CGPoint location = [longpress locationInView:_collectionview];
    NSIndexPath *indexpath = [_collectionview indexPathForItemAtPoint:location];
    switch (state) {
        case UIGestureRecognizerStateBegan:
            if (indexpath) {
                [self startEdit];
            }
            break;
            
        default:
            break;
    }
}

-(void)startEdit
{
    [_collectionview removeGestureRecognizer:longPress];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"edit"];
    [_books removeLastObject];
    [_collectionview reloadData];
    
    UIBarButtonItem *deleteBtn = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(delete)];
    self.navigationItem.leftBarButtonItem = deleteBtn;
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneBtn;
}

#pragma mark - uicollectionviewDatasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return ([_books count]/3+1);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section!=([_books count]/3)) {
        return 3;
    }
    else
    {
        
        return [_books count]%3;
        
    }
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    HQBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bookcell" forIndexPath:indexPath];
    cell.imageview.image = [[_books objectAtIndex:indexPath.section*3+indexPath.row] objectForKey:@"image"];
    cell.label.text = @"";
    NSString *str = [[_books objectAtIndex:indexPath.section*3+indexPath.row] objectForKey:@"str"];
    if (str && [str length]>0) {
        NSString *doc = @".";
        NSInteger location = [str rangeOfString:doc].location;
        NSString *rang = [str substringToIndex:location];
        cell.label.text = rang;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"edit"]) {
        [cell.btn setHidden:NO];
    }else
    {
        [cell.btn setHidden:YES];
    }
    [cell.btn setSelected:NO];
    return cell;
}

-( UIEdgeInsets )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:( NSInteger )section

{
    
    return UIEdgeInsetsMake ( 10 , 5 , 10 , 5 );
    
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((kScreen_Width-50)/3, ((kScreen_Width-50))/3*1.7);
}
#pragma mark - uicollectionviewdelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ((indexPath.section*3+indexPath.row) != ([_books count]-1)) {
        i=indexPath.section*3+indexPath.row;

        NSString* str = _fileList[i];
        [[NSUserDefaults standardUserDefaults] setValue:str forKey:@"txt"];
        HQ_ScrollViewController *loginvctrl = [[HQ_ScrollViewController alloc] init];
        [self presentViewController:loginvctrl animated:NO completion:nil];
    }else
    {
        [self performSegueWithIdentifier:@"tobookcity" sender:nil];
    }
    
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    HQBookHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionheader" forIndexPath:indexPath];
    return headerView;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeMake(600, 50);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"edit"]) {
        size = CGSizeMake(0, 0);
    }else if (section != 0)
    {
        size = CGSizeMake(0, 0);
    }
    return size;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    HQDB *db = [[HQDB alloc] init];
    if (buttonIndex==0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        for (NSString *str in Reader.deletelist) {
            NSString *filePath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"images"]];
            BOOL exit = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (exit) {
                NSString *filePathimage = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@.gif",str]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePathimage]) {
                    [fileManager removeItemAtPath:filePathimage error:nil];
                }
            }
            
            NSString *filePath1 = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"novels"]];
            BOOL exit1 = [[NSFileManager defaultManager] fileExistsAtPath:filePath1];
            if (exit1) {
                NSString *filePathimage1 = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"novels/%@.txt",str]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePathimage1]) {
                    [fileManager removeItemAtPath:filePathimage1 error:nil];
                }
            }
            
            [db deleteTable:str];
        }
        [self getbookslist];
        [Reader.deletelist removeAllObjects];
        [_collectionview reloadData];
    }
}


- (IBAction)editclick:(UIButton *)sender {
    [self startEdit];
}
@end
