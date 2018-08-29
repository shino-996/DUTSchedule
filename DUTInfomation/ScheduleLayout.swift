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
        guard let originAttributes = super.layoutAttributesForElements(in: rect)  else {
            return nil
        }
        let offset = max(collectionView!.bounds.minY, 0)
        var attributes = [UICollectionViewLayoutAttributes]()
        for originAttribute in originAttributes {
            let frame = originAttribute.frame
            let attribute = originAttribute.copy() as! UICollectionViewLayoutAttributes
            if originAttribute.representedElementKind == UICollectionElementKindSectionHeader {
                attribute.frame = CGRect(x: frame.minX, y: offset, width: frame.width, height: frame.height)
            } else if originAttribute.indexPath.item < 8 {
                attribute.frame = CGRect(x: frame.minX, y: offset + 30, width: frame.width, height: frame.height)
                attribute.zIndex = 1024
            } else {
                let alpha = (frame.maxY - (frame.height + offset + 30)) / 45
                attribute.alpha = alpha
            }
            attributes.append(attribute)
        }
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
