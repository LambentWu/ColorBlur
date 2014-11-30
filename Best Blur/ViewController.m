//
//  ViewController.m
//  Best Blur
//
//  Created by Mauro Vime Castillo on 11/10/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ImageEffects.h"
#import "EFCircularSlider.h"
#import "MVAData.h"
#import "MBProgressHUD.h"

@interface ViewController () <MBProgressHUDDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property UILabel *porc;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property UIImage *croped;
@property UIImage *resized;
@property EFCircularSlider* circularSlider;
@property MVAData *data;
@property MBProgressHUD *hud;
@property UIScrollView *scrollView;
@property UIScrollView *imageScrollView;
@property NSMutableArray *buttons;
@property NSArray *tints;
@property NSArray *maximos;
@property NSArray *status;
@property CGFloat pond;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createArrays];
    self.porc = [[UILabel alloc] init];
    self.porc.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:30];
    [self.porc setTextAlignment:NSTextAlignmentCenter];
    self.porc.textColor = [UIColor blackColor];
    CGFloat w = self.view.frame.size.width;
    float x = (w / 2.0f);
    x -= 50;
    CGFloat h = self.view.frame.size.height;
    float y = (h / 2.0f);
    y -= 50;
    [self.porc setFrame:CGRectMake(x, y, 100, 100)];
    self.porc.layer.cornerRadius = 50.0f;
    [self.porc setClipsToBounds:YES];
    self.porc.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5],
    
    [self.view addSubview:self.porc];
    [self load];
    [self setImage];
    [self createScrollMenu];
    [self updateButtons];
    [self setSlider];
    [self setNeedsStatusBarAppearanceUpdate];
    self.saveButton.layer.cornerRadius = 5.0f;
    self.loadButton.layer.cornerRadius = 5.0f;
    [self createScrollImage];
}

-(void)viewDidAppear:(BOOL)animated
{
    CGFloat x = (self.data.tintIndex * 60) + 10;
    x += 30;
    x -= (self.scrollView.frame.size.width/2.0f);
    if (x > (self.scrollView.contentSize.width - self.scrollView.frame.size.width)) {
        x = (self.scrollView.contentSize.width - self.scrollView.frame.size.width);
    }
    else if (x < 0) {
        x = 0;
    }
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(262,262, 500, 500)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:150];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.textColor = [UIColor blackColor];
    label.layer.cornerRadius = 250.0f;
    [label setClipsToBounds:YES];
    label.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    label.text = @"50%";
    [v addSubview:label];
    EFCircularSlider *circular = [[EFCircularSlider alloc] initWithFrame:CGRectMake(262,262, 500, 500)];
    [circular setClipsToBounds:YES];
    [circular setMinimumValue:0];
    [circular setMaximumValue:100];
    [circular setCurrentValue:50];
    [circular setUnfilledColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
    [circular setLineWidth:39];
    [circular setHandleColor:[UIColor colorWithWhite:1 alpha:1]];
    [circular setFilledColor:[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:0.5f]];
    [circular setHandleType:CircularSliderHandleTypeSemiTransparentBlackCircle];
    [v addSubview:circular];
    UIView *back = [[UIImageView alloc] initWithFrame:v.frame];
    back.backgroundColor = [UIColor blackColor];
    [v addSubview:back];
    [v sendSubviewToBack:back];
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)createArrays
{
    UIColor *naranja = [UIColor orangeColor];
    naranja = [naranja colorWithAlphaComponent:0.5];
    
    UIColor *purple = [UIColor purpleColor];
    purple = [purple colorWithAlphaComponent:0.5];
    
    UIColor *brown = [UIColor brownColor];
    brown = [brown colorWithAlphaComponent:0.5];
    
    self.tints = @[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0],
                   [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:0.6],
                   [UIColor colorWithRed:(237.0f/255.0f) green:(193.0f/255.0f) blue:(44.0f/255.0f) alpha:0.5f],
                   brown,
                   naranja,
                   [UIColor colorWithRed:(234.0f/255.0f) green:(124.0f/255.0f) blue:(169.0f/255.0f) alpha:0.5f],
                   [UIColor colorWithRed:(199.0f/255.0f) green:(27.0f/255.0f) blue:(11.0f/255.0f) alpha:0.5f],
                   purple,
                   [UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:0.5f],
                   [UIColor colorWithRed:(11.0f/255.0f) green:(28.0f/255.0f) blue:(118.0f/255.0f) alpha:0.5f],
                   [UIColor colorWithRed:(27.0f/255.0f) green:(174.0f/255.0f) blue:(12.0f/255.0f) alpha:0.5f],
                   [UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:0.73]];
    self.maximos = @[@40,@23,@24,@24,@24,@24,@22,@24,@24,@24,@24,@27];
    self.status = @[@"DEFAULT",@"DEFAULT",@"LIGHT",@"LIGHT",@"LIGHT",@"LIGHT",@"LIGHT",@"LIGHT",@"DEFAULT",@"LIGHT",@"DEFAULT",@"LIGHT"];
}

