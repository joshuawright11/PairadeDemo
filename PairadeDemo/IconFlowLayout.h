//
//  IconFlowLayout.h
//  PairadeDemo
//
//  Created by Josh Wright on 4/26/16.
//  Copyright © 2016 Pairade. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconFlowLayout : UICollectionViewLayout

// A variable for the main UICollectionViewController to toggle to change the layout mode from
// a single cell per row to multiple cells per row.
@property (assign) BOOL multipleMode;

@end
