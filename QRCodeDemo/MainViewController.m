//
//  MainViewController.m
//  UniqueProject
//
//  Created by Mars on 12-12-28.
//  Copyright (c) 2012年 Mars. All rights reserved.
//

#import "MainViewController.h"
#import "QRCodeGenerator.h"
#import "MBProgressHUD.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"首页";
        UIBarButtonItem *editerBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editerPress:)];
        self.navigationItem.rightBarButtonItem = editerBtn;
        [editerBtn release];
        
        UIBarButtonItem *scanBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanQRcodeImage:)];
        self.navigationItem.leftBarButtonItem = scanBtn;
        [scanBtn release];
    }
    return self;
}

///真机扫描二维码
-(void)scanQRcodeImage:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        ZBarReaderViewController *reader = [[ZBarReaderViewController alloc] init];
        reader.readerDelegate = self;
        
        ///真机调试时要用到Camera
        reader.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        //配置解码器
        [reader.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
        [self presentViewController:reader animated:YES completion:nil];
    }
}

///模拟器查看
-(void)editerPress:(id)sender
{
    
    ZBarReaderController * reader = [[ZBarReaderController alloc] init];
    reader.allowsEditing = YES;//是否可以对二维码图片进行编辑
    reader.readerDelegate = self;
    
    //UIImagePickerController默认sourceType就是PhotoLibrary，但ZBarReaderController继承他后把sourceType改成Camera，所以在这需要我们手动设置，否则在真机上会打开摄象头而不是相册
    reader.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//从相册中获取二维码图片
    
    [reader.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];//配置解码器
    
    [self presentViewController:reader animated:YES completion:nil];
    [reader release];

}

- (IBAction)saveQRcodeImage:(id)sender {
    
    [self.searchTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    self.qrImage.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@,%@",self.searchTextField.text,self.nameTextField.text] imageSize:self.qrImage.bounds.size.width];
    UIImageWriteToSavedPhotosAlbum(self.qrImage.image, self, @selector(image:didFinishSaving:andContextInfo:), nil);
}

#pragma mark - UIIMageViewPicker Methods

-(void)image:(UIImage *)image didFinishSaving:(NSError *)error andContextInfo:(void*)contextInfo
{
    if (error == nil) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"二维码已生成，并保存到相册";
        hud.margin = 10.0f;
        hud.yOffset = 180.0f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:3];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    for (symbol in results) {
        
        break;
    }
    
    ///取出二维码中封装的数据
    NSString *qrString = symbol.data;
    
    ///很多二维码是日本人开发，所以会用到日文编写，因此要解决乱码问题
    if ([qrString canBeConvertedToEncoding:NSShiftJISStringEncoding]) {
        NSString *newString = [NSString stringWithCString:[symbol.data cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        
        ///判断是否转码有效
        if (newString != nil) {
            qrString = newString;
        }
    }
    
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil message:qrString delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"关闭", nil];
    [alterView  show];
    [alterView release];
    
    ///获得编辑过的图片
    if (picker.allowsEditing == YES) {
        self.qrImage.image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    else {
        self.qrImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_searchTextField release];
    [_nameTextField release];
    [super dealloc];
}

@end
