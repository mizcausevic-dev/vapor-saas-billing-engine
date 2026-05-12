import Foundation
import Vapor

struct SubscriptionPlan: Content {
    let id: String
    let label: String
    let monthlyPrice: Double
    let annualPrice: Double
    let targetBuyer: String
}

struct AccountSubscription: Content {
    let accountId: String
    let company: String
    let planId: String
    let status: String
    let billingCycle: String
    let mrr: Double
    let seats: Int
    let renewalDate: String
    let paymentMethodHealth: String
}

struct InvoiceRecord: Content {
    let invoiceId: String
    let accountId: String
    let total: Double
    let currency: String
    let state: String
    let prorationDelta: Double
    let attemptCount: Int
    let recommendation: String
}

struct WebhookEventRecord: Content {
    let eventId: String
    let type: String
    let accountId: String
    let processed: Bool
    let outcome: String
    let idempotencyKey: String
}

struct BillingSummary: Content {
    let activeSubscriptions: Int
    let reviewAccounts: Int
    let monthlyRecurringRevenue: Double
    let dunningAccounts: Int
    let processedWebhookEvents: Int
    let leadRecommendation: String
}

struct BillingDashboard: Content {
    let summary: BillingSummary
    let subscriptions: [AccountSubscription]
    let invoices: [InvoiceRecord]
    let webhooks: [WebhookEventRecord]
}

struct WebhookSimulationInput: Content {
    let eventId: String
    let type: String
    let accountId: String
    let amount: Double
    let idempotencyKey: String
}

struct WebhookSimulationResult: Content {
    let outcome: String
    let duplicate: Bool
    let event: WebhookEventRecord
    let summary: BillingSummary
}
