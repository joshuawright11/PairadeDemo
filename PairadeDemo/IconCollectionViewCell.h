//
//  IconCollectionViewCell.h
//  PairadeDemo
//
//  Created by Josh Wright on 4/26/16.
//  Copyright © 2016 Pairade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface IconCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

// A stored disposable to ensure the cell is only subscribed to one RACSignal at a time
@property (weak, nonatomic) RACDisposable *disposable;

@end
