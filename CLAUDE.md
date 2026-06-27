# CLAUDE.md — Listen（口语跟读）项目上下文

> 给下一个 AI / 开发者的接手文档。读完这份就能上手改代码、不踩坑。
> 最后更新：2026-06-27。

## 这是什么

`Listen` 是一个 **iPhone 原生 app**，用来练英语口语：录下美剧/电影里的一句对话原声 →
配上英文台词 → 反复循环听 → 录自己的跟读（保留多次历史）→ 原声/我的版本连续对比播放，
靠耳朵自我对比。**纯本地单机，无账号、无联网、无后端、无第三方依赖。**

核心理念：英语靠固定口语句型应对约 80% 日常沟通；这个 app 帮用户把句型听进去、读出来、内化。

设计文档与实现计划在 `docs/superpowers/`（spec + plan），开发过程账本在 `.superpowers/sdd/progress.md`。

## 技术栈

- **SwiftUI**（界面）/ **SwiftData**（持久化）/ **AVFoundation**（录放）/ **XCTest**（21 个单测）
- Swift 5.0 编译设置，最低部署 **iOS 17.0**
- 开发环境：**Xcode 26.6**，模拟器 **iPhone 17 / iOS 26.5**

## ⚠️ 必读：这个工程的特殊之处

1. **`.xcodeproj` 是手写的**（本机没有 Xcode GUI 自动生成的条件，也没装 XcodeGen/Homebrew）。
   它用了 **file-system synchronized groups**（`PBXFileSystemSynchronizedRootGroup`，objectVersion 77）。
   **含义：要加源文件，直接在 `Listen/` 下新建 `.swift`（子目录随意）；要加测试，在 `ListenTests/` 下新建。
   Xcode 自动纳入编译——绝对不要手动编辑 `Listen.xcodeproj/project.pbxproj` 去登记文件。**
   只有改 build settings（如 bundle id、部署目标）才需要动 pbxproj。

2. **iOS 26 的 ModelContext 坑**：`ModelContext` 不再强引用它的 `ModelContainer`。
   测试里若只持有 context、不持有 container，container 会被提前释放导致崩溃。
   解决方案（已统一应用）：每个 ViewModel 都持有 `private let container: ModelContainer = context.container` 保活。
   **新写依赖 ModelContext 的 ViewModel 时，照此办理。**

3. **音频不在模拟器验证**：录放真实行为只能真机测。单测通过 `AudioService` 协议 + `FakeAudioService`
   覆盖逻辑层；`AVAudioService`（真机实现）只做编译验证。

## 构建 / 测试 / 运行

```bash
# 跑全部测试（21 个）
xcodebuild test -scheme Listen -destination 'platform=iOS Simulator,name=iPhone 17'

# 只跑某个测试类
xcodebuild test -scheme Listen -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:ListenTests/PracticeModelTests

# 编译
xcodebuild build -scheme Listen -destination 'platform=iOS Simulator,name=iPhone 17'

# 在模拟器跑起来 + 截图
xcrun simctl boot "iPhone 17"; open -a Simulator
APP=$(find ~/Library/Developer/Xcode/DerivedData -name "Listen.app" -path "*Debug-iphonesimulator*" | head -1)
xcrun simctl install "iPhone 17" "$APP" && xcrun simctl launch "iPhone 17" com.linklilili.listen
xcrun simctl io "iPhone 17" screenshot /tmp/shot.png
```

装真机：Xcode 打开 → TARGET Listen → Signing & Capabilities → 选个人 Team（免费 Apple ID 即可，
装的 app 7 天过期，重装即可）→ 真机需开 Developer Mode + 信任开发者证书。
Bundle id：`com.linklilili.listen`。

## 架构与文件地图

逻辑层全部不依赖硬件、可单测；音频录放藏在 `AudioService` 协议后。

