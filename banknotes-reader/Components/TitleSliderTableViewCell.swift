//
//  TitleSliderTableViewCell.swift
//  banknotes-reader
//
//  Created by wanlok on 21/12/2025.
//

import UIKit

class TitleSliderTableViewCell: UITableViewCell {
    static let identifier = "TitleSliderTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var indexPath: IndexPath?
    var callback: ((_ indexPath: IndexPath, _ value: Float) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        slider.addTarget(self, action: #selector(sliderEnded(_:)), for: [.touchUpInside, .touchUpOutside])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc private func sliderEnded(_ sender: UISlider) {
        guard let indexPath = indexPath, let callback = callback else {
            return
        }
        callback(indexPath, sender.value)
    }
}
