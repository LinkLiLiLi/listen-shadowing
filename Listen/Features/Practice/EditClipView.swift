import SwiftUI

struct EditClipView: View {
    @StateObject var model: EditClipModel
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("名字", text: $model.title)
                TextField("英文台词", text: $model.scriptText, axis: .vertical)
                    .lineLimit(2...6)
            }
            .navigationTitle("编辑片段")
            .alert("保存失败",
                   isPresented: Binding(get: { errorMessage != nil },
                                        set: { if !$0 { errorMessage = nil } })) {
                Button("好", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        do {
                            try model.save()
                            dismiss()
                        } catch {
                            errorMessage = "保存失败：\(error.localizedDescription)"
                        }
                    }
                }
            }
        }
    }
}
