.PHONY: deploy help

# ─── Colour helpers ───────────────────────────────────────────────────────────
BOLD  := \033[1m
CYAN  := \033[1;36m
GREEN := \033[1;32m
YELLOW:= \033[1;33m
RED   := \033[1;31m
RESET := \033[0m

# ─── Customer / env / firebase-site matrix ────────────────────────────────────
#
#  customer          env file                             firebase site
#  ───────────────── ──────────────────────────────────── ──────────────────────────────────
#  bangkok           .env                                 rodzendai-form
#  bangkok           .env.staging                         rodzendai-form-staging
#  bangkok           .env.sandbox                         rodzendai-form-sandbox
#  samed             .env_samed                           rodzendai-form-samed
#  samed             .env.staging_samed                   rodzendai-form-samed-staging
#  samed             .env.sandbox_samed                   rodzendai-form-samed-sandbox
#  pattaya           .env_pattaya                         rodzendai-form-pattaya
#  pattaya           .env.sandbox_pattaya                 rodzendai-form-pattaya-sandbox
#  pattaya           .env.staging_pattaya                 rodzendai-form-pattaya-staging
#  tessaban_angsila  .env_tessaban_angsila                rodzendai-form-tessaban-angsila
#  tessaban_angsila  .env.staging_angsila                 rodzendai-form-tessaban-angsila-staging
#  tessaban_angsila  .env.sandbox_tessaban_angsila        rodzendai-form-tessaban-angsila-sandbox
#  tessaban_saensuk  .env_tessaban_saensuk                rodzendai-form-tessaban-saensuk
#  tessaban_saensuk  .env.staging_saensuk                 rodzendai-form-saensuk-staging
#  tessaban_saensuk  .env.sandbox_tessaban_saensuk        rodzendai-form-saensuk-sandbox

help:
	@echo ""
	@echo "$(BOLD)$(CYAN)rodzendai-form deploy$(RESET)"
	@echo ""
	@echo "  $(BOLD)make deploy$(RESET)   — interactive deploy wizard"
	@echo ""

deploy:
	@bash scripts/deploy_interactive.sh
