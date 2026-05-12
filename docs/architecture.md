# Architecture

## Core idea

This repo treats SaaS billing as an operating system problem instead of just an invoice problem.

The model has four core lanes:

- plans define commercial packaging
- subscriptions define current entitlement and renewal posture
- invoices define money movement and proration state
- webhook events define external lifecycle triggers and replay risk

## Why Vapor here

Vapor gives the repo a real server-side Swift shape:

- request routing
- JSON encoding and decoding
- testable handlers
- a believable API surface for internal product and finance tooling

## Idempotency story

The most important behavior in the repo is webhook replay handling.

The `BillingStore` keeps a processed idempotency-key set. When the same webhook key arrives again:

- no duplicate state mutation occurs
- the duplicate is logged into webhook history
- the operator can still explain what happened

That makes the demo feel much closer to production-grade billing work than a generic mock API.

## Local-first constraint

The data is intentionally in-memory and seeded:

- no Stripe account required
- no database required
- no external SaaS dependency required

That keeps the repo one-shot while still telling a realistic billing story.
