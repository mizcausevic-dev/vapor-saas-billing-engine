import Foundation

actor BillingStore {
    private let plans: [SubscriptionPlan]
    private var subscriptions: [AccountSubscription]
    private var invoices: [InvoiceRecord]
    private var webhookEvents: [WebhookEventRecord]
    private var processedKeys: Set<String>

    init(
        plans: [SubscriptionPlan] = SampleData.plans,
        subscriptions: [AccountSubscription] = SampleData.subscriptions,
        invoices: [InvoiceRecord] = SampleData.invoices,
        webhookEvents: [WebhookEventRecord] = SampleData.webhookEvents
    ) {
        self.plans = plans
        self.subscriptions = subscriptions
        self.invoices = invoices
        self.webhookEvents = webhookEvents
        self.processedKeys = Set(webhookEvents.map(\.idempotencyKey))
    }

    func plansList() -> [SubscriptionPlan] {
        plans
    }

    func subscriptionsList() -> [AccountSubscription] {
        subscriptions
    }

    func invoicesList() -> [InvoiceRecord] {
        invoices
    }

    func webhookEventsList() -> [WebhookEventRecord] {
        webhookEvents
    }

    func summary() -> BillingSummary {
        let activeSubscriptions = subscriptions.filter { $0.status == "active" }.count
        let reviewAccounts = subscriptions.filter { ["past_due", "trialing"].contains($0.status) }.count
        let monthlyRecurringRevenue = subscriptions.reduce(0) { $0 + $1.mrr }
        let dunningAccounts = invoices.filter { $0.state == "retrying" }.count
        let processedWebhookEvents = webhookEvents.filter(\.processed).count
        let leadRecommendation = "Stabilize the dunning lane for Lattice Harbor before the retry posture becomes involuntary churn."

        return BillingSummary(
            activeSubscriptions: activeSubscriptions,
            reviewAccounts: reviewAccounts,
            monthlyRecurringRevenue: monthlyRecurringRevenue,
            dunningAccounts: dunningAccounts,
            processedWebhookEvents: processedWebhookEvents,
            leadRecommendation: leadRecommendation
        )
    }

    func dashboard() -> BillingDashboard {
        BillingDashboard(
            summary: summary(),
            subscriptions: subscriptions,
            invoices: invoices,
            webhooks: webhookEvents
        )
    }

    func simulateWebhook(_ input: WebhookSimulationInput) -> WebhookSimulationResult {
        if processedKeys.contains(input.idempotencyKey) {
            let duplicateRecord = WebhookEventRecord(
                eventId: input.eventId,
                type: input.type,
                accountId: input.accountId,
                processed: false,
                outcome: "Duplicate suppressed by idempotency guard. Existing billing state remains authoritative.",
                idempotencyKey: input.idempotencyKey
            )
            webhookEvents.insert(duplicateRecord, at: 0)
            return WebhookSimulationResult(
                outcome: "duplicate_ignored",
                duplicate: true,
                event: duplicateRecord,
                summary: summary()
            )
        }

        processedKeys.insert(input.idempotencyKey)

        let outcome: String
        if input.type == "invoice.payment_failed" {
            outcome = "Opened dunning workflow, incremented retry pressure, and flagged the account for assisted recovery."
        } else if input.type == "customer.subscription.updated" {
            outcome = "Recomputed proration and refreshed the subscription lifecycle forecast."
        } else {
            outcome = "Processed webhook and committed the lifecycle event into the billing timeline."
        }

        let record = WebhookEventRecord(
            eventId: input.eventId,
            type: input.type,
            accountId: input.accountId,
            processed: true,
            outcome: outcome,
            idempotencyKey: input.idempotencyKey
        )

        webhookEvents.insert(record, at: 0)
        webhookEvents = Array(webhookEvents.prefix(8))

        if input.type == "invoice.payment_failed",
           let index = subscriptions.firstIndex(where: { $0.accountId == input.accountId }) {
            let current = subscriptions[index]
            subscriptions[index] = AccountSubscription(
                accountId: current.accountId,
                company: current.company,
                planId: current.planId,
                status: "past_due",
                billingCycle: current.billingCycle,
                mrr: current.mrr,
                seats: current.seats,
                renewalDate: current.renewalDate,
                paymentMethodHealth: "retrying"
            )
        }

        return WebhookSimulationResult(
            outcome: "processed",
            duplicate: false,
            event: record,
            summary: summary()
        )
    }
}
