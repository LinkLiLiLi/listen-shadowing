import SwiftUI
import SwiftData

struct ClipLibraryView: View {
    let environment: AppEnvironment
    @Environment(\.modelContext) private var context
    @Query(sort: \Clip.createdAt, order: .reverse) private var clips: [Clip]
    @State private var showingRecord = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(clips) { clip in
                    NavigationLink {
                        PracticeView(model: PracticeModel(
                            clip: clip,
                            audio: environment.audio,
                            store: environment.store,
                            context: context))
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(clip.title).font(.headline)
                            Text(clip.scriptText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .onDelete(perform: deleteClips)
            }
            .navigationTitle("片段库")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingRecord = true
                    } label: {
                        Label("录新片段", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if clips.isEmpty {
                    ContentUnavailableView(
                        "还没有片段",
                        systemImage: "mic",
                        description: Text("点右上角 ＋ 录下第一句美剧对话"))
                }
            }
            .sheet(isPresented: $showingRecord) {
                RecordView(model: RecordClipModel(
                    audio: environment.audio,
                    store: environment.store,
                    context: context))
            }
        }
    }

    private func deleteClips(_ offsets: IndexSet) {
        for index in offsets {
            let clip = clips[index]
            try? environment.store.delete(filename: clip.originalAudioFilename)
            for attempt in clip.attempts {
                try? environment.store.delete(filename: attempt.audioFilename)
            }
            context.delete(clip)
        }
        try? context.save()
    }
}
