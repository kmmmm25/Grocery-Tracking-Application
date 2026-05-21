//
//  ContentView.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/03.
//

import SwiftUI

struct ContentView: View {
    
    // Firebase対応の管理者（ViewModel）
    @StateObject private var viewModel = FoodListViewModel()
    
    @State private var showingAddFoodView = false
    
    var body: some View {
        NavigationView {
            
            // ViewModelが持っているリストを表示
            List(viewModel.foodItems) { item in
                
                HStack {
                    
                    // 左側：食材情報
                    VStack(alignment: .leading) {
                        
                        Text(item.name)
                            .font(.headline)
                        
                        Text("期限: \(item.expiryDate, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // 右側：期限バッジ
                    if item.daysUntilExpiry < 0 {
                        
                        // ① 期限切れ
                        Text("消費期限切れです")
                            .foregroundColor(.red)
                            .font(.caption)
                            .bold()
                            .padding(6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        
                    } else if item.daysUntilExpiry <= 1 {
                        
                        // ② あと1日
                        Text("あと \(item.daysUntilExpiry) 日")
                            .foregroundColor(.red)
                            .font(.caption)
                            .bold()
                            .padding(6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        
                    } else if item.daysUntilExpiry <= 3 {
                        
                        // ③ あと2〜3日
                        Text("あと \(item.daysUntilExpiry) 日")
                            .foregroundColor(.orange)
                            .font(.caption)
                            .padding(6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        
                    } else {
                        
                        // ④ 4日以上
                        Text("あと \(item.daysUntilExpiry) 日")
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
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
            
            // ＋ボタンで追加画面を表示
            .sheet(isPresented: $showingAddFoodView) {
                
                AddFoodView(onSave: { newItem in
                    
                    // Firebaseへ保存
                    viewModel.add(item: newItem)
                })
            }
        }
    }
}
