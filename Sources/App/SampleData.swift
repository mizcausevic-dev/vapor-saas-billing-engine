import Foundation

enum SampleData {
    static let plans: [SubscriptionPlan] = [
        .init(id: "growth", label: "Growth", monthlyPrice: 1490, annualPrice: 15480, targetBuyer: "Scaling product teams"),
        .init(id: "platform", label: "Platform", monthlyPrice: 4200, annualPrice: 45360, targetBuyer: "Multi-tenant SaaS operators"),
        .init(id: "enterprise", label: "Enterprise", monthlyPrice: 9600, annualPrice: 103680, targetBuyer: "Security-heavy enterprise accounts")
    ]

    static let subscriptions: [AccountSubscription] = [
        .init(accountId: "acct-northstar", company: "Northstar Workspace", planId: "enterprise", status: "active", billingCycle: "annual", mrr: 8640, seats: 320, renewalDate: "2026-07-01", paymentMethodHealth: "healthy"),
        .init(accountId: "acct-lattice", company: "Lattice Harbor", planId: "platform", status: "past_due", billingCycle: "monthly", mrr: 4200, seats: 118, renewalDate: "2026-05-29", paymentMethodHealth: "retrying"),
        .init(accountId: "acct-cedar", company: "Cedar Lane Health", planId: "growth", status: "trialing", billingCycle: "monthly", mrr: 1490, seats: 44, renewalDate: "2026-05-20", paymentMethodHealth: "healthy")
    ]

    static let invoices: [InvoiceRecord] = [
        .init(invoiceId: "inv_2201", accountId: "acct-northstar", total: 96480, currency: "USD", state: "paid", prorationDelta: 1200, attemptCount: 1, recommendation: "Keep annual plan and attach the seat uplift note to the account brief."),
        .init(invoiceId: "inv_2202", accountId: "acct-lattice", total: 4200, currency: "USD", state: "retrying", prorationDelta: 0, attemptCount: 3, recommendation: "Route into dunning lane with high-touch recovery before plan suspension."),
        .init(invoiceId: "inv_2203", accountId: "acct-cedar", total: 490, currency: "USD", state: "preview", prorationDelta: -1000, attemptCount: 0, recommendation: "Preview downgrade math and show operator-ready proration explanation.")
    ]

    static let webhookEvents: [WebhookEventRecord] = [
        .init(eventId: "evt_9001", type: "invoice.paid", accountId: "acct-northstar", processed: true, outcome: "Recognized plan uplift and closed the renewal lane.", idempotencyKey: "idemp_evt_9001"),
        .init(eventId: "evt_9002", type: "invoice.payment_failed", accountId: "acct-lattice", processed: true, outcome: "Opened dunning sequence and escalated owner follow-up.", idempotencyKey: "idemp_evt_9002"),
        .init(eventId: "evt_9003", type: "customer.subscription.updated", accountId: "acct-cedar", processed: true, outcome: "Recomputed proration and refreshed the operator preview.", idempotencyKey: "idemp_evt_9003")
    ]
}
