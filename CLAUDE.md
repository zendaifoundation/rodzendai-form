# CLAUDE.md

คำแนะนำสำหรับ Claude Code เมื่อทำงานกับ repo นี้

## ภาษา

สื่อสารกับผู้ใช้เป็น **ภาษาไทย** เสมอ

## Git Flow (บังคับ)

repo นี้ใช้ [git-flow](https://danielkummer.github.io/git-flow-cheatsheet/) — รายละเอียดเต็มอยู่ใน [README.md](README.md#git-flow)

### สรุปกฎที่ Claude ต้องยึด

| Branch | บทบาท |
|--------|-------|
| `master` | production เท่านั้น ทุก merge ต้องมี tag `vX.Y.Z` |
| `develop` | integration branch สำหรับ release ถัดไป |
| `feature/*` | แตกจาก `develop` → PR เข้า `develop` |
| `bugfix/*` | แตกจาก `develop` → PR เข้า `develop` |
| `release/*` | แตกจาก `develop` → PR เข้า `master` **และ** back-merge เข้า `develop` |
| `hotfix/*` | แตกจาก `master` → PR เข้า `master` **และ** back-merge เข้า `develop` |

**ข้อห้าม:**
- ❌ ห้าม commit หรือ push ตรงเข้า `master` / `develop` — ต้องผ่าน PR
- ❌ ห้ามเปิด PR จาก `feature/*` หรือ `bugfix/*` เข้า `master` โดยตรง
- ❌ ห้ามใช้ squash merge — ใช้ merge commit (`--merge` / `--no-ff`) เพื่อรักษาประวัติ branch
- ❌ ห้าม merge เข้า `master` โดยไม่ติด tag

**ต้องทำ:**
- ✅ ตรวจสอบ branch ปัจจุบันด้วย `git status` ก่อนเริ่มงานเสมอ ถ้าอยู่บน `master`/`develop` ให้แตก branch ใหม่ก่อน
- ✅ bump `version:` ใน `pubspec.yaml` ก่อนเปิด release PR
- ✅ หลัง merge เข้า `master` ให้ติด tag `vX.Y.Z` ตรงกับ semver ใน `pubspec.yaml` แล้วสร้าง GitHub Release
- ✅ หลัง merge `hotfix/*` หรือ `release/*` เข้า `master` ต้อง back-merge กลับ `develop` เสมอ

### ลำดับที่ Claude ต้องทำเวลา release

1. เช็คว่ามีงานค้างบน `feature/*` / `bugfix/*` ที่ยังไม่เข้า `develop` หรือไม่ → เปิด PR เข้า `develop` ก่อน
2. รอ/merge PR เหล่านั้นให้เรียบร้อย
3. bump version ใน `pubspec.yaml` บน `develop`
4. เปิด release PR `develop` → `master`
5. หลัง merge → `git tag -a vX.Y.Z` แล้ว `git push origin vX.Y.Z`
6. `gh release create vX.Y.Z`

> ⚠️ การ merge PR และการ push tag เป็น action ที่กระทบ production — **ให้ถามผู้ใช้ยืนยันก่อนเสมอ** ห้ามทำเองโดยอัตโนมัติ

## Versioning

- `pubspec.yaml` → `version: X.Y.Z+BUILD` (เช่น `1.0.24+276`)
- git tag → `vX.Y.Z` (ไม่รวม `+BUILD`)

## Tech Stack

- Flutter (web เป็นหลัก) จัดการเวอร์ชันด้วย `fvm`
- Firebase (Firestore + Hosting)
- LINE LIFF สำหรับ login

## โครงสร้างสำคัญ

- `lib/presentation/` — หน้าจอต่าง ๆ (home_page, register, register_status, splash)
- `lib/repositories/` — data layer
- `lib/core/` — constants, network, routes, services
- `.env*` — config แยกตาม customer (ห้าม commit ดู [SECURITY.md](SECURITY.md))

## Multi-tenant

แอปนี้ deploy หลาย customer จาก codebase เดียว แยกด้วย `CUSTOMER_CODE` ใน `.env_*`
(`bangkok`, `pattaya`, `samed`, `tessaban_saensuk`, `tessaban_angsila`)

คำสั่ง build/deploy ของแต่ละ customer ดูใน [README.md](README.md#deployment)

## ก่อน deploy ทุกครั้ง

ต้อง generate splash ใหม่ตาม partner — ดูหัวข้อ "Update splash logo" ใน [README.md](README.md)
