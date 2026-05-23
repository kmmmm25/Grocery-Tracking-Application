//
//  FoodListViewModel.swift
//  Grocery App
//
//  Created by Ikezaki  Kumataka on 2026/05/21.
//

import Combine
import Foundation
import FirebaseFirestore
import UIKit

class FoodListViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    // Firebaseからデータをリアルタイムで取得し、並び替える
    func fetchData() {
        db.collection("foods").addSnapshotListener { [weak self] (querySnapshot, error) in
            if let error = error {
                print("データの取得に失敗しました: \(error.localizedDescription)")
                return
            }
            
            // Firebaseから生データを取得
            let rawItems = querySnapshot?.documents.compactMap { document in
                try? document.data(as: FoodItem.self)
            } ?? []
            
            // 画面の更新はメインスレッドで安全に行う
            DispatchQueue.main.async {
                self?.foodItems = rawItems.sorted { item1, item2 in
                    if item1.expiryDate == item2.expiryDate {
                        return item1.createdAt < item2.createdAt
                    } else {
                        return item1.expiryDate < item2.expiryDate
                    }
                }
            }
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
    
    // Firebaseから食材を削除する機能
    func delete(item: FoodItem) {
        guard let id = item.id else { return }
        db.collection("foods").document(id).delete { error in
            if let error = error {
                print("削除に失敗しました: \(error.localizedDescription)")
            } else {
                // 🚀【追加】Firebaseから消えたら、iPhone内の写真ファイルも削除する
                if let imagePath = item.imagePath {
                    self.deleteImageFromDocuments(fileName: imagePath)
                }
                print("Firebaseから削除完了！")
            }
        }
    }
    
    // Firebaseの既存データを上書き更新する機能
    func update(item: FoodItem) {
        guard let id = item.id else { return }
        do {
            try db.collection("foods").document(id).setData(from: item)
            print("Firebaseのデータ更新成功！")
        } catch {
            print("更新に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 🚀【新機能】iPhone内のDocumentsフォルダから写真を読み込む関数
    func loadImageFromDocuments(fileName: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            return nil
        }
    }
    
    // 🚀【新機能】iPhone内の写真ファイルを削除する関数
    private func deleteImageFromDocuments(fileName: String) -> Void {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                print("🗑️ 写真ファイルを削除しました")
            } catch {
                print("⚠️ 写真ファイルの削除に失敗しました: \(error.localizedDescription)")
            }
        }
    }
}
