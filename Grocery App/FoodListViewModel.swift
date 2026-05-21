//
//  FoodListViewModel.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/21.
//

import Combine
import Foundation
import FirebaseFirestore

class FoodListViewModel: ObservableObject {
    
    @Published var foodItems: [FoodItem] = []
    
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    // Firebaseからデータをリアルタイム取得
    func fetchData() {
        
        db.collection("foods").addSnapshotListener { [weak self] querySnapshot, error in
            
            // エラーチェック
            if let error = error {
                print("データの取得に失敗しました: \(error.localizedDescription)")
                return
            }
            
            // Firebaseからデータを取得
            let rawItems = querySnapshot?.documents.compactMap { document in
                try? document.data(as: FoodItem.self)
            } ?? []
            
            // UI更新はメインスレッドで実行
            DispatchQueue.main.async {
                
                self?.foodItems = rawItems.sorted { item1, item2 in
                    
                    // 同じ期限なら追加日が古い順
                    if item1.expiryDate == item2.expiryDate {
                        return item1.createdAt < item2.createdAt
                        
                    } else {
                        
                        // 基本は期限が近い順
                        return item1.expiryDate < item2.expiryDate
                    }
                }
            }
        }
    }
    
    // Firebaseに新しい食材を保存
    func add(item: FoodItem) {
        
        do {
            let _ = try db.collection("foods").addDocument(from: item)
            print("Firebaseに保存成功！")
            
        } catch {
            print("Firebaseへの保存に失敗しました: \(error.localizedDescription)")
        }
    }
}