- (void)createScrollMenu
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 58), self.view.frame.size.width, 58)];
    self.buttons = [[NSMutableArray alloc] init];
    int x = 10;
    for (int i = 0; i < 12; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, 50, 50)];
        UIColor *blackTint = [UIColor colorWithWhite:0.11 alpha:0.73];
        button.layer.borderWidth = 1.5f;
        button.layer.cornerRadius = (button.layer.frame.size.height/2.0f);
        if (i == self.data.tintIndex) button.layer.borderColor = [[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:0.5f] CGColor];
        else button.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor];
        [button setClipsToBounds:YES];
        UIImage *bluredImage = [self.croped applyBlurWithRadius:(self.data.radius * self.data.max) tintColor:blackTint saturationDeltaFactor:1.8 maskImage:nil];
        [button setImage:bluredImage forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(buttonSel:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        [self.buttons addObject:button];
        x += 60;
    }
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    self.scrollView.contentSize = CGSizeMake((x + 10), self.scrollView.frame.size.height);
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.scrollView];
}

- (void)createScrollImage
{
    if(self.imageScrollView != nil) {
        [self.imageScrollView removeFromSuperview];
    }
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.imageScrollView setShowsHorizontalScrollIndicator:NO];
    [self.imageScrollView setShowsVerticalScrollIndicator:NO];
    
    [self.background removeFromSuperview];
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.resized.size.width;
    CGFloat h = self.resized.size.height;
    [self.background setFrame:CGRectMake(x, y, w, h)];
    [self.imageScrollView addSubview:self.background];
    self.imageScrollView.contentSize = CGSizeMake(w, h);
    self.imageScrollView.backgroundColor = [UIColor clearColor];
    [self.imageScrollView setBounces:NO];
    [self.view addSubview:self.imageScrollView];
    [self.view sendSubviewToBack:self.imageScrollView];
    [self.imageScrollView setContentOffset:CGPointMake(((self.background.frame.size.width - self.view.frame.size.width)/2.0f), 0) animated:YES];
}

-(void)updateButtons
{
    for (int i = 0; i < [self.buttons count]; ++i) {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIButton *button = [self.buttons objectAtIndex:i];
            UIColor *tint = [self.tints objectAtIndex:i];
            NSNumber *num = (NSNumber *)[self.maximos objectAtIndex:i];
            float max = [num floatValue];
            UIImage *bluredImage = [self.croped applyBlurWithRadius:(self.data.radius * max) tintColor:tint saturationDeltaFactor:1.8 maskImage:nil];
            dispatch_async( dispatch_get_main_queue(), ^{
                [button setImage:bluredImage forState:UIControlStateNormal];
                if ([tint isEqual:self.data.tintColor]) button.layer.borderColor = [[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f] CGColor];
                else button.layer.borderColor = [[UIColor colorWithWhite:1 alpha:1] CGColor];
            });
        });
    }
}

-(void)load
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
    NSMutableArray* myArray = [NSKeyedUnarchiver unarchiveObjectWithFile:appFile];
    if (myArray == nil) {
        self.data = [[MVAData alloc] init];
        self.data.radius = 0.5;
        self.data.max = 40;
        self.data.tintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0];
        self.data.tintIndex = 0;
        self.data.original = [UIImage imageNamed:@"colom"];
        self.data.status = @"DEFAULT";
    }
    else {
        self.data = [myArray firstObject];
        self.data.tintColor = [self.tints objectAtIndex:self.data.tintIndex];
    }
    
    CGSize size = [self.data.original size];
    CGSize sizeView = self.view.frame.size;
    CGRect rect;
    self.pond = sizeView.height / size.height;
    rect = CGRectMake(0,0,(size.width * self.pond),sizeView.height);
    if (rect.size.width < sizeView.width) {
        self.pond = sizeView.width / size.width;
        rect = CGRectMake(0,0,sizeView.width,(size.height * self.pond));
    }
    
    UIGraphicsBeginImageContext( rect.size );
    [self.data.original drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(picture1);
    self.resized = [UIImage imageWithData:imageData];
    self.croped = [self cropImage];
    rect = CGRectMake(0,0,250,250);
    UIGraphicsBeginImageContext( rect.size );
    [self.croped drawInRect:rect];
    UIImage *picture2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData2 = UIImagePNGRepresentation(picture2);
    self.croped =[UIImage imageWithData:imageData2];
}

