//
//  PhotoEditingViewController.m
//  extension
//
//  Created by Mauro Vime Castillo on 13/10/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "MVAPhotoEditingViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "UIImage+ImageEffects.h"
#import "MVAData.h"
#import "EFCircularSlider.h"

@interface MVAPhotoEditingViewController ()  <PHContentEditingController>

@property (nonatomic, weak) IBOutlet UIImageView *filterPreviewView;
@property (nonatomic, strong) UIImage *inputImage;
@property (nonatomic, strong) PHContentEditingInput *contentEditingInput;
@property UIScrollView *scrollView;
@property NSMutableArray *buttons;
@property UIButton *selectedButton;
@property NSArray *tints;
@property NSArray *maximos;
@property NSArray *status;
@property NSArray *nombres;
@property MVAData *data;
@property EFCircularSlider *circularSlider;
@property UILabel *porc;
@property BOOL change;
@property (nonatomic, strong) CIContext *ciContext;
@property UIImageView *background;
@property int apeared;

@end

@implementation MVAPhotoEditingViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createArrays];
    self.apeared = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.change = NO;
    
    if (!self.data) {
        self.data = [[MVAData alloc] init];
        self.data.radius = 0.5;
        self.data.max = 27;
        self.data.tintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0];
        self.data.tintIndex = 0;
    }
    else {
        self.data.tintColor = [self.tints objectAtIndex:self.data.tintIndex];
    }
    
    // Update image
    UIImage *imagen = [self.inputImage applyBlurWithRadius:(self.data.radius * self.data.max) tintColor:self.data.tintColor saturationDeltaFactor:1.8 maskImage:nil];
    self.filterPreviewView.image = imagen;
    CGFloat y1 = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    y1 = 38;
    [self.filterPreviewView setFrame:CGRectMake(8, y1, self.view.frame.size.width - 16, self.view.frame.size.height - (y1 + 8))];
    CGRect frame = [self getFrameSizeForImage:imagen inImageView:self.filterPreviewView];
    
    CGRect imageViewFrame = CGRectMake(self.filterPreviewView.frame.origin.x + frame.origin.x, self.filterPreviewView.frame.origin.y + frame.origin.y, frame.size.width, frame.size.height);
 
    UIImageView *resized = [[UIImageView alloc] initWithFrame:imageViewFrame];
    resized.contentMode = UIViewContentModeScaleAspectFit;
    resized.image = imagen;
    resized.layer.cornerRadius = 5.0f;
    resized.layer.borderWidth = 1.0f;
    resized.layer.borderColor = [[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f] CGColor];
    [resized setClipsToBounds:YES];
    [self.filterPreviewView removeFromSuperview];
    self.filterPreviewView = resized;
    [self.view addSubview:self.filterPreviewView];
    
    self.background = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.background setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *back = [UIImage imageNamed:@"fondoFiltros"];
    self.background .image = back;
    [self.view addSubview:self.background];
    [self.view sendSubviewToBack:self.background];
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
    self.porc.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    [self.view addSubview:self.porc];
    [self setSlider];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.view bringSubviewToFront:self.circularSlider];
    [self createScrollMenuWithSize:self.view.frame.size];
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
    self.apeared = YES;
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
    self.nombres = @[@"transparente",@"blanco",@"amarillo",@"marron",@"naranja",@"rosa",@"rojo",@"violeta",@"cielo",@"azul",@"verde",@"negro"];
}

- (void)createScrollMenuWithSize:(CGSize) size
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, (size.height - 58), size.width, 58)];
    self.buttons = [[NSMutableArray alloc] init];
    int x = 10;
    for (int i = 0; i < 12; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, 50, 50)];
        UIColor *tint = [self.tints objectAtIndex:i];
        button.layer.borderWidth = 1.5f;
        button.layer.cornerRadius = (button.layer.frame.size.height/2.0f);
        button.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor];
        [button setClipsToBounds:YES];
        UIImage *bluredImage = [UIImage imageNamed:[self.nombres objectAtIndex:i]];
        [button setImage:bluredImage forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(buttonSel:) forControlEvents:UIControlEventTouchUpInside];
        if ([self.data.tintColor isEqual:tint]) {
            self.selectedButton = button;
            button.layer.borderColor = [[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f] CGColor];
            
        }
        [self.scrollView addSubview:button];
        [self.buttons addObject:button];
        x += 60;
    }
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    self.scrollView.contentSize = CGSizeMake((x + 10), self.scrollView.frame.size.height);
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.scrollView setAlpha:0];
    [self.view addSubview:self.scrollView];
    [UIView animateWithDuration:1
                     animations:^{
                         [self.scrollView setAlpha:1];
                     }
                     completion:^(BOOL finished){
                     }];
    
}

