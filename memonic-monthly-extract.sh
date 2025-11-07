#!/bin/bash

# Memonic Monthly Extract
# Draait automatisch elke maand op de 1e om 03:00

cd /Volumes/DevSSD/Development/Memonic/webapp

# Roep de extract API aan (lokaal)
curl -X POST http://localhost:3001/api/extract-existing \
  -H "Content-Type: application/json" \
  -o /tmp/memonic-extract-$(date +%Y%m%d).log

echo "Extract completed at $(date)" >> /var/log/memonic-extract.log
