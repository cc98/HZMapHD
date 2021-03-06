//
//  ZGSLayersViewController.m
//  HZMapHD
//
//  Created by zjugis on 13-5-14.
//  Copyright (c) 2013年 zgis. All rights reserved.
//

#import "ZGSLayersViewController.h"
#import "ZGSLayerTableViewCell.h"
#import "ZGSSubLayersViewController.h"
#import "FolderCoverView.h"
#import "UIFolderTableView.h"

@interface ZGSLayersViewController () <UIFolderTableViewDelegate>

@property (strong, nonatomic) ZGSSubLayersViewController *subVc;
@property (strong, nonatomic) NSDictionary *currentLayer;

@end

@implementation ZGSLayersViewController

@synthesize layers = _layers;
@synthesize tableView = _tableView;
@synthesize selectedLayers = _selectedLayers;

-(NSArray *)layers {
    if (_layers == nil){
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Theme" withExtension:@"plist"];
        _layers = [NSArray arrayWithContentsOfURL:url];
    }
        
    return _layers;
}

-(NSArray *)selectedLayers {
    if (!_selectedLayers) {
        _selectedLayers = [NSMutableArray array];
    }
    
    return _selectedLayers;
}

-(void)setSelectedLayers:(NSArray *)selectedLayers {
    _selectedLayers = [NSMutableArray arrayWithArray:selectedLayers];
    [self.tableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(layerView:selected:)]) {
        [self.delegate layerView:self selected:self.selectedLayers];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.layers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"layer_cell";
    
    ZGSLayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ZGSLayerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    NSDictionary *layers = [self.layers objectAtIndex:indexPath.row];
    cell.thumb.image = [UIImage imageNamed:[[layers objectForKey:@"themeicon"] stringByAppendingString:@".png"]];
    cell.name.text = [layers objectForKey:@"themename"];
    
    if ([self checkSubLayerSelected: [layers objectForKey:@"themeid"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    NSMutableArray *subTitles = [[NSMutableArray alloc] init];
    NSArray *subLayers = [layers objectForKey:@"subtheme"];
    for (int i=0; i < MIN(4,  subLayers.count); i++) {
        [subTitles addObject:[[subLayers objectAtIndex:i] objectForKey:@"themename"]];
    }
    cell.subTitle.text = [subTitles componentsJoinedByString:@"/"];
    
    return cell;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZGSSubLayersViewController *subVc = [[ZGSSubLayersViewController alloc] init];
    NSDictionary *currentLayer = [self.layers objectAtIndex:indexPath.row];
    subVc.subLayers = [currentLayer objectForKey:@"subtheme"];
    subVc.selectedLayers = self.selectedLayers;
    self.currentLayer = currentLayer;
    subVc.layersViewController = self;
    
    self.tableView.scrollEnabled = NO;
    UIFolderTableView *folderTableView = (UIFolderTableView *)tableView;
    [folderTableView openFolderAtIndexPath:indexPath WithContentView:subVc.view
                                 openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                     // opening action
                                 }
                                closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                    // closing actions
                                }
                           completionBlock:^{
                               // completed actions
                               self.tableView.scrollEnabled = YES;
                           }];
    
}

-(CGFloat)tableView:(UIFolderTableView *)tableView xForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(void)subLayerBtnAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [((NSMutableArray *)self.selectedLayers) addObject: [NSNumber numberWithInt:btn.tag]];
    }else {
        NSNumber *willRemove = [self themeWithCode: btn.tag];
        [((NSMutableArray *)self.selectedLayers) removeObject: willRemove];
    }
}

-(NSNumber *) themeWithCode:(int)value{
    NSArray *filteredUsers = [self.selectedLayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"intValue == %d", value]];
	return (filteredUsers.count > 0) ? [filteredUsers lastObject] : nil;
}

- (BOOL)checkSubLayerSelected:(NSString *)code {
    NSArray *filteredUsers = [self.selectedLayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"stringValue BEGINSWITH[cd] %@", code]];
    return filteredUsers.count > 0;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"showDownloader"]) {
        UINavigationController *navigation = [segue destinationViewController];
        ZGSDownloadLayersViewController *downloader = [navigation.childViewControllers objectAtIndex:0];
        downloader.delegate = self;
    }
}

-(void)downloader:(ZGSDownloadLayersViewController *)downloader closeWithAnimated:(BOOL)animated
{
    //[downloader dismissViewControllerAnimated:YES completion:nil];
    [self dismissModalViewControllerAnimated:YES];
}

@end
