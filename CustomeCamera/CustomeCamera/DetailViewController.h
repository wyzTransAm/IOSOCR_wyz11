//
//  DetailViewController.h
//  CustomeCamera
//
//  Created by mac on 2018/11/16.
//  Copyright © 2018 ios2chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#define WIDTH_wyz ([UIScreen mainScreen ].bounds.size.width)
#define HEIGHT_wyz ([UIScreen mainScreen ].bounds.size.height)
NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController
@property(nonatomic,strong)NSMutableArray *CurrentArr;
@property(nonatomic,strong)NSMutableArray *resultArr;
//@property (weak, nonatomic) IBOutlet UITableView *table;
@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)UITableView *table2;
//@property (weak, nonatomic) IBOutlet UITableView *table2;
@property(nonatomic,strong)UIButton *btn;
@property(nonatomic,strong)NSArray *SlotArr;
@property(nonatomic,strong)NSMutableArray *SlotArrTwo;
@property(nonatomic,strong)NSMutableArray *FinalArr;
@property(nonatomic,strong)NSMutableArray *FinalArrCopy;
@property(nonatomic,strong)NSMutableArray *FinalCurrentArr;
@property(nonatomic,strong)UILabel *passLabel;
@property(nonatomic,strong)NSMutableSet *set1;
@property(nonatomic,strong)NSMutableSet *set2;
@end

NS_ASSUME_NONNULL_END
