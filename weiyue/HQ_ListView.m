//
//  HQ_ListView.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQ_ListView.h"
#import "HQ_ReaderDataSource.h"
#import "HQ_MarkTableViewCell.h"
#import "HQDB.h"


@implementation HQ_ListView

- (id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithRed:240/255.0 green:239/255.0 blue:234/255.0 alpha:1.0];
        _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
        dataCount = [HQ_ReaderDataSource shareInstance].totalChapter;
        [self configListView];
        
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEListView:)];
        [self addGestureRecognizer:panGes];
        
    }
    return self;
}

- (void)panEListView:(UIPanGestureRecognizer *)recongnizer{
    CGPoint touchPoint = [recongnizer locationInView:self];
    switch (recongnizer.state) {
        case UIGestureRecognizerStateBegan:{
            _panStartX = touchPoint.x;
        }
            break;
            
        case UIGestureRecognizerStateChanged:{
            CGFloat offSetX = touchPoint.x - _panStartX;
            CGRect newFrame = self.frame;
            newFrame.origin.x += offSetX;
            if (newFrame.origin.x >= 0){
                
                newFrame.origin.x = 0;
                self.frame = newFrame;
                return;
            }else{
                self.frame = newFrame;
            }
            
            
        }
            
            break;
            
        case UIGestureRecognizerStateEnded:{
            
            float duringTime = (self.frame.size.width + self.frame.origin.x)/self.frame.size.width * 0.25;
            if (self.frame.origin.x < 0) {
                [UIView animateWithDuration:duringTime animations:^{
                    self.frame = CGRectMake(-self.frame.size.width , 0,  self.frame.size.width, self.frame.size.height);
                } completion:^(BOOL finished) {
                    [_delegate removeHQ_ListView];
                }];
                
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
            
            break;
            
        default:
            break;
    }
    
    
}



- (void)configListView{
    
    _isMenu = YES;
    _isMark = NO;
    _isNote = NO;
    
    [self configListViewHeader];
    
    _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.frame.size.width, self.frame.size.height - 80 - 60)];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.backgroundColor = [UIColor clearColor];
    [self addSubview:_listView];
    
}

- (void)deleteAllmark{
    HQDB *db = [[HQDB alloc] init];
    [db deleteTable:[HQ_ReaderDataSource shareInstance].txtName];
}

- (void)configListViewHeader{
    
    NSArray *segmentedArray = @[@"目录",@"书签"];
    _segmentControl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
    _segmentControl.frame = CGRectMake(15, 30, self.bounds.size.width - 30 , 40);
    _segmentControl.selectedSegmentIndex = 0;
    _segmentControl.tintColor = [UIColor colorWithRed:233/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
    [self addSubview:_segmentControl];
    [_segmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:17] forKey:NSFontAttributeName];
    [_segmentControl setTitleTextAttributes:dict forState:0];
    
}

- (void)segmentAction:(UISegmentedControl *)sender{
    
    NSInteger index = sender.selectedSegmentIndex;
    switch (index) {
        case 0:{
            _isMenu = YES;
            _isMark = NO;
            _isNote = NO;
            dataCount = [HQ_ReaderDataSource shareInstance].totalChapter;
            [_listView reloadData];
        }
            break;
        case 1:{
            _isMenu = NO;
            _isMark = YES;
            _isNote = NO;
            _dataSource = [HQ_CommonManager Manager_getMark];
            [_listView reloadData];
        }
            break;
            
        default:
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isMark) {
        return 100;
    }
    
    return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_isMark) {
        return _dataSource.count;
    }
    return dataCount;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isMark) {
        [_delegate clickMark:[_dataSource objectAtIndex:indexPath.row]];
        return;
    }
    
    [_delegate clickChapter:indexPath.row];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isMenu == YES) {
        static NSString *cellStr = @"menuCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = [NSString stringWithFormat:@"第%d章",indexPath.row + 1];
        return cell;
        
    }else if(_isMark){
        
        static NSString *cellStr = @"markCell";
        HQ_MarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
        if (cell == nil) {
            cell = [[HQ_MarkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.chapterLbl.text = [NSString stringWithFormat:@"第%@章",[(HQ_Mark *)[_dataSource objectAtIndex:indexPath.row] markChapter]];
        cell.timeLbl.text    = [(HQ_Mark *)[_dataSource objectAtIndex:indexPath.row] markTime];
        cell.contentLbl.text = [(HQ_Mark *)[_dataSource objectAtIndex:indexPath.row] markContent];
        return cell;
        
    }else{
        static NSString *cellStr = @"noteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = [NSString stringWithFormat:@"第%d章",indexPath.row + 1];
        return cell;
        
    }
    return nil;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
