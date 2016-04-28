//
//  CollectionViewController.m
//  PairadeDemo
//
//  Created by Josh Wright on 4/19/16.
//  Copyright © 2016 Pairade. All rights reserved.
//

#import "CollectionViewController.h"
#import "IconCollectionViewCell.h"
#import "IconFlowLayout.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CollectionViewController ()

@end

@implementation CollectionViewController {
    
    // Used to store the signals of the loading images so they can be bound to a UICollectionViewCell
    NSMutableArray<RACSignal *> *imageSignals;
    
    // A dictionary for caching the loaded images
    NSMutableDictionary<NSString *, UIImage *> *cache;
    
    // List of all the image URLs
    NSArray *imageURLs;
}

static NSString * const reuseIdentifier = @"IconCell";

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Mode: Single";
    
    [self initializeVariables];
    
    // Begin loading all images asynchronously
    for (NSString *imagePath in imageURLs) {
        RACSignal *signal = [self loadFromURLString:imagePath];
        [imageSignals addObject:signal];
        
        // So that all images being downloading immedeately
        [signal subscribeNext:^(UIImage *image) {
            cache[imagePath] = image;
        }];
    }
}

#pragma mark - Helper methods

// A simple method using RAC to load an image from a URL on a separate thread.
// Currently assumes that all urls are valid and does no error handling.
- (RACSignal *)loadFromURLString: (NSString*) urlString {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // First, see if the image is already stored in the cache
        UIImage *image = cache[urlString];
        
        // If it is not, then load it from the web
        if(!image) {
            
            
            NSLog(@"Fetching image");
            // ISSUE: Images don't load until the signal is attached to a cell
            
            NSURL *url = [NSURL URLWithString:urlString];
            NSData * imageData = [NSData dataWithContentsOfURL:url];
            image = [UIImage imageWithData:imageData];
            cache[urlString] = image;
        }
        
        // Send the loaded (either from the cache or the web) as the RACSignal's value
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        
        return nil;
        
        // Don't run on the main thread
    }] subscribeOn:[RACScheduler scheduler]];
}

# pragma mark - IBActions

// Called when the state is toggled using the UIBarButtonItem in the UINavigationBar
- (IBAction)toggleState:(id)sender {
    
    // Toggle the mode of the custom UICollectionViewLayout
    IconFlowLayout *layout = ((IconFlowLayout *)self.collectionViewLayout);
    layout.multipleMode = !layout.multipleMode;
    
    self.navigationItem.title = layout.multipleMode ? @"Mode: Multiple" : @"Mode: Single";
    
    // Force an animated reload of the UICollectionView
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadData];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return imageURLs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    IconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Clear the UIImageView of the reused cell and dispose of any subscriptions the cell has
    // so that an image of a previous index doesn't load into it.
    cell.imageView.image = nil;
    if (cell.disposable) {
        [cell.disposable dispose];
    }
    
    // Subscribes the cell to the related RACSignal and sets its disposable for future disposal.
    // Ensures that the block will be executed on the main thread since it is a UI operation.
    cell.disposable = [[imageSignals[indexPath.row] deliverOn: RACScheduler.mainThreadScheduler]
     subscribeNext:^(UIImage *image) {
         
        // Sets the UIImageView of the cell when it is loaded by the RACSignal
        cell.imageView.image = image;
    }];
    
    return cell;
}

# pragma mark - Setup Methods

- (void)initializeVariables {
    
    // Just a bunch of random pictures off of Flickr
    imageURLs = @[@"https://farm2.staticflickr.com/1529/26399561050_c507af17e5_b.jpg",
                  @"https://farm2.staticflickr.com/1601/26651999906_f31b038435_b.jpg",
                  @"https://farm2.staticflickr.com/1539/26394459950_c4a351f771_o.jpg",
                  @"https://farm2.staticflickr.com/1643/26682925535_a21b044c66_b.jpg",
                  @"https://farm2.staticflickr.com/1648/26602403371_6fc329281c_o.jpg",
                  @"https://farm2.staticflickr.com/1619/26406527400_fc8d9c7f9f_o.jpg",
                  @"https://farm2.staticflickr.com/1462/26403874270_cfce3d6fc0_o.jpg",
                  @"https://farm2.staticflickr.com/1563/26064250854_b15abe5dc5_o.jpg",
                  @"https://farm2.staticflickr.com/1554/26573612632_6f94a592b0_o.jpg",
                  @"https://farm2.staticflickr.com/1636/26586203102_eeb7c47582_o.jpg",
                  @"https://farm2.staticflickr.com/1530/26679350575_def34e41f5_b.jpg",
                  @"https://farm2.staticflickr.com/1633/26067447274_ae6b60eb98_b.jpg",
                  @"https://farm2.staticflickr.com/1690/26394065660_95390c632c_b.jpg",
                  @"https://farm2.staticflickr.com/1525/26066908103_9e8e46d019_b.jpg",
                  @"https://farm2.staticflickr.com/1444/26072130643_a63150d1dc_o.jpg",
                  @"https://farm2.staticflickr.com/1653/26673647905_dd6b700ae6_b.jpg",
                  @"https://farm2.staticflickr.com/1528/26399687860_12afa79d38_o.jpg",
                  @"https://farm2.staticflickr.com/1606/26614961871_181f425a1a_o.jpg",
                  @"https://farm2.staticflickr.com/1596/26677193375_046604343f_b.jpg",
                  @"https://farm2.staticflickr.com/1702/26406291440_69199a97d5_b.jpg",
                  @"https://farm2.staticflickr.com/1624/26682330035_db53007d4d_o.jpg",
                  @"https://farm2.staticflickr.com/1479/26680021255_880036efb6_b.jpg",
                  @"https://farm2.staticflickr.com/1650/26406805060_b8e74a0f97_b.jpg",
                  @"https://farm2.staticflickr.com/1596/26586239532_58b1fb5ec9_b.jpg",
                  @"https://farm2.staticflickr.com/1568/26586784192_a014df7efb_o.jpg"];
    
    imageSignals = [[NSMutableArray alloc] initWithCapacity:imageURLs.count];
    cache = [[NSMutableDictionary alloc] initWithCapacity:imageURLs.count];
}

@end
