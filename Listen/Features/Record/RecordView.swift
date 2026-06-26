import SwiftUI

struct RecordView: View {
    @StateObject var model: RecordClipModel
    @Environment(\.dismiss) private var dismiss

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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        _ = try? model.save()
                        dismiss()
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
