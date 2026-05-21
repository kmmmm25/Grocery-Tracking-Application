//
//  ContentView.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/03.
//

import SwiftUI

struct ContentView: View {
    // Firebase対応の管理者（ViewModel）を呼び出す
    @StateObject private var viewModel = FoodListViewModel()
    @State private var showingAddFoodView = false
    
    var body: some View {
        NavigationView {
            // ViewModelが持っているリストをそのまま表示
            List(viewModel.foodItems) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text("期限: \(item.expiryDate, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // 残り日数に応じたカラーバッジ
                    Text("あと \(item.daysUntilExpiry) 日")
                        .foregroundColor(item.daysUntilExpiry <= 3 ? .red : .green)
                        .font(.caption)
                        .padding(6)
                        .background(item.daysUntilExpiry <= 3 ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .navigationTitle("食材管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFoodView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // ＋ボタンが押されたら追加画面をハーフシートで表示
            .sheet(isPresented: $showingAddFoodView) {
                AddFoodView(onSave: { newItem in
                    // 追加画面から届いたデータを、ViewModel経由でFirebaseへ送る
                    viewModel.add(item: newItem)
                })
            }
        }
    }
}
