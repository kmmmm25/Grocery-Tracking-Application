//
//  Fooditem.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/21.
//
import Foundation
import FirebaseFirestore
import UIKit

struct FoodItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var expiryDate: Date
    var createdAt: Date // 🚀【新機能】追加された日時を記録するプロパティ
    
    // 【追加】将来的にFirebase Storageに保存した写真のURLを入れる枠
    var imageURLString: String?
    
    // Codableでエラーにならないようにするための設定
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case expiryDate
        case createdAt // 🚀 忘れずにここにも追加
        case imageURLString
    }
    
    // 期限までの残り日数を計算する機能
    var daysUntilExpiry: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
}

// 【重要】AddFoodViewで「image: inputImage」を受け取れるようにするための補助機能
extension FoodItem {
    init(name: String, expiryDate: Date, image: UIImage?) {
        self.id = nil
        self.name = name
        self.expiryDate = expiryDate
        self.createdAt = Date() // 🚀 初期値として「作成した瞬間の現在日時」をセットします
        self.imageURLString = nil
    }
}
