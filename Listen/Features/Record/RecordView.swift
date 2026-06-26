import SwiftUI

struct RecordView: View {
    @StateObject var model: RecordClipModel
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("原声录音") {
                    Button {
                        toggleRecording()
                    } label: {
                        Label(model.isRecording ? "停止录音" : "开始录音",
                              systemImage: model.isRecording
                                  ? "stop.circle.fill" : "mic.circle.fill")
                            .foregroundStyle(model.isRecording ? .red : .accentColor)
                    }
                    if model.hasRecording {
                        Text("已录好 ✓").foregroundStyle(.secondary)
                    }
                }
                Section("台词") {
                    TextField("名字，如 How you doin'", text: $model.title)
                    TextField("英文台词", text: $model.scriptText,
                              axis: .vertical)
                        .lineLimit(2...5)
                }
            }
            .navigationTitle("录新片段")
            .alert("保存失败",
                   isPresented: Binding(get: { errorMessage != nil },
                                        set: { if !$0 { errorMessage = nil } })) {
                Button("好", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        model.cancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        do {
                            _ = try model.save()
                            dismiss()
                        } catch {
                            errorMessage = "保存失败：\(error.localizedDescription)"
                        }
                    }
                    .disabled(!model.hasRecording)
                }
            }
        }
    }

    private func toggleRecording() {
        if model.isRecording {
            model.stopRecording()
        } else {
            try? model.startRecording()
        }
    }
}
