//
//  ScheduleLayout.swift
//  DUTInfomation
//
//  Created by shino on 17/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

// 固定 headers 和第一行
class ScheduleLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect)  else {
            return nil
        }
        let offset = max(collectionView!.bounds.minY, 0)
        for attribute in attributes {
            let frame = attribute.frame
            if attribute.representedElementKind == UICollectionElementKindSectionHeader {
                attribute.frame = CGRect(x: frame.minX, y: offset, width: frame.width, height: frame.height)
                continue
            }
            if attribute.indexPath.item < 8 {
                attribute.frame = CGRect(x: frame.minX, y: offset + 20, width: frame.width, height: frame.height)
                attribute.zIndex = 1024
            }
        }
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
