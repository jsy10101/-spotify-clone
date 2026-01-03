.PHONY: server server-network client codegen dev help

help:
	@echo "Available commands:"
	@echo "  make server         - Run FastAPI server (localhost only - SECURE for regular development)"
	@echo "  make server-network - Run FastAPI server (all interfaces - for physical device testing)"
	@echo "  make client         - Run Flutter app on iPhone 15 Pro simulator"
	@echo "  make codegen        - Run Flutter code generation (build_runner watch)"
	@echo "  make dev            - Run all development services concurrently (output will be mixed)"

# Default server - binds to localhost only (127.0.0.1)
# SECURE: Only accessible from this machine
# Use this for: Simulator testing, regular development
server:
	cd server && source venv/bin/activate && fastapi dev main.py

# Network server - binds to all interfaces (0.0.0.0)
# CAUTION: Accessible from any device on your network
# Use this ONLY for: Physical iPhone/device testing
# REMEMBER: Switch back to 'make server' when done testing on physical device
server-network:
	cd server && source venv/bin/activate && uvicorn main:app --reload --host 0.0.0.0 --port 8000

client:
	cd client && flutter run -d "iPhone 15 Pro"

codegen:
	cd client && dart run build_runner watch -d

dev:
	@echo "Starting all development services concurrently..."
	@echo "Note: Output from all services will be mixed. Use Ctrl+C to stop all services."
	@echo ""
	@$(MAKE) server & $(MAKE) client & $(MAKE) codegen & wait
