//
//  FamilyAuthView.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/28.
//

import SwiftUI
import FirebaseFirestore

struct FamilyAuthView: View {
    // ログイン成功時に、アプリ全体に「ログインした家族ID」を伝えるためのバインド
    @Binding var currentFamilyID: String?
     
    @State private var familyID = ""
    @State private var password = ""
    @State private var isSignUpMode = false // trueなら新規作成、falseならログイン
     
    @State private var errorMessage = ""
    @State private var isLoading = false
     
    private var db = Firestore.firestore()
    
    // 他のファイルから確実に呼び出せるようにする公開用初期化関数
    public init(currentFamilyID: Binding<String?>) {
        self._currentFamilyID = currentFamilyID
    }
     
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text(isSignUpMode ? "家族グループを新規作成" : "家族アカウントでログイン")
                    .font(.title2)
                    .bold()
                    .padding(.top, 40)
                 
                VStack(spacing: 15) {
                    // 家族ID入力欄
                    HStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(.gray)
                        TextField("家族ID (重複不可の英数字)", text: $familyID)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                     
                    // パスワード入力欄
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        SecureField("パスワード", text: $password)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                 
                // エラーメッセージ表示
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                 
                // 実行ボタン
                Button(action: {
                    if isSignUpMode {
                        handleSignUp()
                    } else {
                        handleLogin()
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        Text(isSignUpMode ? "グループを作成して始める" : "ログインして始める")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(familyID.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(familyID.isEmpty || password.isEmpty || isLoading)
                .padding(.horizontal)
                 
                // モード切り替えボタン
                Button(action: {
                    isSignUpMode.toggle()
                    errorMessage = ""
                }) {
                    Text(isSignUpMode ? "既にアカウントをお持ちの方（ログイン）" : "新しい家族グループを作りたい方（新規登録）")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                 
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
     
    // 🚀【新規作成処理】
    private func handleSignUp() {
        isLoading = true
        errorMessage = ""
         
        let trimmedFamilyID = familyID.trimmingCharacters(in: .whitespacesAndNewlines)
        let docRef = db.collection("families").document(trimmedFamilyID)
         
        docRef.getDocument { (document, error) in
            if let error = error {
                self.errorMessage = "通信エラーが発生しました: \(error.localizedDescription)"
                self.isLoading = false
                return
            }
             
            if let document = document, document.exists {
                self.errorMessage = "❌ この家族IDは既に他の家族に使われています。\n別のIDを入力してください。"
                self.isLoading = false
            } else {
                let familyData: [String: Any] = [
                    "password": self.password,
                    "createdAt": FieldValue.serverTimestamp()
                ]
                 
                docRef.setData(familyData) { error in
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "登録に失敗しました: \(error.localizedDescription)"
                    } else {
                        print("🎉 家族グループ「\(trimmedFamilyID)」を新しく作成しました！")
                        UserDefaults.standard.set(trimmedFamilyID, forKey: "savedFamilyID")
                        
                        // 💡【修正】メインスレッドで安全に画面を切り替える
                        DispatchQueue.main.async {
                            self.currentFamilyID = trimmedFamilyID
                            self.switchToContentView(familyID: trimmedFamilyID)
                        }
                    }
                }
            }
        }
    }
     
    // 🚀【ログイン処理】
    private func handleLogin() {
        isLoading = true
        errorMessage = ""
         
        let trimmedFamilyID = familyID.trimmingCharacters(in: .whitespacesAndNewlines)
         
        db.collection("families").document(trimmedFamilyID).getDocument { (document, error) in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "ログインエラー: \(error.localizedDescription)"
                    return
                }
                 
                guard let document = document, document.exists, let data = document.data() else {
                    self.errorMessage = "❌ 家族IDが見つかりません。登録内容を確認してください。"
                    return
                }
                 
                if let savedPassword = data["password"] as? String, savedPassword == self.password {
                    print("🔑 ログイン成功！")
                    UserDefaults.standard.set(trimmedFamilyID, forKey: "savedFamilyID")
                    
                    // 💡【修正】ログイン成功した瞬間に、アプリ全体へ通知してContentViewへ強制切り替えする
                    self.currentFamilyID = trimmedFamilyID
                    self.switchToContentView(familyID: trimmedFamilyID)
                } else {
                    self.errorMessage = "❌ パスワードが正しくありません。"
                }
            }
        }
    }
    
    // 💡【新機能】ログイン・登録成功時にContentViewの画面を強制的に立ち上げるお助け関数
    private func switchToContentView(familyID: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(
                rootView: ContentView().environment(\.currentFamilyID, familyID)
            )
            window.makeKeyAndVisible()
        }
    }
}