-(void)guardar
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
        
        NSMutableArray *myObject=[NSMutableArray array];
        [myObject addObject:self.data];
        
        [NSKeyedArchiver archiveRootObject:myObject toFile:appFile];
    });
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([self.data.status isEqual:@"LIGHT"]) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (IBAction)saveInBackground:(id)sender
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.delegate = self;
    self.hud.labelText = NSLocalizedString(@"Saving", nil);
    [self.hud setDimBackground:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(saveTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)saveTimer:(NSTimer *)timer
{
    UIImage *bluredImage = [self.resized applyBlurWithRadius:(self.data.radius * self.data.max) tintColor:self.data.tintColor saturationDeltaFactor:1.8 maskImage:nil];
    UIImageWriteToSavedPhotosAlbum(bluredImage, nil, nil, nil);
    self.hud.labelText = NSLocalizedString(@"Photo saved!", nil);
    self.hud.mode = MBProgressHUDModeText;
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(hideHUD:)
                                   userInfo:nil
                                    repeats:NO];

}

-(void)hideHUD:(NSTimer *)timer
{
        [self.hud hide:YES];
}

- (IBAction)loadFoto:(id)sender
{
    [self chooseFoto];
}

-(void)chooseFoto
{
    if (nil != NSClassFromString(@"UIAlertController")) {
        //show alertcontroller
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:NSLocalizedString(@"Choose photo", nil)
                                      message:NSLocalizedString(@"Select picture source:", nil)
                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Take a picture", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 if ([UIImagePickerController isSourceTypeAvailable:
                                      UIImagePickerControllerSourceTypeCamera] == YES){
                                     // Create image picker controller
                                     UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                     
                                     // Set source to the camera
                                     imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                                     
                                     // Delegate is self
                                     imagePicker.delegate = self;
                                     
                                     [imagePicker setShowsCameraControls:YES];
                                     // Show image picker
                                     [self presentViewController:imagePicker animated:YES completion:nil];
                                     //[self presentModalViewController:imagePicker animated:YES];
                                 }
                                 
                             }];
        [alert addAction:ok]; // add action to uialertcontroller
        
        
        UIAlertAction* ok2 = [UIAlertAction
                              actionWithTitle:NSLocalizedString(@"Choose from library", nil)
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //Do some thing here
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                                  if ([UIImagePickerController isSourceTypeAvailable:
                                       UIImagePickerControllerSourceTypePhotoLibrary] == YES){
                                      // Create image picker controller
                                      UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                      
                                      // Set source to the camera
                                      imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                                      
                                      // Delegate is self
                                      imagePicker.delegate = self;
                                      
                                      // Show image picker
                                      [self presentViewController:imagePicker animated:YES completion:nil];
                                  }
                                  
                              }];
        [alert addAction:ok2]; // add action to uialertcontroller
        
        UIAlertAction* ok4 = [UIAlertAction
                              actionWithTitle:NSLocalizedString(@"Cancel", nil)
                              style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction * action)
                              {
                                  //Do some thing here
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                              }];
        [alert addAction:ok4]; // add action to uialertcontroller
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIActionSheet *popup;
        popup = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Picture Source:", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:
                 NSLocalizedString(@"Take a picture", nil),
                 NSLocalizedString(@"Choose from library", nil),
                 nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    }
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    if ([UIImagePickerController isSourceTypeAvailable:
                         UIImagePickerControllerSourceTypeCamera] == YES){
                        // Create image picker controller
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        
                        // Set source to the camera
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                        
                        // Delegate is self
                        imagePicker.delegate = self;
                        
                        [imagePicker setShowsCameraControls:YES];
                        // Show image picker
                        [self presentViewController:imagePicker animated:YES completion:nil];
                        //[self presentModalViewController:imagePicker animated:YES];
                    }
                    break;
                case 1:
                    if ([UIImagePickerController isSourceTypeAvailable:
                         UIImagePickerControllerSourceTypePhotoLibrary] == YES){
                        // Create image picker controller
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        
                        // Set source to the camera
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                        
                        // Delegate is self
                        imagePicker.delegate = self;
                        
                        // Show image picker
                        [self presentViewController:imagePicker animated:YES completion:nil];
                        //[self presentModalViewController:imagePicker animated:YES];
                    }
                    break;
            }
            break;
        }
        default:
            break;
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.delegate = self;
    self.hud.labelText = NSLocalizedString(@"Loading", nil);
    [self.hud setDimBackground:YES];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:^{
        
        // Access the uncropped image from info dictionary
        UIImage *Bimage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        self.data.original = Bimage;
        [self guardar];
        
        CGSize size = [self.data.original size];
        CGSize sizeView = self.view.frame.size;
        CGRect rect;
        self.pond = sizeView.height / size.height;
        rect = CGRectMake(0,0,(size.width * self.pond),sizeView.height);
        if (rect.size.width < sizeView.width) {
            self.pond = sizeView.width / size.width;
            rect = CGRectMake(0,0,sizeView.width,(size.height * self.pond));
        }
        
        UIGraphicsBeginImageContext( rect.size );
        [self.data.original drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(picture1);
        self.resized =[UIImage imageWithData:imageData];
        self.croped = [self cropImage];
        rect = CGRectMake(0,0,250,250);
        UIGraphicsBeginImageContext( rect.size );
        [self.croped drawInRect:rect];
        UIImage *picture2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData2 = UIImagePNGRepresentation(picture2);
        self.croped =[UIImage imageWithData:imageData2];
        [self setImage];
        [self updateButtons];
        [self createScrollImage];
        [self.hud hide:YES];
    }];
}

