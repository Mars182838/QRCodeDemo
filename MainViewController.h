//
//  MainViewController.h
//  UniqueProject
//
//  Created by Mars on 12-12-28.
//  Copyright (c) 2012年 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,ZBarReaderDelegate>

@property (nonatomic, retain) NSArray *array;


@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
- (IBAction)saveQRcodeImage:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;


@property (nonatomic, retain)IBOutlet UIImageView *qrImage;

@end