```
Listen/
  ListenApp.swift              @main；建真实 ModelContainer + AppEnvironment，根视图 ClipLibraryView
  AppEnvironment.swift         @MainActor，持有 RecordingStore.defaultStore() + AVAudioService（共享单例）
  Models/                      SwiftData @Model
    Clip.swift                 title, scriptText, originalAudioFilename, createdAt, lastPracticedAt,
                               attempts[Attempt](cascade), collection(PracticeCollection?)
    Attempt.swift              audioFilename, createdAt, clip(Clip?)  —— 一次跟读
    PracticeCollection.swift   name, clips[Clip](nullify)  —— 合集分组
    ModelContainer+Preview.swift  makeInMemoryContainer()（测试/预览用，自由函数非 extension）
  Audio/
    AudioService.swift         protocol（startRecording/stopRecording/play/playSequence/stop/isRecording/isPlaying）
                               + enum AudioServiceError
    AVAudioService.swift       真机实现（AVAudioRecorder/AVAudioPlayer/AVAudioSession）。
                               关键：录音前会先停播放（防止跟读串入原声）；序列播放靠 delegate 推进
    RecordingStore.swift       录音文件 ↔ 沙盒 Documents/recordings/ 路径；makeFilename(prefix:id:)
  Features/
    Library/ClipLibraryView.swift   首页：@Query 片段、按 collection.name 分组（无→"未分组"）、＋录制、滑动删除(连带删音频文件)
    Record/RecordClipModel.swift    录原声 ViewModel：startRecording/stopRecording/save/cancel
    Record/RecordView.swift         录制 sheet
    Practice/PracticeModel.swift    练习 ViewModel：playOriginal(loop)/startAttempt/stopAttempt/playAttempt/
                                    playComparison/deleteAttempt/stopPlayback/attemptsNewestFirst
    Practice/PracticeView.swift     练习页：循环听/停止播放/录跟读 + 历史跟读列表(回放/对比/删除) + 编辑入口
    Practice/EditClipModel.swift    编辑台词/名字 ViewModel
    Practice/EditClipView.swift     编辑 sheet
ListenTests/                   单测；Fakes/FakeAudioService.swift 是 AudioService 的测试替身
docs/superpowers/              specs/（设计） plans/（逐任务实现计划）
.superpowers/sdd/progress.md   开发账本：每个任务的提交范围、review 结论、遗留 minor
```

## 约定与风格

- **TDD**：先写失败测试再实现。ViewModel 用注入的 `idProvider: () -> String` 和 `now: () -> Date`
  做确定性测试（见现有测试）。音频断言走 `FakeAudioService` 的 `recordedFilenames/playedFilenames/
  playedSequences/lastLoop`。
- ViewModel 都是 `@MainActor final class ... : ObservableObject`，`@Published` 暴露 UI 状态。
- 界面用 try? 调用 ViewModel（错误处理较薄，见下方遗留项）。
- 文案、注释用中文，与现有代码一致。

## 已知遗留项（follow-up，不阻塞，可挑着做）

来自整分支代码评审，已记在 `.superpowers/sdd/progress.md`：
- UI 层 `try?` 大量静默吞错；仅 save 路径加了错误弹窗，其余音频操作失败无提示。
- `AVAudioService.playSequence` 中途文件缺失会静默中断（代码里有 TODO）。
- record→录了但不保存 会在沙盒留下孤儿 `.m4a`（cancel 已清，但"录完不存"未清）。
- 测试覆盖缺口：`playAttempt`、`stop()` 重置 `isPlaying`、`PracticeCollection` nullify 规则 等无独立测试。
- `ClipLibraryView` 分组用 collection 名做 ForEach id；"未分组" 可能与用户自建同名合集冲突。
- 合集目前**无创建/分配 UI**（数据模型支持，界面只展示分组）。

## 路线图（产品方向）

- 发音对比/评分（当前是手动对比播放，用户最初明确先不做自动评分；要做可接 Azure 发音评估等）
- 合集创建与分配 UI
- 录音波形 / 语调可视化

## 仓库 / 身份

- GitHub：`git@github.com:LinkLiLiLi/listen-shadowing.git`（公开）
- 本仓库已设**本地** git 身份 `LinkLiLiLi <LinkLiLiLi@users.noreply.github.com>`，推送用专用 deploy key
  （`~/.ssh/listen_github_ed25519`，已写进 `.git/config` 的 core.sshCommand）。
- ⚠️ **`~/.ssh/id_ed25519` 是用户公司的 GitLab 密钥，严禁用于本项目或加到 GitHub。**
- 默认分支 `master`。
