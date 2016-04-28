//
//  IconCollectionViewCell.m
//  PairadeDemo
//
//  Created by Josh Wright on 4/26/16.
//  Copyright © 2016 Pairade. All rights reserved.
//

#import "IconCollectionViewCell.h"

@implementation IconCollectionViewCell

// This is so that the UIImageView will properly resize along with the rest of the cell
// when the cell is resized during the UICollectionView mode switch.
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}

@end