-(void)setSlider
{
    float x = (self.view.frame.size.width / 2.0f);
    x -= 60;
    float y = (self.view.frame.size.height / 2.0f);
    y -= 60;
    CGRect sliderFrame = CGRectMake(x, y, 120, 120);
    self.circularSlider = [[EFCircularSlider alloc] initWithFrame:sliderFrame];
    [self.circularSlider addTarget:self action:@selector(valueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.circularSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.circularSlider setUnfilledColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
    [self.circularSlider setLineWidth:10];
    [self.circularSlider setHandleColor:[UIColor colorWithWhite:1 alpha:1]];
    [self.circularSlider setFilledColor:[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:0.5f]];
    [self.view addSubview:self.circularSlider];
    [self.circularSlider setMinimumValue:0.0f];
    [self.circularSlider setMaximumValue:self.data.max];
    [self.circularSlider setCurrentValue:(self.data.radius * self.data.max)];
    [self.circularSlider setHandleType:CircularSliderHandleTypeSemiTransparentBlackCircle];
    self.porc.text = [[NSString stringWithFormat:@"%d",(int)(self.data.radius * 100)] stringByAppendingString:@"%"];
}

-(void)setImage
{
    UIImage *imagen = [self.resized applyBlurWithRadius:(self.data.radius * self.data.max) tintColor:self.data.tintColor saturationDeltaFactor:1.8 maskImage:nil];
    self.background.contentMode  = UIViewContentModeScaleAspectFill;
    self.background.image = imagen;
    self.background.userInteractionEnabled = YES;
}

-(UIImage *)cropImage
{
    CGSize size = [self.resized size];
    float ref = size.width;
    float x = 0;
    float y = ((size.height/2.0f) - (ref/2.0f));
    if (size.height < ref) {
        ref = size.height;
        x = ((size.width/2.0f) - (ref/2.0f));
        y = 0;
    }
    CGRect rect = CGRectMake(x, y, ref, ref);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.resized CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    return img;
}

-(void)valueChanged:(EFCircularSlider*)slider
{
    self.data.radius = (slider.currentValue/self.data.max);
    self.porc.text = [[NSString stringWithFormat:@"%d",(int)(self.data.radius * 100)] stringByAppendingString:@"%"];
}

-(void)valueEnd:(EFCircularSlider*)slider
{
    [self guardar];
    [self setImage];
    [self updateButtons];
}

- (IBAction)buttonSel:(id)sender
{
    UIButton *boton = (UIButton *)sender;
    self.data.tintColor = [self.tints objectAtIndex:boton.tag];
    self.data.tintIndex = (int)boton.tag;
    [self setNeedsStatusBarAppearanceUpdate];
    NSNumber *num = (NSNumber *)[self.maximos objectAtIndex:boton.tag];
    self.data.max = [num floatValue];
    self.data.status = [self.status objectAtIndex:boton.tag];
    [self.circularSlider setMaximumValue:self.data.max];
    [self.circularSlider setCurrentValue:(self.data.radius * self.data.max)];
    [self updateButtons];
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(imageTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)imageTimer:(NSTimer *)timer
{
    [self guardar];
    UIImage *imagen = [self.resized applyBlurWithRadius:(self.data.radius * self.data.max) tintColor:self.data.tintColor saturationDeltaFactor:1.8 maskImage:nil];
    self.background.contentMode  = UIViewContentModeScaleAspectFill;
    self.background.image = imagen;
    self.background.userInteractionEnabled = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end