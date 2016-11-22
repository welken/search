//
//  ViewController.m
//  CitySearchDemo
//
//  Created by 张峻鸣 on 2016/11/22.
//  Copyright © 2016年 张峻鸣. All rights reserved.
//

#import "ViewController.h"
#import "CityModel.h"
#import "ChineseString.h"
#import "MJExtension.h"

@interface ViewController ()<UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating>

/** dataSource */
@property (nonatomic,strong) NSMutableArray <NSArray *> *dataSource;
/** titleArr */
@property (nonatomic,strong) NSMutableArray <NSString *> *titleArr;
/** tableView */
@property (nonatomic,strong) UITableView *tableView;
/** search data */
@property (strong,nonatomic) NSMutableArray  *searchList;
/** 搜索控制器 */
@property (nonatomic, strong) UISearchController *searchController;

@end

static NSString * const CityCellReuseID = @"CityCellReuseID";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"城市列表";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    //    去除空 cell
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    [self networkRequest];
    
}



- (void)networkRequest{
    
    NSArray *cityListArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CityList.plist" ofType:nil]];
    
    NSLog(@"%@",cityListArr);
    
    NSMutableArray *nameArr = [[NSMutableArray alloc] initWithCapacity:cityListArr.count];
    for (NSDictionary *dict in cityListArr) {
        [nameArr addObject:dict[@"associationName"]];
    }
    
    NSArray *membersModelArr = [[CityModel mj_objectArrayWithKeyValuesArray:cityListArr] copy];
    
    NSArray *sortNameArr = [ChineseString LetterSortArray:nameArr];
    
    NSMutableArray <NSArray *> *sortObjArr = [[NSMutableArray alloc] initWithCapacity:sortNameArr.count];
    for (NSArray *arr in sortNameArr) {
        //集合去重
        NSMutableSet *section = [[NSMutableSet alloc] initWithCapacity:arr.count];
        for (NSString *str in arr) {
            for (CityModel *model in membersModelArr) {
                if ([str isEqualToString:model.associationName]) {
                    [section addObject:model];
                }
            }
        }
        NSArray *deduplicationArr = [[NSArray alloc] initWithArray:[section allObjects]];
        [sortObjArr addObject:deduplicationArr];
    }
    
    
    [self.dataSource addObjectsFromArray:[sortObjArr copy]];
    [self.titleArr addObjectsFromArray:[ChineseString IndexArray:nameArr]];
    
    [self.tableView reloadData];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.searchController.active = NO;
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchController.active) {
        return 1;
    }
    return self.titleArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return [self.searchList count];
    }
    
    NSInteger count = [self.dataSource objectAtIndex:section].count;
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CityCellReuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CityCellReuseID];
    }
    
    if (self.searchController.active) {
        CityModel *model = self.searchList[indexPath.row];
        [cell.textLabel setText:model.associationName];
        return cell;
    }
    CityModel *model = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell.textLabel setText:model.associationName];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return nil;
    }
    UILabel *lab = [UILabel new];
    lab.backgroundColor = [UIColor groupTableViewBackgroundColor];
    lab.text = [NSString stringWithFormat:@"   %@",[self.titleArr objectAtIndex:section]];
    lab.textColor = [UIColor grayColor];
    lab.font = [UIFont systemFontOfSize:15];
    return lab;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.searchController.active) {
        return 0.1;
    }
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CityModel *model;
    
    if (self.searchController.active) {
        model = self.searchList[indexPath.row];
        
    }else{
        model = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    self.searchController.active = NO;
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@", model.associationName] delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
    
    
    
}


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [self.searchController.searchBar text];
    
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"associationName CONTAINS %@", searchString];
    NSMutableArray *modelArr = [NSMutableArray array];
    for (NSArray *arr in self.dataSource) {
        for (CityModel *model in arr) {
            [modelArr addObject:model];
        }
    }
    if (self.searchList!= nil) {
        [self.searchList removeAllObjects];
    }
    
    //过滤数据
    self.searchList = [NSMutableArray arrayWithArray:[modelArr filteredArrayUsingPredicate:preicate]];
    //刷新表格
    
    [self.tableView reloadData];
}


- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (NSMutableArray *)titleArr{
    if (!_titleArr) {
        _titleArr = [NSMutableArray array];
    }
    return _titleArr;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        _tableView.tableHeaderView.frame = rect;
        _tableView.tableHeaderView = self.searchController.searchBar;
 
    }
    return _tableView;
}
- (UISearchController *)searchController{
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        
        _searchController.searchResultsUpdater = self;
        
        _searchController.dimsBackgroundDuringPresentation = NO;
        
        _searchController.searchBar.placeholder=@"搜索";
        _searchController.searchBar.tintColor = [UIColor whiteColor];
        
        _searchController.definesPresentationContext = YES;
        
        _searchController.hidesNavigationBarDuringPresentation = NO;
        
    }
    return _searchController;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    

}


@end
