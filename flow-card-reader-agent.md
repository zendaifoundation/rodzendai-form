# Flow: ID Card Reader Agent

## ภาพรวม

ระบบอ่านบัตรประชาชนรองรับ 2 agent ผ่าน WebSocket โดยใช้ **Auto-detect** — ลอง IDWAgent ก่อน ถ้าไม่ได้ค่อยลอง ZendaiAgent

```
IDWAgent   ws://localhost:14820/IDWAgent      (agent สำเร็จรูป)
ZendaiAgent  ws://localhost:15820/ZendaiAgent   (agent ที่เขียนเอง)
```

---

## โครงสร้างไฟล์

```
blocs/id_card_reader/
  agents/
    id_card_agent.dart     — abstract interface + AgentCardData
    idw_agent.dart         — IDWAgent protocol
    zendai_agent.dart      — ZendaiAgent protocol
  id_card_reader_bloc.dart
  id_card_reader_event.dart
  id_card_reader_state.dart
```

---

## Flow หลัก

### 1. Connect (Auto-detect)

```
Page.initState()
  └─ add(IDCardConnectRequested)
       └─ BLoC: _buildCandidates() → [IDWAgent(), ZendaiAgent()]  ← สร้างใหม่ทุกครั้ง
            │
            ├─ try IDWAgent.connect() ── timeout 2s ──► fail
            │    └─ IDWAgent.dispose()
            │
            └─ try ZendaiAgent.connect() ── timeout 2s ──► success
                 ├─ _agent = ZendaiAgent
                 ├─ subscribe cardStream + errorStream
                 └─ emit IDCardConnected(agentName: "ZendaiAgent")
                      └─ Page listener → เปิด IdCardRequestDialog
```

ถ้าทั้งคู่ fail:
```
emit IDCardFailure("ไม่พบเครื่องอ่านบัตร...")
```

---

### 2. อ่านบัตร

```
User กดปุ่ม "อ่านข้อมูลจากบัตร"
  └─ add(IDCardReadRequested)
       └─ BLoC: emit IDCardReading()
            └─ agent.sendReadCard()

── IDWAgent ──────────────────────────────────────────
send: {"Command":"ReadIDCard", "IDNumberRead":true, ...}

server response:
{"Message":"ReadIDCardR", "Status":0, "IDNumber":"...", "IDText":"นาย#สมชาย#..."}
  └─ IDWAgent._parse() → แยก IDText ด้วย '#'
       └─ AgentCardData(idCard, firstName, lastName, address, bridthDate="YYYYMMDD พ.ศ.")

── ZendaiAgent ───────────────────────────────────────
send: {"command":"read_card"}

server response:
{"event":"card_data", "data":{"cid":"...", "firstnameTH":"...", "bridthDate":"dd/MM/yyyy ค.ศ.", ...}}
  └─ ZendaiAgent._normalize() → แปลง bridthDate "24/12/1997" → "25401224" (YYYYMMDD พ.ศ.)
       └─ AgentCardData(idCard, firstName, lastName, address, bridthDate="YYYYMMDD พ.ศ.")

── ทั้งคู่ส่ง AgentCardData เข้า cardStream ──────────
  └─ BLoC._onDataReceived()
       └─ AgentCardData → IDCardPayload
            └─ emit IDCardReadSuccess(payload)
                 └─ Dialog listener → Navigator.pop(payload)
                      └─ Page: setPatientInfoFromIDCard(payload)
```

หากอ่านไม่สำเร็จ:
```
ZendaiAgent: {"event":"error"} → errorStream.add("อ่านบัตรไม่สำเร็จ")
IDWAgent:    ReadIDCardR Status != 0  → errorStream.add("อ่านบัตรไม่สำเร็จ, code: X")
  └─ BLoC._onErrorReceived() → emit IDCardFailure → _disposeAgent()
```

---

### 3. Connection หลุด (Auto-reconnect)

```
WebSocket onDone ยิง (connection หลุดกะทันหัน)
  └─ agent._reconnect()
       ├─ cancel subscription + close channel
       ├─ delay 500ms
       └─ reconnect WebSocket
            ├─ success → subscribe ใหม่ → พร้อมรับ read_card ได้ทันที
            └─ fail    → errorStream.add("ขาดการเชื่อมต่อกับเครื่องอ่านบัตร")
                           └─ BLoC → emit IDCardFailure → _disposeAgent()

หมายเหตุ: "Connection closed" จาก onDone ถูก ignore ที่ BLoC
           เพราะ server เปิดตลอด — ไม่ถือเป็น error
```

---

### 4. Reset / ออกจากหน้า

```
Page.dispose()
  └─ add(IDCardResetRequested)
       └─ BLoC._disposeAgent()
            ├─ cancel cardSub + errorSub
            ├─ agent.dispose() → _disposed = true → ปิด StreamController + WebSocket
            └─ emit IDCardInitial()

กลับมาหน้าเดิม:
  └─ Page.initState() → add(IDCardConnectRequested)
       └─ _buildCandidates() → สร้าง instances ใหม่ทั้งหมด (ไม่มีปัญหา _disposed เดิม)
```

---

## State Diagram

```
IDCardInitial
    │  IDCardConnectRequested
    ▼
IDCardConnecting
    │  connect สำเร็จ
    ▼
IDCardConnected(agentName)  ◄──────────────────────────────┐
    │  IDCardReadRequested                                   │
    ▼                                                        │
IDCardReading                                               │ (อ่านสำเร็จ dialog ปิด
    │  card_data received                                    │  state ยังอยู่ที่ ReadSuccess
    ▼                                                        │  กดอ่านใหม่ได้เลย)
IDCardReadSuccess(payload) ─────────────────────────────────┘
    │  IDCardReadRequested (อ่านซ้ำ)
    ▼
IDCardReading → ...

IDCardReading / IDCardConnected / IDCardReadSuccess
    │  error จาก agent
    ▼
IDCardFailure(message)
    │  IDCardResetRequested
    ▼
IDCardInitial
```

---

## bridthDate Format

| Agent | Format ที่ได้รับ | Format ที่ส่งต่อ | หมายเหตุ |
|---|---|---|---|
| IDWAgent | `"25401224"` (YYYYMMDD พ.ศ.) | ไม่เปลี่ยน | downstream ลบ 543 เอง |
| ZendaiAgent | `"24/12/1997"` (dd/MM/yyyy ค.ศ.) | `"25401224"` (YYYYMMDD พ.ศ.) | แปลงใน `_convertBridthDate()` |

Downstream ที่ใช้ `bridthDate`:
- `register_to_claim_your_rights_provider.dart:831` — `substring(0,4)` แล้วลบ 543

---

## Key Design Decisions

| เรื่อง | การตัดสินใจ | เหตุผล |
|---|---|---|
| สร้าง candidates | สร้างใหม่ทุกครั้งที่ connect | agent ที่ `dispose()` แล้วใช้ซ้ำไม่ได้ |
| `_disposed` flag | เช็คก่อน add ทุก stream | ป้องกัน "Cannot add after close" เมื่อ message มาหลัง dispose |
| "Connection closed" | ignore ที่ BLoC | server เปิดตลอด — onDone = หลุดชั่วคราว ให้ reconnect แทน |
| IDWAgent GetReaderList | auto-select reader แรก | ไม่ให้ user เลือก reader เอง |
| มือถือ/แท็บเล็ต | connect fail gracefully | `localhost` บนมือถือไม่มี agent → IDCardFailure ตามปกติ |
