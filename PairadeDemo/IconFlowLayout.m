//
//  IconFlowLayout.m
//  PairadeDemo
//
//  Created by Josh Wright on 4/26/16.
//  Copyright © 2016 Pairade. All rights reserved.
//

#import "IconFlowLayout.h"

@implementation IconFlowLayout

// The height of the UICollectionView (varies by mode)
CGFloat height;

// A unit of measurement for the sizes of the cells of the UICollectionView. One unit is 1/3 of the
// width of the screen. In single mode each cell is 3 units x 3 units, and in multiple mode there are
// two sizes of cell; 2 units x 2 units and 1 unit x 1 unit.
CGFloat unit;

// The padding around each cell.
CGFloat padding = 2.0;

// The cache of the UICollectionViewLayoutAttributes for the various cells in the UICollectionView
NSMutableArray<UICollectionViewLayoutAttributes *> *cache;

// The UICollectionViewLayoutAttributes of the previous mode. Only necessary because of an issue with
// the UICollectionView animation processs not properly animating cells that weren't originally on the
// screen.
NSMutableArray<UICollectionViewLayoutAttributes *> *oldCache;

# pragma mark - Helper methods

// Calculate wheather the UICollectionViewCell at an index should be large or small (only applicable
// in multiple mode).
- (BOOL) isLarge:(NSInteger)index {
    if ((index / 3)%2 == 0) {
        return index % 3 == 0;
    } else {
        return index % 3 == 2;
    }
}

# pragma mark - UICollectionViewLayout overrides

// Prepare the layout; ensure that the size of the UICollectionView is calculated and the dimensions/
// locations of all the cells are calculated and stored in the cache.
- (void)prepareLayout {
    
    unit = self.collectionView.bounds.size.width/3.0;
    
    // Set the height of the UICollectionView based on the mode
    if (!self.multipleMode) {
        height = [self.collectionView numberOfItemsInSection:0] * unit * 3.0;
    } else {
        height = ceil([self.collectionView numberOfItemsInSection:0] / 3.0) * unit*2.0;
    }
    
    // Update the `oldCache` and reset the main cache.
    oldCache = cache;
    cache = [[NSMutableArray<UICollectionViewLayoutAttributes *> alloc] init];
    
    // Used to keep track of the y value of the UICollectionViewCell's frames
    CGFloat y = 0.0;
    
    // Loops through and calculate the frame for all cells in the UICollectionView
    for (int i = 0 ; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        
        BOOL large = [self isLarge: i];
        CGFloat x;
        
        if ((i / 3)%2 == 0) {
            
            x = large ? 0.0 : unit*2.0;
            
            if (i%3 == 2) {
                y += unit;
            } else if (i%3 == 0 && i != 0) {
                y+=unit*2.0;
            }
        } else {
            x = large ? unit : 0.0;
            
            if (i%3 == 1) {
                y+= unit;
            } else if (i%3 == 2) {
                y -= unit;
            } else if (i%3 == 0) {
                y+= unit;
            }
        }
        
        // Calculate the length and width of the cell (each cell is a square)
        CGFloat side = large ? unit*2.0: unit;
        
        // If the cell is in single mode, all cells have the same dimensions
        if (!self.multipleMode) {
            side = unit * 3.0;
            x = 0;
            y = i*unit*3.0;
        }
        
        // Calculate the frame of the cell with padding
        CGFloat widthPadding = self.multipleMode ? 0 : padding * 2.0;
        CGRect frame = CGRectMake(x+padding, y+padding, side-widthPadding, side);
        
        CGRect insetFrame = CGRectInset(frame, padding, padding);
        
        // Create UICollectionViewLayoutAttributes for each cell and store it in the cache
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        attributes.frame = insetFrame;
        
        [cache addObject:attributes];
    }
}

// Required method for setting the UICollectionView's size
- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

// Return the UICollectionViewLayoutAttributes for every cell in on the screen
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    for (UICollectionViewLayoutAttributes *attribute in cache) {
        if (CGRectIntersectsRect(attribute.frame, rect)) {
            [toReturn addObject:attribute];
        }
    }
    
    return toReturn;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = cache[indexPath.row];
    return attributes;
}

// A hacky solution for avoiding a (bug?) in the UICollectionView where certain cells do not animate
// properly on their layout changing.
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return oldCache[itemIndexPath.row];
}

@end
