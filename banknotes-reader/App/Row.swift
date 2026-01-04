//
//  Row.swift
//  banknotes-reader
//
//  Created by wanlok on 21/12/2025.
//

protocol Row {}

struct TitleSubtitleAccessoryTypeRow: Row {
    let title: String
    let subtitle: String?
    let accessoryType: UITableViewCell.AccessoryType?
}

struct TitleMinMaxValueRow: Row {
    let title: String
    let min: Float
    let max: Float
    let value: Float
}

struct TitleBoolRow: Row {
    let title: String
    let bool: Bool
}
