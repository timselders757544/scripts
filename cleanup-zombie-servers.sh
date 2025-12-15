#!/bin/bash
# Cleanup zombie Next.js development servers
# Kills Next.js processes that are using excessive CPU/memory

echo "🧹 Cleanup Zombie Development Servers"
echo "======================================"
echo ""

# Find zombie Next.js servers (high CPU, not the current active ones)
echo "🔍 Scanning for zombie Next.js processes..."
echo ""

# Get all next-server processes
ZOMBIE_PIDS=$(ps aux | grep "next-server" | grep -v grep | awk '{
    # Skip processes with low CPU (< 10%) - these are healthy idle servers
    if ($3 < 10) next;

    # Print PID, CPU%, MEM%, and port info
    print $2, $3, $4, $11
}')

if [ -z "$ZOMBIE_PIDS" ]; then
    echo "✅ No zombie processes found!"
    echo ""
    echo "📊 Active development servers:"
    lsof -i -P | grep LISTEN | grep -E "node|next" | awk '{print "   Port", $9, "→", $1, "(PID", $2")"}'
    exit 0
fi

echo "⚠️  Found potential zombie processes:"
echo "$ZOMBIE_PIDS" | while read pid cpu mem process; do
    echo "   PID $pid - CPU: ${cpu}% - MEM: ${mem}%"
done
echo ""

# Ask for confirmation
read -p "❓ Kill these processes? [y/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 1
fi

# Kill zombie processes
echo ""
echo "🔪 Killing zombie processes..."
echo "$ZOMBIE_PIDS" | while read pid cpu mem process; do
    echo "   Killing PID $pid (CPU: ${cpu}%)..."
    kill -9 "$pid" 2>/dev/null
done

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📊 Remaining development servers:"
lsof -i -P | grep LISTEN | grep -E "node|next" | awk '{print "   Port", $9, "→", $1, "(PID", $2")"}'
