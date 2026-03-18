#Requires AutoHotkey v2.0
#SingleInstance Force

SetTitleMatchMode(2)

; ============================================================
; DQX 自動ログインスクリプト
;
; Bitwarden CLI (bw) からパスワード・OTP を自動取得して入力
;
; ホットキー:
;   F1  : 自動ログイン開始（プレイヤー1 → プレイヤー2）
;   F2  : マウス座標表示（座標調整用）
;   Esc : スクリプト終了
;
; 前提条件:
;   - bw がインストール済み・ログイン済み (bw login)
;   - 各プレイヤーの BW アイテムにパスワードと TOTP が設定済み
; ============================================================

; === 設定 ===
DQX_BOOT := "E:\Program Files (x86)\SquareEnix\DRAGON QUEST X\Boot\DQXBoot.exe"
LAUNCHER_TITLE := "ahk_exe DQXLauncher.exe"

; Bitwarden アイテム UUID
BW_ID := Map(
    "player1", "75619f49-82fb-4d90-870a-dc2075663995",
    "player2", "3f5922be-ac15-4fbc-b126-09e0ba62c658",
)

; ランチャー内座標（クライアント領域基準）
; ※ F2 キーで実際の座標を確認して調整してください
POS := Map(
    "player1",   [77, 300],     ; プレイヤー1 ラジオボタン
    "player2",   [77, 320],     ; プレイヤー2 ラジオボタン
    "password",  [506, 318],    ; パスワード入力フィールド
    "start",     [444, 437],    ; 「オンラインモードを開始」ボタン
    "otp",       [491, 292],    ; OTP 入力フィールド（要調整）
)

; 待機時間（ミリ秒）
WAIT := Map(
    "after_select",     100,    ; プレイヤー選択後
    "after_click",      50,     ; フィールドクリック後
    "before_start",     50,     ; 開始ボタン押下前
    "otp_appear",       50,   ; OTP ダイアログ表示待ち
    "game_launch",      50,  ; ゲーム起動完了待ち
    "launcher_init",    8000,   ; ランチャー描画完了待ち
)

; BW セッション（内部使用）
BwSession := ""

; === 起動モード ===
; 引数 "run" 付きで起動された場合は即時実行して終了
; 引数なしの場合はホットキーモード（F1: 実行, F2: 座標確認）
if A_Args.Length > 0 && A_Args[1] = "run" {
    RunDqxLogin()
    ExitApp()
}

F1::RunDqxLogin()

F2:: {
    CoordMode("Mouse", "Client")
    MouseGetPos(&mx, &my)
    ToolTip("Client: x=" mx " y=" my)
    SetTimer(() => ToolTip(), -3000)
}

Esc::ExitApp()

; === メイン処理 ===
RunDqxLogin() {
    global BwSession

    Status("BW アンロック中...")
    if !BwUnlock()
        return

    Status("DQX ランチャー起動中...")
    if !ActivateOrLaunch()
        return

    Status("プレイヤー1 ログイン中...")
    if !Login("player1")
        return

    Status("ゲーム起動待機中...")
    Sleep(WAIT["game_launch"])

    ; プレイヤー2 のためにランチャーを再度開く
    Status("ランチャー復帰中...")
    if !ActivateOrLaunch()
        return

    Status("プレイヤー2 ログイン中...")
    Login("player2")

    ; セキュリティ: BW をロック
    RunCmd("bw lock")
    BwSession := ""
    Status("完了！")
    SetTimer(() => ToolTip(), -3000)
}

; === ログイン処理 ===
Login(player) {
    CoordMode("Mouse", "Client")
    WinActivate(LAUNCHER_TITLE)
    WinWaitActive(LAUNCHER_TITLE)

    ; プレイヤー選択
    ClickAt(POS[player])
    Sleep(WAIT["after_select"])

    ; パスワードフィールドをクリック → 全選択 → 入力
    ClickAt(POS["password"])
    Sleep(WAIT["after_click"])
    Send("^a")
    Sleep(100)

    pw := BwGet("password", BW_ID[player])
    if (pw = "") {
        MsgBox(player ": パスワード取得に失敗しました。`nbw が unlock されているか確認してください。")
        return false
    }
    SendText(pw)
    pw := ""
    Sleep(WAIT["before_start"])

    ; 「オンラインモードを開始」クリック
    ClickAt(POS["start"])
    Sleep(WAIT["otp_appear"])

    ; OTP 入力（TOTP は時間依存なので直前に取得）
    totp := BwGet("totp", BW_ID[player])
    if (totp = "") {
        MsgBox(player ": TOTP 取得に失敗しました。")
        return false
    }
    ClickAt(POS["otp"])
    Sleep(WAIT["after_click"])
    SendText(totp)
    totp := ""
    Sleep(WAIT["after_click"])
    Send("{Enter}")
    Sleep(1000)

    return true
}

; === ランチャー起動/アクティブ化 ===
ActivateOrLaunch() {
    if WinExist(LAUNCHER_TITLE) {
        WinActivate(LAUNCHER_TITLE)
    } else {
        Run(DQX_BOOT)
    }
    if !WinWaitActive(LAUNCHER_TITLE,, 30) {
        MsgBox("ランチャーが見つかりません。タイムアウトしました。")
        return false
    }
    Sleep(WAIT["launcher_init"])
    return true
}

; === Bitwarden ヘルパー ===
BwUnlock() {
    global BwSession

    statusJson := RunCmd("bw status")

    if InStr(statusJson, '"unlocked"') {
        ; 既にアンロック済み → セッションキー不要
        BwSession := ""
        return true
    }

    if !InStr(statusJson, '"locked"') {
        MsgBox("Bitwarden にログインされていません。`n先に bw login を実行してください。")
        return false
    }

    ; マスターパスワードを入力
    ib := InputBox("Bitwarden マスターパスワード", "BW Unlock", "Password w350 h130")
    if (ib.Result = "Cancel")
        return false

    ; 環境変数経由でパスワードを渡す（プロセスリストに露出しない）
    EnvSet("DQX_BW_PW", ib.Value)
    session := RunCmd("bw unlock --passwordenv DQX_BW_PW --raw")
    EnvSet("DQX_BW_PW", "")

    if (session = "" || InStr(session, "Invalid") || InStr(session, "error")) {
        MsgBox("Bitwarden アンロックに失敗しました。`nパスワードを確認してください。")
        return false
    }

    BwSession := session
    return true
}

BwGet(type, itemId) {
    global BwSession
    cmd := "bw get " type " " itemId
    if (BwSession != "")
        cmd .= ' --session "' BwSession '"'
    return RunCmd(cmd)
}

; === ユーティリティ ===
RunCmd(cmd) {
    tmpFile := A_Temp "\dqx_" A_TickCount ".tmp"
    try {
        RunWait(A_ComSpec ' /c ' cmd ' > "' tmpFile '" 2>nul',, "Hide")
        result := Trim(FileRead(tmpFile), " `t`r`n")
        FileDelete(tmpFile)
        return result
    } catch {
        try FileDelete(tmpFile)
        return ""
    }
}

ClickAt(pos) {
    Click(pos[1], pos[2])
}

Status(msg) {
    ToolTip(msg)
}
