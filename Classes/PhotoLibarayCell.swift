//
//  PhotoLibarayCell.swift
//  Photos
//
//  Created by 张晓鑫 on 2017/6/1.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit

class PhotoLibarayCell: UITableViewCell {

//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var countLabel: UILabel!
    var titleLabel: UILabel = UILabel()
    var countLabel: UILabel = UILabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupWithDictionary(_ dic: Dictionary<String, String>) {
        titleLabel.text = dic["title"]
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.frame = CGRect(x: 16, y: 20, width:0, height:0)
        titleLabel.sizeToFit()
        self.addSubview(titleLabel)
        countLabel.text = dic["count"]
        countLabel.font = UIFont.systemFont(ofSize: 15)
        countLabel.frame = CGRect(x: 16 + titleLabel.bounds.size.width + 10, y: titleLabel.frame.minY, width:0, height: 0)
        countLabel.sizeToFit()
        self.addSubview(countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
