//
//  PhotoGridCell.swift
//  Photos
//
//  Created by 张晓鑫 on 2017/6/1.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit

class PhotoGridCell: UICollectionViewCell {
    
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var selectedImageView: UIImageView!
    
    var imageView: UIImageView! = UIImageView()
    var selectedImageView: UIImageView! = UIImageView()
    var assistantLabel: UILabel = UILabel()
    open override var isSelected: Bool {
        didSet{
            if isSelected {
                selectedImageView.image = UIImage(named:"CellBlueSelected")
            } else {
                selectedImageView.image = UIImage(named:"CellGreySelected")
            }
        }
    }
    
    var duration: TimeInterval = 0 {
        didSet {
            let newValue = Int(ceil(duration))
            assistantLabel.text = String(format: "%d:%02d", arguments: [newValue / 60, newValue % 60])
            assistantLabel.isHidden = false            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        selectedImageView.frame = CGRect(x: self.bounds.width - 35, y: 0, width: 30, height: 30)
        selectedImageView.image = UIImage.init(named: "CellGreySelected")
        self.addSubview(selectedImageView)
        
        assistantLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.addSubview(assistantLabel)
        assistantLabel.isHidden = true
        assistantLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: assistantLabel, attribute: .trailing, multiplier: 1, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: assistantLabel, attribute: .bottom, multiplier: 1, constant: 8))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assistantLabel.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showAnim() {
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { 
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: { 
                self.selectedImageView.transform = CGAffineTransform(scaleX: 0.7, y:0.7)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: { 
                self.selectedImageView.transform = CGAffineTransform.identity
            })
        }, completion: nil)
    }
    
}
