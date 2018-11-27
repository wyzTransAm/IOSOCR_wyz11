//
//  DetailViewController.m
//  CustomeCamera
//
//  Created by mac on 2018/11/16.
//  Copyright © 2018 ios2chen. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@interface DetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //  self.resultArr = [[NSMutableArray alloc]init];
    self.passLabel.text = @"Pass";
    
    // NSArray *array2 = [self.resultArr sortedArrayUsingSelector:@selector(compare:)];
    
    self.FinalArr = [[NSMutableArray alloc]init];
    self.FinalArrCopy = [[NSMutableArray alloc]init];
    self.FinalCurrentArr = [[NSMutableArray alloc]init];
    self.btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 100, 50)];
    self.btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.btn.backgroundColor = [UIColor grayColor];
    [self.btn setTitle:@"请点击" forState:UIControlStateNormal]; // 正常状态
    [self.btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn];
    
    
    self.passLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, HEIGHT_wyz-100, WIDTH_wyz, 100)];
    [self.view addSubview:self.passLabel];
    self.passLabel.textColor = [UIColor redColor];
    
    
    self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, WIDTH_wyz/2,HEIGHT_wyz-120 ) style:UITableViewStylePlain];
    
    
    self.table.dataSource = self;
    
    self.table.delegate = self;
    
    [self.view addSubview:self.table];
    
    self.table2 = [[UITableView alloc]initWithFrame:CGRectMake(WIDTH_wyz/2, 50, WIDTH_wyz/2,HEIGHT_wyz-120 ) style:UITableViewStylePlain];
    self.table2.dataSource = self;
    
    self.table2.delegate = self;
    
    
    [self.view addSubview:self.table2];
    
    self.SlotArr = [[NSArray alloc] initWithObjects:@"22.0",@"18.0",@"14.0",@"10.0",@"6.0",@"2.0",@"0.0",@"4.0",@"8.0",@"12.0",@"16.0",@"20.0",@"24.0",nil];
    //显示每组的尾部
    //    for (int j =0 ;j<self.CurrentArr.count ;j++) {
    //        NSString *num = self.CurrentArr[j][0];
    //        NSString *pn =  [self.CurrentArr[j][4] componentsSeparatedByString:@" "][0];
    //        NSString *sn =  [self.CurrentArr[j][4] componentsSeparatedByString:@" "][1];
    //        NSString *ver = [self.CurrentArr[j][4] componentsSeparatedByString:@" "][2];
    //    }
    //    for (int i=self.resultArr.count-1; i>-1; i--) {
    //        NSDictionary *result = [self.resultArr objectAtIndex:i] ;
    //        NSLog(@"%@", result);
    //        NSString *title = @"识别结果";
    //        NSMutableString *message = [NSMutableString string];
    //
    //        if(result[@"words_result"]){
    //            if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
    //                [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    //                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
    //                        [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
    //                    }else{
    //                        [message appendFormat:@"%@: %@\n", key, obj];
    //                    }
    //
    //                }];
    //            }else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
    //                //默认用这个
    //                for(NSDictionary *obj in result[@"words_result"]){
    //                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
    //                        [message appendFormat:@"%@:%@\n",self.SlotArr[i], obj[@"words"]];
    //                    }else{
    //                        [message appendFormat:@"%@\n", obj];
    //                    }
    //                }
    //            }
    //
    //        }else{
    //            [message appendFormat:@"%@", result];
    //        }
    //
    //    }
    
    
    // Do any additional setup after loading the view.
}
- (void)buttonAction:(UIButton *)btn{
    HomeViewController *vc = [[HomeViewController alloc]init];
    
    [self presentViewController:vc animated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    if (section==0) {
    //       return self.CurrentArr.count;
    //    }else{
    //         return self.resultArr.count;
    //    }
    if (tableView==self.table) {
        return self.CurrentArr.count;
    }else{
        return self.resultArr.count;
    }
    
}
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView =[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)] ;
    customView.backgroundColor=[UIColor orangeColor];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    headerLabel.backgroundColor = [UIColor orangeColor];
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:15];
    headerLabel.frame = CGRectMake(0.0, 0.0, 320.0, 30.0);
    if (tableView == self.table){
        headerLabel.text=@"Current Config";
    }else{
        headerLabel.text = @"OCR Detail";
    }
    //    if (section == 0) {
    //        headerLabel.text=@"Current Config";
    //    }else if (section == 1){
    //        headerLabel.text = @"OCR Detail";
    //    }
    
    [customView addSubview:headerLabel];
    
    return customView;
}
//    if ([tableView isEqual: self.table]) {
//        // 定义cell标识  每个cell对应一个自己的标识
//        NSString *CellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",indexPath.section,indexPath.row];
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//
//        if (!cell) {
//
//            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//
//            UIView *topContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH_wyz, 90)];
//
//            UILabel *num = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 50, 15)];
//            num.text =[self.CurrentArr objectAtIndex:indexPath.row][0];
//
//            UILabel *pn = [[UILabel alloc]initWithFrame:CGRectMake(150, 10, 150, 15)];
//            pn.text = [self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][0];
//
//
//            UILabel *sn = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 100, 15)];
//            NSString *sntext =[self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][1];
//            NSString *snfinal = sntext.length==7?[sntext uppercaseString]:[[sntext substringFromIndex:1] uppercaseString];
//
//            sn.text=snfinal;
//
//
//            UILabel *ver =[[UILabel alloc]initWithFrame:CGRectMake(150, 50, 150, 15)];
//            ver.text = [self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][2];
//
//            [topContainerView addSubview:num];
//            [topContainerView addSubview:pn];
//            [topContainerView addSubview:sn];
//            [topContainerView addSubview:ver];
//            [cell.contentView addSubview:topContainerView];
//
//        }
//
//        return cell;
//    }else if([tableView isEqual: self.table2]){
//        // 定义cell标识  每个cell对应一个自己的标识
//        NSString *CellIdentifier = [NSString stringWithFormat:@"cell45%ld",indexPath.row];
//        UITableViewCell *cell = [self.table2 dequeueReusableCellWithIdentifier:CellIdentifier];
//        self.table2.dataSource = self;
//
//        self.table2.delegate = self;
//        if (!cell) {
//
//            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//
//            NSDictionary *result = [self.resultArr objectAtIndex:(self.resultArr.count-1 -indexPath.row)] ;
//            NSLog(@"%@", result);
//            NSString *title = @"识别结果";
//            NSMutableString *message = [NSMutableString string];
//
//            if(result[@"words_result"]){
//                if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
//                    [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                        if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
//                            [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
//                        }else{
//                            [message appendFormat:@"%@: %@\n", key, obj];
//                        }
//
//                    }];
//                }else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
//                    //默认用这个
//                    for(NSDictionary *obj in result[@"words_result"]){
//                        if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
//                            [message appendFormat:@"%@:%@\n",self.SlotArr[indexPath.row], obj[@"words"]];
//                        }else{
//                            [message appendFormat:@"%@\n", obj];
//                        }
//                    }
//                }
//
//            }else{
//                [message appendFormat:@"%@", result];
//            }
//            UIView *topContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH_wyz, 90)];
//
//            UILabel *num = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 500, 15)];
//            num.text =message;
//
//            [topContainerView addSubview:num];
//            [cell.contentView addSubview:topContainerView];
//        }
//        return cell;
//    }else{
//         return nil;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual: self.table]) {
        // 定义cell标识  每个cell对应一个自己的标识
        NSString *CellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",indexPath.section,indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
            NSMutableArray *arrAdd = [[NSMutableArray alloc]init];
            
            UIView *topContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH_wyz, 90)];
            
            UILabel *num = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 50, 15)];
            num.text =[self.CurrentArr objectAtIndex:indexPath.row][0];
            [arrAdd addObject:[self.CurrentArr objectAtIndex:indexPath.row][0]];
            
            UILabel *pn = [[UILabel alloc]initWithFrame:CGRectMake(150, 10, 150, 15)];
            pn.text = [self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][0];
            [arrAdd addObject:[self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][0]];
            
            UILabel *sn = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 100, 15)];
            NSString *sntext =[self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][1];
            NSString *snfinal = sntext.length==7?[sntext uppercaseString]:[[sntext substringFromIndex:1] uppercaseString];
            
            sn.text=snfinal;
            [arrAdd addObject:snfinal];
            
            UILabel *ver =[[UILabel alloc]initWithFrame:CGRectMake(150, 50, 150, 15)];
            ver.text = [[self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][2] substringToIndex:4];
            [arrAdd addObject:[[self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][2] substringToIndex:4]];
            
            [topContainerView addSubview:num];
            [topContainerView addSubview:pn];
            [topContainerView addSubview:sn];
            [topContainerView addSubview:ver];
            
            [self.FinalCurrentArr addObject:arrAdd];
            [cell.contentView addSubview:topContainerView];
            
        }
        
        return cell;
    }else{
        
        // 定义cell标识  每个cell对应一个自己的标识
        NSString *CellIdentifier = [NSString stringWithFormat:@"cell45%ld",indexPath.row];
        UITableViewCell *cell = [self.table2 dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
            NSDictionary *result = [self.resultArr objectAtIndex:indexPath.row] ;
            NSLog(@"%@", result);
            NSString *title = @"识别结果";
            NSMutableString *message = [NSMutableString string];
            
            if(result[@"words_result"]){
                if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
                    [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                            [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
                        }else{
                            [message appendFormat:@"%@: %@\n", key, obj];
                        }
                        
                    }];
                }else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
                    //默认用这个
                    for(NSDictionary *obj in result[@"words_result"]){
                        if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                            
                            [message appendFormat:@"%@\n", obj[@"words"]];
                        }else{
                            
                            [message appendFormat:@"%@\n", obj];
                        }
                    }
                }
                
            }else{
                [message appendFormat:@"%@", result];
            }
            //            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            //                [alertView show];
            //            }];
            UIView *topContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH_wyz, 90)];
            
            
            NSMutableArray *arrAdd = [[NSMutableArray alloc]init];
            
            UILabel *num = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 50, 15)];
            num.text =self.SlotArr[indexPath.row];
            
            [arrAdd addObject:self.SlotArr[indexPath.row]];
            
            NSMutableArray *temparr =[message componentsSeparatedByString:@"\n"];
            
            UILabel *pn = [[UILabel alloc]initWithFrame:CGRectMake(150, 10, 150, 15)];
            UILabel *sn = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 100, 15)];
            UILabel *ver =[[UILabel alloc]initWithFrame:CGRectMake(150, 50, 150, 15)];
            
            for (int i =0; i<temparr.count; i++) {
                
                NSString *pntemp =temparr[i];
                if ([pntemp containsString:@"CEN"]||[pntemp containsString:@"uea"]||[pntemp containsString:@"RMA"]||[pntemp containsString:@"Lean"]||[pntemp containsString:@"pass"]||[pntemp containsString:@"ssed"]) {
                    
                }else{
                    
                    if ([pntemp containsString:@"-"]) {
                        if (pntemp.length>=10) {
                            pn.text = [[pntemp uppercaseString] substringToIndex:10];
                            [arrAdd addObject:[[pntemp uppercaseString] substringToIndex:10]];
                        }
                        
                    }
                    if ([[[pntemp uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""] hasPrefix:@"C3"]){
                        sn.text = [[[pntemp uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""] substringToIndex:7];
                        [arrAdd addObject:[[[pntemp uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""] substringToIndex:7]];
                    }
                    if (pntemp.length == 9){
                        
                        ver.text =[[[pntemp uppercaseString] stringByReplacingOccurrencesOfString:@"O" withString:@"0"] substringFromIndex:pntemp.length-4];
                        [arrAdd addObject:[[[pntemp uppercaseString] stringByReplacingOccurrencesOfString:@"O" withString:@"0"] substringFromIndex:pntemp.length-4]];
                    }
                    //                    if (pntemp.length == 4){
                    //
                    //                        ver.text =[[pntemp uppercaseString] stringByReplacingOccurrencesOfString:@"O" withString:@"0"] ;
                    //                    }
                }
            }
            
            [topContainerView addSubview:num];
            [topContainerView addSubview:pn];
            [topContainerView addSubview:sn];
            [topContainerView addSubview:ver];
            
            //  [topContainerView addSubview:num];
            [cell.contentView addSubview:topContainerView];
            
            
            [self.FinalArr addObject:arrAdd];
            
            self.FinalArrCopy =[self.FinalArr mutableCopy] ;
            
            if ([self.FinalArr[indexPath.row] count]<4&&[self.FinalArr[indexPath.row] count]>1) {
                cell.backgroundColor = [UIColor redColor];
                // self.passLabel.text = @"Fail";
            }else if ([self.FinalArr[indexPath.row] count]==1){
                cell.backgroundColor = [UIColor grayColor];
                
            }
            else{
                cell.backgroundColor = [UIColor greenColor];
            }
            
            
            //   self.passLabel.text = @"Pass";
        }
        //        for (int i=(self.FinalArr.count-1); i>=0; i--) {
        //            if ([self.FinalArr[i] count]==1) {
        //                [self.FinalArr removeObjectAtIndex:i];
        //            }
        //        }
        return cell;
    }
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if(self.FinalArr.count==13){
        
        
        for (int i=(self.FinalArrCopy.count-1); i>=0; i--) {
            if ([self.FinalArrCopy[i] count]==1) {
                [self.FinalArrCopy removeObjectAtIndex:i];
            }
        }
        
        if (self.FinalArrCopy.count==self.FinalCurrentArr.count) {
            for(int i=0;i<self.FinalArrCopy.count;i++){
                if ([self.FinalArrCopy[i] count]!=4) {
                    self.passLabel.text = @"Fail";
                }else{
                    self.passLabel.text = @"Pass";
                }
            }
            //        self.set1= [NSMutableSet setWithArray:self.FinalArr];
            //        self.set2= [NSMutableSet setWithArray:self.FinalCurrentArr];
            //
            //        [self.set1 intersectSet:self.set2];
            //        if (self.set1.count<self.FinalArr.count) {
            //             self.passLabel.text = @"Fail";
            //            //两个不相等，FinalArr包含有CurrentArr没有的数据
            //        }else if(self.set1.count==self.FinalArr.count){
            //            if (self.set1.count==self.FinalCurrentArr.count) {
            //                //数据匹配
            //                self.passLabel.text = @"Pass";
            //            }else{
            //                //两个不相等，CurrentArr大于FinalArr的数据
            //                 self.passLabel.text = @"Fail";
            //            }
            //        }else{
            //            NSLog(@"算法出错了");
            //        }
        }else{
            self.passLabel.text = @"Fail";
        }
    }
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *ID = @"cell";
//    // 根据标识去缓存池找cell
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    // 不写这句直接崩掉，找不到循环引用的cell
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//
//    }
//
//    //为单元格的label设置数据
//   // cell.textLabel.text = [self.CurrentArr objectAtIndex:indexPath.row][0];
//    UIView *topContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH_wyz, 90)];
//
//    UILabel *num = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 50, 15)];
//    num.text =[self.CurrentArr objectAtIndex:indexPath.row][0];
//
//    UILabel *pn = [[UILabel alloc]initWithFrame:CGRectMake(150, 10, 150, 15)];
//    pn.text = [self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][0];
//    UILabel *sn = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 100, 15)];
//    sn.text=[self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][1];
//    UILabel *ver =[[UILabel alloc]initWithFrame:CGRectMake(150, 50, 150, 15)];
//    ver.text = [self.CurrentArr[indexPath.row][4] componentsSeparatedByString:@" "][2];
//
//    [topContainerView addSubview:num];
//    [topContainerView addSubview:pn];
//    [topContainerView addSubview:sn];
//    [topContainerView addSubview:ver];
//    [cell.contentView addSubview:topContainerView];
//
//
//
//    // 虽然我们可以在cell直接点出cell里面的控件，
//    // 其实这些点出来的控件的父控件都是cell.contentView
//
//
//
//    return cell;
//}

//显示每组的头部

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//
//    return @"对比结果";
//}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
