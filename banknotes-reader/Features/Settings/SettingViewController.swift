//
//  SettingViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

protocol SettingRow {
    
}

struct TitleSubtitleAccessoryTypeRow: SettingRow {
    let title: String
    let subtitle: String?
    let accessoryType: UITableViewCell.AccessoryType?
}

struct TitleSliderRow: SettingRow {
    let title: String
    let min: Float
    let max: Float
    let value: Float
}

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let defaults = UserDefaults.standard
    
    let titleSubtitleAccessoryTypeTableViewCellIdentifier: String = "TitleSubtitleAccessoryTypeTableViewCell"
    let titleSliderTableViewCellIdentifier: String = "TitleSliderTableViewCell"
    
    var sections:  [(title: String, rows: [SettingRow])] {
        fatalError("Subclasses must override sections")
    }
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TitleSliderTableViewCell", bundle: nil), forCellReuseIdentifier: titleSliderTableViewCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       if let tableView = view.subviews.compactMap({ $0 as? UITableView }).first,
          let indexPath = tableView.indexPathForSelectedRow {
           tableView.deselectRow(at: indexPath, animated: true)
       }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections[section].title == title { return 0 }
        if section == 0 { return 34 }
        return 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let row = sections[indexPath.section].rows[indexPath.row]
        if let row = row as? TitleSubtitleAccessoryTypeRow {
            cell = getTitleSubtitleAccessoryTypeTableViewCell(tableView, row)
        } else if let row = row as? TitleSliderRow {
            cell = getTitleSliderTableViewCell(tableView, indexPath, row)
        } else {
            fatalError("tableView cellForRowAt")
        }
        return cell
    }
    
    func getTitleSubtitleAccessoryTypeTableViewCell(_ tableView: UITableView, _ row: TitleSubtitleAccessoryTypeRow) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: titleSubtitleAccessoryTypeTableViewCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: titleSubtitleAccessoryTypeTableViewCellIdentifier)
        }
        guard let cell else {
            fatalError("getTitleSubtitleAccessoryTypeTableViewCell")
        }
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.subtitle
        if let accessoryType = row.accessoryType {
            cell.accessoryType = accessoryType
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func getTitleSliderTableViewCell(_ tableView: UITableView, _ indexPath: IndexPath, _ row: TitleSliderRow) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: titleSliderTableViewCellIdentifier, for: indexPath) as? TitleSliderTableViewCell else {
            fatalError("getTitleSliderTableViewCell")
        }
        cell.indexPath = indexPath
        cell.callback = tableViewCellSliderEnded
        cell.titleLabel.text = row.title
        cell.slider.minimumValue = row.min
        cell.slider.maximumValue = row.max
        cell.slider.value = row.value
        return cell
    }
    
    func isRowSelected(_ key: String, _ index: Int) -> UITableViewCell.AccessoryType? {
        return defaults.integer(forKey: key) == index ? .checkmark : nil
    }
    
    func tableViewCellSliderEnded(_ indexPath: IndexPath, _ value: Float) {
        fatalError("Subclasses must override tableViewCellSliderEnded")
    }
}
