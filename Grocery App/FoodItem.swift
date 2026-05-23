//
//  Fooditem.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/03.
//

import Foundation
import FirebaseFirestore
import UIKit

struct FoodItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var expiryDate: Date
    var createdAt: Date
    
    // iPhone内に保存した画像の「ファイル名」を記録する枠
    var imagePath: String?
    
    // 🚀【大復活！】消えてしまっていた残り日数の自動計算プロパティ
    var daysUntilExpiry: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
    
    // Codableでエラーにならないようにするための設定
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case expiryDate
        case createdAt
        case imagePath
    }
}

// ContentViewや他画面との連携用の補助機能
extension FoodItem {
    init(name: String, expiryDate: Date, image: UIImage?) {
        self.id = nil
        self.name = name
        self.expiryDate = expiryDate
        self.createdAt = Date()
        self.imagePath = nil
    }
}
