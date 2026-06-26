# 口语跟读 App — 执行进度账本

计划：docs/superpowers/plans/2026-06-26-口语跟读app.md
分支：feature/口语跟读-mvp
基线提交：0b220ab

## 任务进度
（每个任务 review 通过后追加一行）
Task 1: complete (commit f348073, 工程脚手架 + 冒烟测试 ** TEST SUCCEEDED **)
Task 2: complete (commits 07a8e60..097d365, review clean)
  - minor (defer to final): ModelContainer+Preview.swift 命名暗示 extension 实为自由函数; PracticeCollection nullify 规则无独立测试
Task 3: complete (commits a8b356f..bbe034d, review clean — Important TOCTOU 已修复, 4/4 pass)
  - minor (defer to final): defaultStore() urls[0] 强下标; 测试 tempDir 未清理
Task 4: complete (commits 475371a..89cb318, review clean — 3 Important 已修复, 3/3 pass)
  - minor (defer to final): playSequence 测试未断言 isPlaying; 无 stop() 重置 isPlaying 测试; RED 未单独捕获
Task 5: complete (commits 837d90e..038e0f8, review clean — spec ✅)
  - 注意: iOS 26 ModelContext 不强引用 ModelContainer; RecordClipModel 持有 context.container 保活 (either-acceptable)
  - minor (defer to final): save() 后未清 pendingFilename(可重复保存); 测试未断言 createdAt
Task 6: complete (commits df2ca67..36a3d09, review clean — spec ✅, 5/5)
  - minor (defer to final): stopAttempt() now() 调用两次时间戳不一致; save 抛错时 pendingFilename 未清; playAttempt 无独立测试
Task 7: complete (commits 76c5008..212e7d0, review clean — spec ✅, BUILD SUCCEEDED, 全套 19/19, app 启动无崩溃) — 最小可用 app 达成
  - minor (defer to final): try? 静默吞错(尤其 save 路径无提示); @StateObject 外部传参契约脆弱; RecordView 取消时不停录(靠 deinit, 但 recorder 实际由 AVAudioService 持有→可能继续录)
Task 8: complete (commits ad7b6b7..8b37283, review clean — spec ✅, BUILD SUCCEEDED, 20/20) — 编辑+合集分组里程碑
  - minor (defer to final): EditClipView save try? 无提示; "未分组" 名称冲突边界; ForEach id 用合集名

== 所有任务完成。待整分支最终评审。==

== 整分支最终评审 (opus): Ready to merge WITH FIXES ==
final fixes (commit 6ee93d3): C1 取消停录+删孤儿文件; I1 录音/播放前先停在放(修复跟读串入原声)+停止播放按钮; I2 save 错误弹窗(RecordView/EditClipView); I3 session deactivate; M1 save 后清 pending; M2 时间戳取一次。21/21 测试通过, BUILD SUCCEEDED。
follow-up tickets (评审认可可延后): M3 record→不保存的孤儿文件清理; M4 序列播放缺文件静默中断; M5 ModelContainer+Preview 命名; M6 "未分组" 名称冲突/ForEach id; 测试补 playAttempt/stop-resets-isPlaying/nullify 规则。
