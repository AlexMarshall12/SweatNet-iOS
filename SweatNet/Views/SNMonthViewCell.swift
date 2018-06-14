//
//  SNTimelineMonthViewCell.swift
//  SweatNet
//
//  Created by Alex on 5/26/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

class SNMonthViewCell: UICollectionViewCell {

    @IBOutlet weak var dayTicks: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D) {
        dayTicks.delegate = dataSourceDelegate
        dayTicks.dataSource = dataSourceDelegate
        dayTicks.reloadData()
    }
}
