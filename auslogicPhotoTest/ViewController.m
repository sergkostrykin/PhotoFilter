//
//  ViewController.m
//  auslogicPhotoTest
//
//  Created by Sergiy Kostrykin on 8/8/15.
//  Copyright (c) 2015 Sergiy Kostrykin. All rights reserved.
//


#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;


@property (nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic) NSMutableArray *capturedImages;


@end



@implementation ViewController
- (IBAction)applyFilter:(UIBarButtonItem *)sender {
    if (self.imageView.image != nil) {
        [self brightnessFilter];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Choose image" message:@"Choose image first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)saveImage:(UIBarButtonItem *)sender {
    [self saveImageToFile];
}

-(void) filter
{
    CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, self.imageView.image.size.width, self.imageView.image.size.height, 8, self.imageView.image.size.width, colorSapce, kCGImageAlphaNone);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height), [self.imageView.image CGImage]);
    
    CGImageRef bwImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSapce);
    
    self.imageView.image = [UIImage imageWithCGImage:bwImage]; // This is result B/W image.
}

-(void) brightnessFilter
{
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.imageView.image];
    CIFilter *exposureAdjustmentFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
    [exposureAdjustmentFilter setDefaults];
    [exposureAdjustmentFilter setValue:inputImage forKey:@"inputImage"];
    [exposureAdjustmentFilter setValue:[NSNumber numberWithFloat:-2.5f] forKey:@"inputEV"];
    CIImage *outputImage = [exposureAdjustmentFilter valueForKey:@"outputImage"];
    CIContext *context = [CIContext contextWithOptions:nil];
    self.imageView.image = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];}

-(void)saveImageToFile
{
    
    UIImageWriteToSavedPhotosAlbum(self.imageView.image,nil,nil,nil);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.capturedImages = [[NSMutableArray alloc] init];
    
    
}




- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.imageView.isAnimating)
    {
        [self.imageView stopAnimating];
    }
    
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


#pragma mark - Toolbar actions




- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
        }
        else
        {
            self.imageView.animationImages = self.capturedImages;
            self.imageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
            self.imageView.animationRepeatCount = 0;   // Animate forever (show all photos).
            [self.imageView startAnimating];
        }
        
        [self.capturedImages removeAllObjects];
    }
    
    self.imagePickerController = nil;
}


#pragma mark - Property


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.capturedImages addObject:image];
    
    
    [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end

