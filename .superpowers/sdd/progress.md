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
