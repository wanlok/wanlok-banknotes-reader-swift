//
//  TitleSwitchTableViewCell.swift
//  banknotes-reader
//
//  Created by wanlok on 4/1/2026.
//

import UIKit

class TitleSwitchTableViewCell: UITableViewCell {
    static let identifier = "TitleSwitchTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var aSwitch: UISwitch!
    
    var indexPath: IndexPath?
    var callback: ((_ indexPath: IndexPath, _ value: Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        aSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        guard let indexPath = indexPath, let callback = callback else {
            return
        }
        callback(indexPath, sender.isOn)
    }
}
