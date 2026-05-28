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
    private var familyID: String
    
    // 💡 どんな場面からでも安全に初期化できるようにします
    init() {
        self.familyID = UserDefaults.standard.string(forKey: "savedFamilyID") ?? ""
        fetchData()
    }
    
    private var familyFoodsCollection: CollectionReference {
        return db.collection("families").document(familyID).collection("foods")
    }
    
    func fetchData() {
        guard !familyID.isEmpty else { return }
        
        familyFoodsCollection.addSnapshotListener { [weak self] (querySnapshot, error) in
            if let error = error {
                print("データの取得に失敗しました: \(error.localizedDescription)")
                return
            }
            
            let rawItems = querySnapshot?.documents.compactMap { document in
                try? document.data(as: FoodItem.self)
            } ?? []
            
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
    
    func add(item: FoodItem) {
        guard !familyID.isEmpty else { return }
        do {
            let _ = try familyFoodsCollection.addDocument(from: item)
            print("🎉 Firebase（\(familyID)の部屋）に食材を追加しました！")
        } catch {
            print("追加に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func update(item: FoodItem) {
        guard let id = item.id, !familyID.isEmpty else { return }
        do {
            try familyFoodsCollection.document(id).setData(from: item)
            print("🎉 Firebase（\(familyID)の部屋）のデータ更新成功！")
        } catch {
            print("更新に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func delete(item: FoodItem) {
        guard let id = item.id, !familyID.isEmpty else { return }
        
        familyFoodsCollection.document(id).delete { error in
            if let error = error {
                print("削除に失敗しました: \(error.localizedDescription)")
            } else {
                print("🗑️ Firebaseから食材を削除しました")
                if let imagePath = item.imagePath {
                    self.deleteImageFromDocuments(fileName: imagePath)
                }
                NotificationManager.shared.cancelNotifications(for: id)
            }
        }
    }
    
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
