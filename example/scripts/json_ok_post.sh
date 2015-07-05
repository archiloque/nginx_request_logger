#!/usr/bin/env bash
curl -v -X POST -H "Content-Type: application/json" -H "X-SPECIAL-HEADER: plop" -d '{"key":"value_in"}' "http://localhost:8081/json/ok"

