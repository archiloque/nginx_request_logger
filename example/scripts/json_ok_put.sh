#!/usr/bin/env bash
curl -v -X PUT -H "Content-Type: application/json" -d '{"key":"value"}' "http://localhost:8081/json/ok"
