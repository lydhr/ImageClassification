//
//  cameraViewController.m
//  helloObjC
//
//  Created by 李茵 on 15/11/16.
//  Copyright © 2015年 李茵. All rights reserved.
//

#import "cameraViewController.h"

@interface cameraViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITextView *clsfTextView;
@end

@implementation cameraViewController
- (IBAction)classifyBtnTouch:(UIButton *)sender {
    NSString * urlImg=@"http://10.148.228.84:5000/classify_upload";
    [self saveImageToServer:urlImg];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"camera view controller on load");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)saveImageToServer:(NSString *)url{
    // COnvert Image to NSData
    NSData *dataImage = UIImageJPEGRepresentation(_imageView.image, 1.0f);
    
    // set your URL Where to Upload Image
    NSString * urlString=url;
    
    // set your Image Name
    NSString *filename = @"img.png";
    
    // Create 'POST' MutableRequest with Data and Other Image Attachment.
    NSMutableURLRequest* request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imagefile\"; filename=\"%@.jpg\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:dataImage]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    
    // Get Response of Your Request
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"Response  %@",responseString);
    //parse response json data
    NSError *errorJson=nil;
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&errorJson];
    NSArray* responseArray=[responseDict objectForKey:@"result"];
    for (NSObject* elements in responseArray[1]) {
        //NSLog(@"meta--- %@",elements);
    }
    for (NSObject* elements in responseArray[2]) {
        //NSLog(@"bet result--- %@",elements);
        //str=[str stringByAppendingString:@"%@",@"test"];
    }
    
    //NSLog(@"time--- %@",responseArray[3]);
    NSString * str = [self arrayTostring:responseArray[2]];
    

    [_clsfTextView setText:str];
    //view result data in table
    //[_tableView setValue:@"value" forKey:@"key"];
    //[_tableView setDelegate:self];
}
-(NSString*) arrayTostring: (NSArray*) arr{
    //NSString * str = [[arr valueForKey:@"description"] componentsJoinedByString:@""];
    NSString* str=@"";
    NSString* substr=[[NSString alloc]init];
    
    for (NSArray* elements in arr) {
        substr=[NSString stringWithFormat:@"%@    %@\n",elements[1],elements[0]];
        
        str=[str stringByAppendingString:substr];
        
        //str=[str stringByAppendingString:[arr description]];
        //str=[str stringByAppendingString:[arr description]];
    }
    return str;
}
#pragma mark - show image

- (IBAction)btnShowImage:(UIButton *)sender {
    NSLog(@"btnShowImage");
    UIImage* imgOctocat=[UIImage imageNamed:@"octocat.png"];
    [_imageView setImage:imgOctocat];
    
}

#pragma mark - invoke camera

- (IBAction)btnsysCameraOnClick:(UIButton *)sender {
    NSLog(@"btnsysCameraOnClick");
    [self addCarema];
    
}

-(void)addCarema
{
    //判断是否可以打开相机，模拟器此功能无法使用
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [picker setEditing:YES];
        [picker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera ]];
        [picker setDelegate:self];
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }else{
        //no camera, alert warning
        UIAlertController* alt=[UIAlertController alertControllerWithTitle:@"error" message:@"no rear camera" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * OK=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alt addAction:OK];
        [self presentViewController:alt animated:YES completion:nil];
        
    }
}

#pragma mark - UIImagePickerControllerDelegate 代理方法
// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}
// 当得到照片或者视频后，调用该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"Picker returned successfully.");
    //NSLog(@"%@", info);
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    //if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
    //#import <MobileCoreServices/UTCoreTypes.h>
    if ([mediaType isEqualToString: @"public.image"]){
        UIImage *theImage = nil;
        // 判断，图片是否允许修改
        if ([picker allowsEditing]){
            //获取用户编辑之后的图像
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            // 照片的元数据参数
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        [_imageView setImage:theImage];
        
        // 保存图片到相册中
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(theImage, self,selectorToCall, NULL);
        
    //}else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
    }else if ([mediaType isEqualToString:@"public.movie"]){
//        // 判断获取类型：视频
//        //获取视频文件的url
//        NSURL* mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
//        //创建ALAssetsLibrary对象并将视频保存到媒体库
//        // Assets Library 框架包是提供了在应用程序中操作图片和视频的相关功能。相当于一个桥梁，链接了应用程序和多媒体文件。
//        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//        // 将视频保存到相册中
//        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:mediaURL
//                                          completionBlock:^(NSURL *assetURL, NSError *error) {
//                                              if (!error) {
//                                                  NSLog(@"captured video saved with no error.");
//                                              }else{
//                                                  NSLog(@"error occured while saving the video:%@", error);
//                                              }
//                                          }];
//        [assetsLibrary release];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
// 当用户取消时，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"cancel");
    //[picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
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