-(void)setSlider
{
    [self.view bringSubviewToFront:self.porc];
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

-(void)valueChanged:(EFCircularSlider*)slider
{
    self.data.radius = (slider.currentValue/self.data.max);
    self.porc.text = [[NSString stringWithFormat:@"%d",(int)(self.data.radius * 100)] stringByAppendingString:@"%"];
}

-(void)valueEnd:(EFCircularSlider*)slider
{
    self.change = YES;
    UIImage *imagen = [self.inputImage applyBlurWithRadius:(self.data.radius * self.data.max) tintColor:self.data.tintColor saturationDeltaFactor:1.8 maskImage:nil];
    self.filterPreviewView.image = imagen;
}

- (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView {
    
    float hfactor = image.size.width / imageView.frame.size.width;
    float vfactor = image.size.height / imageView.frame.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (imageView.frame.size.width - newWidth) / 2;
    float topOffset = (imageView.frame.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}


-(void)updateButtons:(UIButton *)boton
{
    self.selectedButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    boton.layer.borderColor = [[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f] CGColor];
    self.selectedButton = boton;
}

- (void)viewDidLayoutSubviews
{
    self.apeared += 1;
    if (self.apeared > 2) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        self.scrollView.frame = CGRectMake(0, (size.height - 58), size.width, 58);
        CGFloat w = size.width;
        float x = (w / 2.0f);
        x -= 50;
        CGFloat h = size.height;
        float y = (h / 2.0f);
        y -= 50;
        [self.porc setFrame:CGRectMake(x, y, 100, 100)];
        [self.background setFrame:CGRectMake(0, 0, size.width, size.height)];
        CGFloat y1 = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
        y1 = 38;
        [self.filterPreviewView setFrame:CGRectMake(8, y1, size.width - 16, size.height - (y1 + 8))];
        CGRect frame = [self getFrameSizeForImage:self.inputImage inImageView:self.filterPreviewView];
        
        CGRect imageViewFrame = CGRectMake(self.filterPreviewView.frame.origin.x + frame.origin.x, self.filterPreviewView.frame.origin.y + frame.origin.y, frame.size.width, frame.size.height);
        [self.filterPreviewView setFrame:imageViewFrame];
        self.filterPreviewView.layer.cornerRadius = 5.0f;
        self.filterPreviewView.layer.borderWidth = 1.0f;
        self.filterPreviewView.layer.borderColor = [[UIColor colorWithRed:(123.0f/255.0f) green:(168.0f/255.0f) blue:(235.0f/255.0f) alpha:1.0f] CGColor];
        [self.filterPreviewView setClipsToBounds:YES];
        [self.circularSlider setFrame:CGRectMake(x, y, 100, 100)];
        [self.view bringSubviewToFront:self.circularSlider];
    }
}

#pragma mark - PHContentEditingController

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData
{
    BOOL result = [adjustmentData.formatIdentifier isEqualToString:@"app.bestblur.com.extension"];
    result &= [adjustmentData.formatVersion isEqualToString:@"1.0"];
    return result;
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage
{
    self.contentEditingInput = contentEditingInput;
    
    // Load input image
    switch (self.contentEditingInput.mediaType) {
        case PHAssetMediaTypeImage:
            self.inputImage  =
            [UIImage imageWithCGImage:[self.contentEditingInput.displaySizeImage CGImage]
                                scale:1.0
                          orientation: UIImageOrientationUp];
            break;
            
        default:
            break;
    }
    
    // Load adjustment data, if any
    @try {
        PHAdjustmentData *adjustmentData = self.contentEditingInput.adjustmentData;
        if (adjustmentData) {
            self.data = [NSKeyedUnarchiver unarchiveObjectWithData:adjustmentData.data];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception decoding adjustment data: %@", exception);
    }
}

- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler
{
    PHContentEditingOutput *contentEditingOutput = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.contentEditingInput];
    
    // Adjustment data
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:self.data];
    PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:@"app.bestblur.com.extension" formatVersion:@"1.0" data:archivedData];
    contentEditingOutput.adjustmentData = adjustmentData;
    
    switch (self.contentEditingInput.mediaType) {
        case PHAssetMediaTypeImage: {
            // Get full size image
            NSURL *url = self.contentEditingInput.fullSizeImageURL;
            
            // Generate rendered JPEG data
            UIImage *image = [UIImage imageWithContentsOfFile:url.path];
            image = [self.inputImage applyBlurWithRadius:(self.data.radius * self.data.max) tintColor:self.data.tintColor saturationDeltaFactor:1.8 maskImage:nil];
            NSData *renderedJPEGData = UIImageJPEGRepresentation(image, 0.9f);
            
            // Save JPEG data
            NSError *error = nil;
            BOOL success = [renderedJPEGData writeToURL:contentEditingOutput.renderedContentURL options:NSDataWritingAtomic error:&error];
            if (success) {
                completionHandler(contentEditingOutput);
            } else {
                NSLog(@"An error occured: %@", error);
                completionHandler(nil);
            }
            break;
        }
            
        default:
            break;
    }
}

-(BOOL)shouldShowCancelConfirmation
{
    return self.change;
}

- (void)cancelContentEditing
{
    // Handle cancellation
}

#pragma mark - Image Filtering

- (IBAction)buttonSel:(id)sender
{
    self.change = YES;
    UIButton *boton = (UIButton *)sender;
    self.data.tintColor = [self.tints objectAtIndex:boton.tag];
    self.data.tintIndex = (int)boton.tag;
    NSNumber *num = (NSNumber *)[self.maximos objectAtIndex:boton.tag];
    self.data.max = [num floatValue];
    [self.circularSlider setMaximumValue:self.data.max];
    [self.circularSlider setCurrentValue:(self.data.radius * self.data.max)];
    [self updateButtons:boton];
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(imageTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)imageTimer:(NSTimer *)timer
{
    UIImage *imagen = [self.inputImage applyBlurWithRadius:(self.data.radius * self.data.max) tintColor:self.data.tintColor saturationDeltaFactor:1.8 maskImage:nil];
    self.filterPreviewView.image = imagen;
}

@end