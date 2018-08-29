//
//  ScheduleLayout.swift
//  DUTInfomation
//
//  Created by shino on 17/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

// 自定义 UIcollectionView 流布局
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

// 实现 UICollectionViewDelegateFlowLayout, 补充流布局
// 课程表的布局
extension ScheduleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidthPX = collectionView.bounds.width * UIScreen.main.scale
        var cellWidth: CGFloat = 0
        var cellHeight: CGFloat = 0
        let widthPX = collectionViewWidthPX - 7 * UIScreen.main.scale * 2
        let line = indexPath.item % 8
        let row = Int(indexPath.item / 8)
        if row == 0 {
            cellHeight = 45
            if line == 0 {
                cellWidth = CGFloat(Int(widthPX / 15)) / UIScreen.main.scale
            } else {
                cellWidth = CGFloat(Int(widthPX / 15)) * 2 / UIScreen.main.scale
            }
        } else {
            cellHeight = 85
            if line == 0 {
                cellWidth = CGFloat(Int(widthPX / 15)) / UIScreen.main.scale
            } else {
                cellWidth = CGFloat(Int(widthPX / 15)) * 2 / UIScreen.main.scale
            }
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let collectionViewWidthPX = collectionView.bounds.width * UIScreen.main.scale
        let widthPX = collectionViewWidthPX - 7 * UIScreen.main.scale * 2
        let remindWidth = widthPX - CGFloat(Int(widthPX / 15)) * 15
        let leftPadding = CGFloat(Int(remindWidth / 2)) / UIScreen.main.scale
        let rightPadding = remindWidth / UIScreen.main.scale - leftPadding - 0.001
        return UIEdgeInsets(top: 0, left: leftPadding, bottom: 2, right: rightPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let cellSpace = CGFloat(2)
        return cellSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let cellSpace = CGFloat(2)
        return cellSpace
    }
}
