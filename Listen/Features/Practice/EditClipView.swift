import SwiftUI

struct EditClipView: View {
    @StateObject var model: EditClipModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("名字", text: $model.title)
                TextField("英文台词", text: $model.scriptText, axis: .vertical)
                    .lineLimit(2...6)
            }
            .navigationTitle("编辑片段")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        try? model.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
