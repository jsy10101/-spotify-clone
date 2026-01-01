.PHONY: server client codegen dev help

help:
	@echo "Available commands:"
	@echo "  make server   - Run FastAPI development server"
	@echo "  make client   - Run Flutter app on iPhone 15 Pro simulator"
	@echo "  make codegen  - Run Flutter code generation (build_runner watch)"
	@echo "  make dev      - Run all development services concurrently (output will be mixed)"

server:
	cd server && source venv/bin/activate && fastapi dev main.py

client:
	cd client && flutter run -d "iPhone 15 Pro"

codegen:
	cd client && dart run build_runner watch -d

dev:
	@echo "Starting all development services concurrently..."
	@echo "Note: Output from all services will be mixed. Use Ctrl+C to stop all services."
	@echo ""
	@$(MAKE) server & $(MAKE) client & $(MAKE) codegen & wait
