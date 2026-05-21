//
//  FoodListViewModel.swift
//  Grocery App
//
//  Created by Ikezaki  Kumataka on 2026/05/21.
//

import Combine // ← 画面とデータを連動させるための最重要モジュール
import Foundation
import FirebaseFirestore

class FoodListViewModel: ObservableObject {
    // 画面にリアルタイムで変更を通知する食材リスト
    @Published var foodItems: [FoodItem] = []
    
    // Firebase Firestore への接続窓口
    private var db = Firestore.firestore()
    
    init() {
        // 起動時に自動でデータを読み込む
        fetchData()
    }
    
    // Firebaseからデータをリアルタイムで監視・取得
    // Firebaseからデータをリアルタイムで監視・取得
        func fetchData() {
            db.collection("foods").addSnapshotListener { [weak self] (querySnapshot, error) in // ←「[weak self]」を追加！
                if let error = error {
                    print("データの取得に失敗しました: \(error.localizedDescription)")
                    return
                }
                
                // selfの前に「?」をつけます
                self?.foodItems = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: FoodItem.self)
                } ?? []
            }
        }
    
    // Firebaseに新しい食材を追加保存
    func add(item: FoodItem) {
        do {
            let _ = try db.collection("foods").addDocument(from: item)
            print("Firebaseに保存成功！")
        } catch {
            print("Firebaseへの保存に失敗しました: \(error.localizedDescription)")
        }
    }
}
