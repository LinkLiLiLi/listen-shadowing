import SwiftUI

struct PracticeView: View {
    @StateObject var model: PracticeModel
    @Environment(\.modelContext) private var editContext
    @State private var showingEdit = false

    var body: some View {
        List {
            Section {
                Text(model.clip.scriptText.isEmpty
                     ? "（无台词）" : model.clip.scriptText)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }

            Section("练习") {
                Button {
                    try? model.playOriginal(loop: true)
                } label: {
                    Label("循环听原声", systemImage: "repeat")
                }
                Button {
                    toggleAttempt()
                } label: {
                    Label(model.isRecording ? "停止录音" : "录我的跟读",
                          systemImage: model.isRecording
                              ? "stop.circle.fill" : "mic.circle.fill")
                        .foregroundStyle(model.isRecording ? .red : .accentColor)
                }
            }

            Section("历史跟读（\(model.attemptsNewestFirst.count)）") {
                if model.attemptsNewestFirst.isEmpty {
                    Text("还没有跟读，先录一条吧")
                        .foregroundStyle(.secondary)
                }
                ForEach(model.attemptsNewestFirst) { attempt in
                    HStack {
                        Button {
                            try? model.playAttempt(attempt, loop: false)
                        } label: {
                            Image(systemName: "play.circle")
                        }
                        Text(attempt.createdAt, style: .time)
                        Spacer()
                        Button("对比") {
                            try? model.playComparison(attempt)
                        }
                        .buttonStyle(.bordered)
                    }
                    .swipeActions {
                        Button("删除", role: .destructive) {
                            try? model.deleteAttempt(attempt)
                        }
                    }
                }
            }
        }
        .navigationTitle(model.clip.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("编辑") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditClipView(model: EditClipModel(
                clip: model.clip, context: editContext))
        }
    }

    private func toggleAttempt() {
        if model.isRecording {
            try? model.stopAttempt()
        } else {
            try? model.startAttempt()
        }
    }
}
